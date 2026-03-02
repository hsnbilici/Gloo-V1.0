import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloo/game/meta/resource_manager.dart';
import 'package:gloo/features/quests/quest_overlay.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'onboarding_done': true,
      'analytics_enabled': true,
    });
  });

  Widget buildApp() {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: SizedBox.expand(
            child: DraggableScrollableSheet(
              builder: (context, controller) => const QuestOverlay(),
            ),
          ),
        ),
      ),
    );
  }

  // ─── _pickQuests deterministik secim (saf Dart testi) ───────────────────────

  group('Quest selection determinism', () {
    List<Quest> pickQuests(List<Quest> pool, int count, int seed) {
      final shuffled = List<Quest>.from(pool);
      for (int i = shuffled.length - 1; i > 0; i--) {
        final j = (seed * 31 + i * 17) % (i + 1);
        final temp = shuffled[i];
        shuffled[i] = shuffled[j];
        shuffled[j] = temp;
      }
      return shuffled.take(count).toList();
    }

    test('daily: seed produces exactly 3 quests from pool', () {
      final result = pickQuests(kDailyQuestPool, 3, 42);
      expect(result.length, 3);
    });

    test('weekly: seed produces exactly 5 quests from pool', () {
      final result = pickQuests(kWeeklyQuestPool, 5, 10);
      expect(result.length, 5);
    });

    test('same seed returns same daily quests (deterministic)', () {
      const seed = 100;
      final first = pickQuests(kDailyQuestPool, 3, seed);
      final second = pickQuests(kDailyQuestPool, 3, seed);
      for (int i = 0; i < first.length; i++) {
        expect(first[i].type, second[i].type);
        expect(first[i].description, second[i].description);
      }
    });

    test('same seed returns same weekly quests (deterministic)', () {
      const seed = 7;
      final first = pickQuests(kWeeklyQuestPool, 5, seed);
      final second = pickQuests(kWeeklyQuestPool, 5, seed);
      for (int i = 0; i < first.length; i++) {
        expect(first[i].type, second[i].type);
        expect(first[i].description, second[i].description);
      }
    });

    test('different seeds produce different quest orders', () {
      final a = pickQuests(kDailyQuestPool, 3, 1);
      final b = pickQuests(kDailyQuestPool, 3, 999);
      final aTypes = a.map((q) => q.type).toList();
      final bTypes = b.map((q) => q.type).toList();
      final allSame = List.generate(
        aTypes.length,
        (i) => aTypes[i] == bTypes[i],
      ).every((x) => x);
      expect(allSame, isFalse);
    });

    test('selected quests are always from the pool', () {
      for (int seed = 0; seed < 50; seed++) {
        final selected = pickQuests(kDailyQuestPool, 3, seed);
        for (final q in selected) {
          expect(kDailyQuestPool.contains(q), isTrue,
              reason: 'seed $seed produced quest not in pool');
        }
      }
    });
  });

  // ─── Quest ve QuestType veri modeli ─────────────────────────────────────────

  group('Quest data model', () {
    test('kDailyQuestPool has at least 3 quests', () {
      expect(kDailyQuestPool.length, greaterThanOrEqualTo(3));
    });

    test('kWeeklyQuestPool has at least 5 quests', () {
      expect(kWeeklyQuestPool.length, greaterThanOrEqualTo(5));
    });

    test('all daily quests have isWeekly == false', () {
      for (final q in kDailyQuestPool) {
        expect(q.isWeekly, isFalse,
            reason: '${q.description} should not be weekly');
      }
    });

    test('all weekly quests have isWeekly == true', () {
      for (final q in kWeeklyQuestPool) {
        expect(q.isWeekly, isTrue, reason: '${q.description} should be weekly');
      }
    });

    test('all quests have positive XP and gel rewards', () {
      for (final q in [...kDailyQuestPool, ...kWeeklyQuestPool]) {
        expect(q.xpReward, greaterThan(0),
            reason: '${q.description} should have positive XP');
        expect(q.gelReward, greaterThan(0),
            reason: '${q.description} should have positive gel');
      }
    });

    test('all quests have valid QuestType', () {
      final allTypes = QuestType.values.toSet();
      for (final q in [...kDailyQuestPool, ...kWeeklyQuestPool]) {
        expect(allTypes.contains(q.type), isTrue,
            reason: '${q.description} has invalid type');
      }
    });

    test('all quests have non-empty description', () {
      for (final q in [...kDailyQuestPool, ...kWeeklyQuestPool]) {
        expect(q.description.isNotEmpty, isTrue);
      }
    });

    test('all quests have positive target count', () {
      for (final q in [...kDailyQuestPool, ...kWeeklyQuestPool]) {
        expect(q.targetCount, greaterThan(0),
            reason: '${q.description} should have positive target');
      }
    });

    test('weekly rewards are larger than daily rewards', () {
      final dailyMaxXp = kDailyQuestPool
          .map((q) => q.xpReward)
          .reduce((a, b) => a > b ? a : b);
      final weeklyMinXp = kWeeklyQuestPool
          .map((q) => q.xpReward)
          .reduce((a, b) => a < b ? a : b);
      expect(weeklyMinXp, greaterThan(dailyMaxXp));
    });
  });

  // ─── Widget testleri ────────────────────────────────────────────────────────
  // QuestOverlay uses flutter_animate (non-settling timers) and async init
  // with RemoteRepository (Supabase not available in tests).
  // We test the initial rendering and loading state, then dispose promptly.

  group('QuestOverlay widget', () {
    // flutter_animate creates timers that persist after widget disposal.
    // We pump(Duration.zero) after replacing the widget to let those fire.
    Future<void> cleanUp(WidgetTester tester) async {
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 5));
    }

    testWidgets('renders QuestOverlay in the widget tree', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();
      expect(find.byType(QuestOverlay), findsOneWidget);
      await cleanUp(tester);
    });

    testWidgets('shows daily quests section after initialization',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();
      // After initialization, _loaded becomes true and quest list renders.
      // The GUNLUK section header should be visible.
      expect(find.text('GUNLUK'), findsOneWidget);
      await cleanUp(tester);
    });

    testWidgets('shows GOREVLER title text on initial frame', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();
      // Title is always rendered (outside the _loaded branch)
      expect(find.text('GOREVLER'), findsOneWidget);
      await cleanUp(tester);
    });

    testWidgets('shows XP Kazan badge on initial frame', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();
      expect(find.text('XP Kazan'), findsOneWidget);
      await cleanUp(tester);
    });

    testWidgets('contains DraggableScrollableSheet', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();
      expect(find.byType(DraggableScrollableSheet), findsWidgets);
      await cleanUp(tester);
    });
  });
}
