import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../core/models/challenge.dart';
import 'supabase_client.dart';

class ChallengeRepository {
  bool get isConfigured =>
      SupabaseConfig.isConfigured && SupabaseConfig.isInitialized;
  String? get _userId => SupabaseConfig.currentUserId;

  /// Exponential backoff retry for critical mutations.
  Future<T?> _retry<T>(Future<T> Function() action,
      {int maxAttempts = 3}) async {
    for (var i = 0; i < maxAttempts; i++) {
      try {
        return await action();
      } catch (e) {
        if (i == maxAttempts - 1) rethrow;
        await Future<void>.delayed(
            Duration(milliseconds: 500 * (i + 1) + Random().nextInt(200)));
      }
    }
    return null;
  }

  // ── Mutations (Edge Functions) ────────────────────────────────────────

  /// Create a challenge. Returns `{challengeId, balance?}` or null.
  Future<Map<String, dynamic>?> createChallenge({
    String? recipientId,
    required String mode,
    required String challengeType,
    required int senderScore,
    required int wager,
    int? clientBalance,
  }) async {
    if (!isConfigured || _userId == null) return null;
    try {
      final response = await SupabaseConfig.client.functions.invoke(
        'create-challenge',
        body: {
          'recipientId': recipientId,
          'mode': mode,
          'challengeType': challengeType,
          'senderScore': senderScore,
          'wager': wager,
          if (clientBalance != null) 'clientBalance': clientBalance,
        },
      );
      if (response.status != 200) return null;
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ChallengeRepository.createChallenge error: $e');
      }
      return null;
    }
  }

  /// Accept a pending challenge. Returns `{challenge, balance?}` or null.
  Future<Map<String, dynamic>?> acceptChallenge({
    required String challengeId,
    int? clientBalance,
  }) async {
    if (!isConfigured || _userId == null) return null;
    try {
      final response = await SupabaseConfig.client.functions.invoke(
        'accept-challenge',
        body: {
          'challengeId': challengeId,
          if (clientBalance != null) 'clientBalance': clientBalance,
        },
      );
      if (response.status != 200) return null;
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ChallengeRepository.acceptChallenge error: $e');
      }
      return null;
    }
  }

  /// Decline a pending challenge. Returns true on success.
  Future<bool> declineChallenge(String challengeId) async {
    if (!isConfigured || _userId == null) return false;
    try {
      final response = await SupabaseConfig.client.functions.invoke(
        'decline-challenge',
        body: {'challengeId': challengeId},
      );
      return response.status == 200;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ChallengeRepository.declineChallenge error: $e');
      }
      return false;
    }
  }

  /// Cancel a challenge the user created. Returns true on success.
  Future<bool> cancelChallenge(String challengeId) async {
    if (!isConfigured || _userId == null) return false;
    try {
      final response = await SupabaseConfig.client.functions.invoke(
        'cancel-challenge',
        body: {'challengeId': challengeId},
      );
      return response.status == 200;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ChallengeRepository.cancelChallenge error: $e');
      }
      return false;
    }
  }

  /// Submit recipient's score. Uses [_retry] for reliability.
  /// Returns [ChallengeResult] with outcome and rewards on success.
  Future<ChallengeResult?> submitRecipientScore({
    required String challengeId,
    required int score,
  }) async {
    if (!isConfigured || _userId == null) return null;
    try {
      final response = await _retry(
        () => SupabaseConfig.client.functions.invoke(
          'submit-challenge-score',
          body: {
            'challengeId': challengeId,
            'recipientScore': score,
          },
        ),
      );
      if (response == null || response.status != 200) return null;
      return ChallengeResult.fromMap(response.data as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ChallengeRepository.submitRecipientScore error: $e');
      }
      return null;
    }
  }

  /// Claim an open challenge via deep link. Returns response data or null.
  Future<Map<String, dynamic>?> claimDeepLinkChallenge(
      String challengeId) async {
    if (!isConfigured || _userId == null) return null;
    try {
      final response = await SupabaseConfig.client.functions.invoke(
        'claim-deep-link-challenge',
        body: {'challengeId': challengeId},
      );
      if (response.status != 200) return null;
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ChallengeRepository.claimDeepLinkChallenge error: $e');
      }
      return null;
    }
  }

  // ── Read Queries (challenges_safe view) ───────────────────────────────

  /// Get pending challenges sent to the current user.
  Future<List<Challenge>> getPendingChallenges() async {
    if (!isConfigured) return [];
    final uid = _userId;
    if (uid == null) return [];
    try {
      final data = await SupabaseConfig.client
          .from('challenges_safe')
          .select()
          .eq('recipient_id', uid)
          .inFilter('status', ['pending', 'active'])
          .order('created_at', ascending: false);
      return (data as List)
          .map((e) => Challenge.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ChallengeRepository.getPendingChallenges error: $e');
      }
      return [];
    }
  }

  /// Get challenges sent by the current user (pending or active).
  Future<List<Challenge>> getSentChallenges() async {
    if (!isConfigured) return [];
    final uid = _userId;
    if (uid == null) return [];
    try {
      final data = await SupabaseConfig.client
          .from('challenges_safe')
          .select()
          .eq('sender_id', uid)
          .inFilter('status', ['pending', 'active'])
          .order('created_at', ascending: false);
      return (data as List)
          .map((e) => Challenge.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ChallengeRepository.getSentChallenges error: $e');
      }
      return [];
    }
  }

  /// Get completed/expired/declined/cancelled challenge history.
  Future<List<Challenge>> getChallengeHistory({int limit = 20}) async {
    if (!isConfigured) return [];
    final uid = _userId;
    if (uid == null) return [];
    try {
      final data = await SupabaseConfig.client
          .from('challenges_safe')
          .select()
          .or('sender_id.eq.$uid,recipient_id.eq.$uid')
          .inFilter(
              'status', ['completed', 'expired', 'declined', 'cancelled'])
          .order('created_at', ascending: false)
          .limit(limit);
      return (data as List)
          .map((e) => Challenge.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ChallengeRepository.getChallengeHistory error: $e');
      }
      return [];
    }
  }

  /// Get count of challenges created by the user today (for daily limit).
  Future<int> getDailyChallengeCount() async {
    if (!isConfigured) return 0;
    final uid = _userId;
    if (uid == null) return 0;
    try {
      final today = DateTime.now().toUtc();
      final startOfDay = DateTime.utc(today.year, today.month, today.day);
      final data = await SupabaseConfig.client
          .from('challenges_safe')
          .select('id')
          .eq('sender_id', uid)
          .gte('created_at', startOfDay.toIso8601String());
      return (data as List).length;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ChallengeRepository.getDailyChallengeCount error: $e');
      }
      return 0;
    }
  }
}
