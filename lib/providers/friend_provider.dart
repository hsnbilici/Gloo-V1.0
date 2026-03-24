import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/remote/friend_repository.dart';

final friendRepositoryProvider =
    Provider<FriendRepository>((ref) => FriendRepository());

final friendsProvider = FutureProvider<FriendsState>((ref) async {
  final repo = ref.read(friendRepositoryProvider);
  if (!repo.isConfigured) return const FriendsState.empty();

  final results = await Future.wait([
    repo.getFollowing(),
    repo.getFollowers(),
    repo.getMyFriendCode(),
  ]);

  return FriendsState(
    following: results[0] as List<FriendInfo>,
    followers: results[1] as List<FriendInfo>,
    myCode: (results[2] as String?) ?? '',
  );
});

class FriendsState {
  const FriendsState({
    required this.following,
    required this.followers,
    required this.myCode,
  });

  const FriendsState.empty()
      : following = const [],
        followers = const [],
        myCode = '';

  final List<FriendInfo> following;
  final List<FriendInfo> followers;
  final String myCode;

  /// Karşılıklı follow — gerçek arkadaşlar.
  List<FriendInfo> get mutualFriends =>
      following.where((f) => f.isMutual).toList();

  /// Tek yönlü: ben takip ediyorum, onlar etmiyor.
  List<FriendInfo> get onlyFollowing =>
      following.where((f) => !f.isMutual).toList();

  /// Beni takip eden ama benim takip etmediğim kişiler.
  List<FriendInfo> get onlyFollowers {
    final followingIds = following.map((f) => f.userId).toSet();
    return followers.where((f) => !followingIds.contains(f.userId)).toList();
  }

  int get totalFollowing => following.length;
  int get totalFollowers => followers.length;
}
