import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/local/isar_schema.dart';
import '../data/local/local_repository.dart';

final localRepositoryProvider = FutureProvider<LocalRepository>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return LocalRepository(prefs);
});

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final repo = await ref.watch(localRepositoryProvider.future);
  return repo.getProfile();
});

final highScoreProvider =
    FutureProvider.family<int, String>((ref, mode) async {
  final repo = await ref.watch(localRepositoryProvider.future);
  return repo.getHighScore(mode);
});

final streakProvider = FutureProvider<int>((ref) async {
  final repo = await ref.watch(localRepositoryProvider.future);
  return repo.checkAndUpdateStreak();
});

final eloProvider = FutureProvider<int>((ref) async {
  final repo = await ref.watch(localRepositoryProvider.future);
  return repo.getElo();
});
