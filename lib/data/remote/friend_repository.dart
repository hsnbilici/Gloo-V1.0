import 'package:flutter/foundation.dart';
import '../remote/supabase_client.dart';
import 'dto/leaderboard_entry.dart';

class FriendInfo {
  const FriendInfo({
    required this.userId,
    required this.username,
    required this.friendCode,
    required this.isMutual,
  });

  final String userId;
  final String username;
  final String friendCode;
  final bool isMutual;

  factory FriendInfo.fromMap(Map<String, dynamic> map, {bool isMutual = false}) {
    return FriendInfo(
      userId: map['id'] as String? ?? '',
      username: map['username'] as String? ?? 'Player',
      friendCode: map['friend_code'] as String? ?? '',
      isMutual: isMutual,
    );
  }
}

class FriendsRankData {
  const FriendsRankData({
    required this.rank,
    required this.total,
    required this.myScore,
    this.rivalName,
    this.rivalScore,
  });

  final int rank;
  final int total;
  final int myScore;
  final String? rivalName;
  final int? rivalScore;
}

class FriendRepository {
  bool get isConfigured => SupabaseConfig.isConfigured && SupabaseConfig.isInitialized;
  String? get _userId => SupabaseConfig.currentUserId;

  /// Follow a user by their userId. Returns true if successful.
  Future<bool> follow(String targetUserId) async {
    if (!isConfigured) return false;
    final uid = _userId;
    if (uid == null || uid == targetUserId) return false;
    try {
      await SupabaseConfig.client.from('follows').insert({
        'follower_id': uid,
        'following_id': targetUserId,
      });
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('FriendRepository.follow error: $e');
      return false;
    }
  }

  /// Unfollow a user.
  Future<void> unfollow(String targetUserId) async {
    if (!isConfigured) return;
    final uid = _userId;
    if (uid == null) return;
    try {
      await SupabaseConfig.client
          .from('follows')
          .delete()
          .eq('follower_id', uid)
          .eq('following_id', targetUserId);
    } catch (e) {
      if (kDebugMode) debugPrint('FriendRepository.unfollow error: $e');
    }
  }

  /// Search user by friend code (exact match).
  Future<FriendInfo?> searchByCode(String code) async {
    if (!isConfigured) return null;
    try {
      final data = await SupabaseConfig.client
          .from('profiles')
          .select('id, username, friend_code')
          .eq('friend_code', code.toUpperCase())
          .maybeSingle();
      if (data == null) return null;
      final isMutual = await _checkMutual(data['id'] as String);
      return FriendInfo.fromMap(data, isMutual: isMutual);
    } catch (e) {
      if (kDebugMode) debugPrint('FriendRepository.searchByCode error: $e');
      return null;
    }
  }

  /// Search users by username (ilike, max 20 results).
  Future<List<FriendInfo>> searchByUsername(String query) async {
    if (!isConfigured || query.length < 3) return [];
    final uid = _userId;
    try {
      final data = await SupabaseConfig.client
          .from('profiles')
          .select('id, username, friend_code')
          .ilike('username', '%$query%')
          .neq('id', uid ?? '')
          .limit(20);
      return (data as List)
          .map((e) => FriendInfo.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('FriendRepository.searchByUsername error: $e');
      return [];
    }
  }

  /// Get list of users I follow (with mutual check).
  Future<List<FriendInfo>> getFollowing() async {
    if (!isConfigured) return [];
    final uid = _userId;
    if (uid == null) return [];
    try {
      final data = await SupabaseConfig.client
          .from('follows')
          .select('following_id, profiles!follows_following_id_fkey(id, username, friend_code)')
          .eq('follower_id', uid);

      // Get list of people who follow me back
      final reverseData = await SupabaseConfig.client
          .from('follows')
          .select('follower_id')
          .eq('following_id', uid);
      final reverseSet = (reverseData as List)
          .map((e) => e['follower_id'] as String)
          .toSet();

      return (data as List).map((e) {
        final profile = e['profiles'] as Map<String, dynamic>;
        final targetId = profile['id'] as String;
        return FriendInfo.fromMap(profile, isMutual: reverseSet.contains(targetId));
      }).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('FriendRepository.getFollowing error: $e');
      return [];
    }
  }

  /// Get list of users who follow me.
  Future<List<FriendInfo>> getFollowers() async {
    if (!isConfigured) return [];
    final uid = _userId;
    if (uid == null) return [];
    try {
      final data = await SupabaseConfig.client
          .from('follows')
          .select('follower_id, profiles!follows_follower_id_fkey(id, username, friend_code)')
          .eq('following_id', uid);

      return (data as List).map((e) {
        final profile = e['profiles'] as Map<String, dynamic>;
        return FriendInfo.fromMap(profile);
      }).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('FriendRepository.getFollowers error: $e');
      return [];
    }
  }

  /// Get friends leaderboard for a mode.
  Future<List<LeaderboardEntry>> getFriendsLeaderboard({
    required String mode,
    bool weekly = false,
    int limit = 50,
  }) async {
    if (!isConfigured) return [];
    try {
      final data = await SupabaseConfig.client
          .from('friends_leaderboard_view')
          .select('user_id, mode, score, created_at, username')
          .eq('mode', mode)
          .order('score', ascending: false)
          .limit(weekly ? limit * 3 : limit);

      var entries = (data as List)
          .map((e) => LeaderboardEntry.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();

      if (weekly) {
        final weekAgo = DateTime.now().subtract(const Duration(days: 7));
        entries = entries
            .where((e) => e.createdAt != null && e.createdAt!.isAfter(weekAgo))
            .toList();
      }
      if (entries.length > limit) entries = entries.sublist(0, limit);
      return entries;
    } catch (e) {
      if (kDebugMode) debugPrint('FriendRepository.getFriendsLeaderboard error: $e');
      return [];
    }
  }

  /// Get weekly rank among friends.
  Future<FriendsRankData?> getFriendsRank({
    required String mode,
    bool weekly = true,
  }) async {
    if (!isConfigured) return null;
    try {
      final result = await SupabaseConfig.client.rpc('get_friends_rank', params: {
        'p_mode': mode,
        'p_weekly': weekly,
      });
      if (result == null) return null;
      final map = result as Map<String, dynamic>;
      return FriendsRankData(
        rank: map['rank'] as int? ?? 0,
        total: map['total'] as int? ?? 0,
        myScore: map['myScore'] as int? ?? 0,
        rivalName: map['rivalName'] as String?,
        rivalScore: map['rivalScore'] as int?,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('FriendRepository.getFriendsRank error: $e');
      return null;
    }
  }

  /// Get my friend code.
  Future<String?> getMyFriendCode() async {
    if (!isConfigured) return null;
    final uid = _userId;
    if (uid == null) return null;
    try {
      final data = await SupabaseConfig.client
          .from('profiles')
          .select('friend_code')
          .eq('id', uid)
          .maybeSingle();
      return data?['friend_code'] as String?;
    } catch (e) {
      if (kDebugMode) debugPrint('FriendRepository.getMyFriendCode error: $e');
      return null;
    }
  }

  Future<bool> _checkMutual(String targetId) async {
    final uid = _userId;
    if (uid == null) return false;
    try {
      final data = await SupabaseConfig.client
          .from('follows')
          .select('follower_id')
          .eq('follower_id', targetId)
          .eq('following_id', uid)
          .maybeSingle();
      return data != null;
    } catch (_) {
      return false;
    }
  }
}
