import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/core/constants/color_constants.dart';
import 'package:gloo/core/l10n/app_strings.dart';
import 'package:gloo/core/l10n/strings_ar.dart';
import 'package:gloo/core/l10n/strings_de.dart';
import 'package:gloo/core/l10n/strings_en.dart';
import 'package:gloo/core/l10n/strings_es.dart';
import 'package:gloo/core/l10n/strings_fr.dart';
import 'package:gloo/core/l10n/strings_hi.dart';
import 'package:gloo/core/l10n/strings_ja.dart';
import 'package:gloo/core/l10n/strings_ko.dart';
import 'package:gloo/core/l10n/strings_pt.dart';
import 'package:gloo/core/l10n/strings_ru.dart';
import 'package:gloo/core/l10n/strings_tr.dart';
import 'package:gloo/core/l10n/strings_zh.dart';
import 'package:gloo/game/pvp/matchmaking.dart';

void main() {
  // All 12 concrete instances used throughout the tests.
  final allStrings = <String, AppStrings>{
    'en': StringsEn(),
    'tr': StringsTr(),
    'de': StringsDe(),
    'zh': StringsZh(),
    'ja': StringsJa(),
    'ko': StringsKo(),
    'ru': StringsRu(),
    'es': StringsEs(),
    'ar': StringsAr(),
    'fr': StringsFr(),
    'hi': StringsHi(),
    'pt': StringsPt(),
  };

  // ─── Non-empty core strings — all 12 languages ─────────────────────────

  group('Non-empty core strings', () {
    for (final entry in allStrings.entries) {
      final lang = entry.key;
      final s = entry.value;

      test('[$lang] scoreLabel is non-empty', () {
        expect(s.scoreLabel, isNotEmpty);
      });

      test('[$lang] gameOverTitle is non-empty', () {
        expect(s.gameOverTitle, isNotEmpty);
      });

      test('[$lang] settingsTitle is non-empty', () {
        expect(s.settingsTitle, isNotEmpty);
      });

      test('[$lang] leaderboardTitle is non-empty', () {
        expect(s.leaderboardTitle, isNotEmpty);
      });

      test('[$lang] shopTitle is non-empty', () {
        expect(s.shopTitle, isNotEmpty);
      });

      test('[$lang] pauseTitle is non-empty', () {
        expect(s.pauseTitle, isNotEmpty);
      });

      test('[$lang] onboardingStart is non-empty', () {
        expect(s.onboardingStart, isNotEmpty);
      });

      test('[$lang] modeClassicDesc is non-empty', () {
        expect(s.modeClassicDesc, isNotEmpty);
      });

      test('[$lang] collectionEmpty is non-empty', () {
        expect(s.collectionEmpty, isNotEmpty);
      });

      test('[$lang] tutorialStep1 is non-empty', () {
        expect(s.tutorialStep1, isNotEmpty);
      });
    }
  });

  // ─── RTL: Arabic strings are non-empty and differ from English ─────────

  group('RTL (Arabic) string correctness', () {
    final ar = StringsAr();
    final en = StringsEn();

    test('Arabic scoreLabel is non-empty', () {
      expect(ar.scoreLabel, isNotEmpty);
    });

    test('Arabic gameOverTitle differs from English', () {
      expect(ar.gameOverTitle, isNot(equals(en.gameOverTitle)));
    });

    test('Arabic pauseHome differs from English', () {
      expect(ar.pauseHome, isNot(equals(en.pauseHome)));
    });

    test('Arabic settingsTitle differs from English', () {
      expect(ar.settingsTitle, isNot(equals(en.settingsTitle)));
    });

    test('Arabic leaderboardTitle differs from English', () {
      expect(ar.leaderboardTitle, isNot(equals(en.leaderboardTitle)));
    });

    test('Arabic onboardingStep1Desc is non-empty', () {
      expect(ar.onboardingStep1Desc, isNotEmpty);
    });

    test('Arabic colorblindDialogMessage is non-empty', () {
      expect(ar.colorblindDialogMessage, isNotEmpty);
    });

    test('Arabic tutorialStep3 is non-empty', () {
      expect(ar.tutorialStep3, isNotEmpty);
    });
  });

  // ─── Long translation overflow: multi-sentence strings > 50 chars ──────

  group('Long translation strings have reasonable length', () {
    // onboardingStep1Desc and similar multi-sentence strings should be
    // non-trivially long (i.e., > 20 chars) and not absurdly long (< 400).
    for (final entry in allStrings.entries) {
      final lang = entry.key;
      final s = entry.value;

      test('[$lang] onboardingStep1Desc length is within reasonable bounds', () {
        final len = s.onboardingStep1Desc.length;
        expect(len, greaterThan(20),
            reason: 'onboardingStep1Desc must be descriptive (>20 chars)');
        expect(len, lessThan(400),
            reason: 'onboardingStep1Desc must not overflow (< 400 chars)');
      });

      test('[$lang] settingsDeleteConfirmMessage length is within bounds', () {
        final len = s.settingsDeleteConfirmMessage.length;
        expect(len, greaterThan(20));
        expect(len, lessThan(400));
      });
    }
  });

  // ─── String interpolation / method-based strings ────────────────────────

  group('Parameterised string methods return non-empty strings', () {
    for (final entry in allStrings.entries) {
      final lang = entry.key;
      final s = entry.value;

      test('[$lang] shareScoreCaption returns non-empty', () {
        final result = s.shareScoreCaption('Classic', '12345');
        expect(result, isNotEmpty);
      });

      test('[$lang] shareDailyCaption returns non-empty', () {
        final result = s.shareDailyCaption('2026-03-20', '9999');
        expect(result, isNotEmpty);
      });

      test('[$lang] shareComboCaption returns non-empty', () {
        final result = s.shareComboCaption('EPIC COMBO', 'Classic', '5000');
        expect(result, isNotEmpty);
      });
    }
  });

  // ─── shareScoreCaption embeds the arguments ──────────────────────────────

  group('shareScoreCaption contains the provided arguments', () {
    for (final entry in allStrings.entries) {
      final lang = entry.key;
      final s = entry.value;

      test('[$lang] shareScoreCaption contains score', () {
        final result = s.shareScoreCaption('Classic', '99999');
        expect(result, contains('99999'));
      });
    }
  });

  // ─── Color names — all 12 colors × 12 languages ─────────────────────────

  group('colorName returns non-empty for all colors and languages', () {
    final colors = GelColor.values;

    for (final entry in allStrings.entries) {
      final lang = entry.key;
      final s = entry.value;

      for (final color in colors) {
        test('[$lang] colorName(${color.name}) is non-empty', () {
          expect(s.colorName(color), isNotEmpty,
              reason: 'colorName(${color.name}) must not be empty in $lang');
        });
      }
    }
  });

  // ─── Color names differ between primary and synthesis colors ─────────────

  group('Color names are distinct within each language', () {
    for (final entry in allStrings.entries) {
      final lang = entry.key;
      final s = entry.value;

      test('[$lang] all 12 color names are unique', () {
        final names = GelColor.values.map(s.colorName).toList();
        final uniqueNames = names.toSet();
        expect(uniqueNames.length, equals(GelColor.values.length),
            reason: 'Duplicate color names found in $lang: $names');
      });
    }
  });

  // ─── ELO league names — 5 leagues × 12 languages ────────────────────────

  group('EloLeague.leagueName returns non-empty for all leagues and languages',
      () {
    final leagues = EloLeague.values;

    for (final entry in allStrings.entries) {
      final lang = entry.key;
      final s = entry.value;

      for (final league in leagues) {
        test('[$lang] leagueName(${league.name}) is non-empty', () {
          expect(league.leagueName(s), isNotEmpty,
              reason:
                  'leagueName(${league.name}) must not be empty in $lang');
        });
      }
    }
  });

  // ─── ELO league names are distinct within each language ──────────────────

  group('EloLeague names are distinct within each language', () {
    for (final entry in allStrings.entries) {
      final lang = entry.key;
      final s = entry.value;

      test('[$lang] all 5 league names are unique', () {
        final names = EloLeague.values.map((l) => l.leagueName(s)).toList();
        final uniqueNames = names.toSet();
        expect(uniqueNames.length, equals(EloLeague.values.length),
            reason: 'Duplicate league names found in $lang: $names');
      });
    }
  });

  // ─── forLocale factory returns correct type ───────────────────────────────

  group('AppStrings.forLocale factory', () {
    test('forLocale(ar) returns StringsAr', () {
      expect(AppStrings.forLocale(const Locale('ar')), isA<StringsAr>());
    });

    test('forLocale(zh) returns StringsZh', () {
      expect(AppStrings.forLocale(const Locale('zh')), isA<StringsZh>());
    });

    test('forLocale(ja) returns StringsJa', () {
      expect(AppStrings.forLocale(const Locale('ja')), isA<StringsJa>());
    });

    test('forLocale(hi) returns StringsHi', () {
      expect(AppStrings.forLocale(const Locale('hi')), isA<StringsHi>());
    });

    test('forLocale(ko) returns StringsKo', () {
      expect(AppStrings.forLocale(const Locale('ko')), isA<StringsKo>());
    });

    test('forLocale(ru) returns StringsRu', () {
      expect(AppStrings.forLocale(const Locale('ru')), isA<StringsRu>());
    });

    test('forLocale unsupported locale falls back to StringsEn', () {
      expect(
          AppStrings.forLocale(const Locale('sv')), isA<StringsEn>());
    });
  });

  // ─── Tutorial strings completeness ───────────────────────────────────────

  group('Tutorial strings are complete in all languages', () {
    for (final entry in allStrings.entries) {
      final lang = entry.key;
      final s = entry.value;

      test('[$lang] all tutorial strings are non-empty', () {
        expect(s.tutorialStep1, isNotEmpty);
        expect(s.tutorialStep2, isNotEmpty);
        expect(s.tutorialStep3, isNotEmpty);
        expect(s.tutorialGotIt, isNotEmpty);
      });
    }
  });

  // ─── Level section names completeness ────────────────────────────────────

  group('Level section names are complete in all languages', () {
    for (final entry in allStrings.entries) {
      final lang = entry.key;
      final s = entry.value;

      test('[$lang] all level section names are non-empty', () {
        expect(s.levelSectionGelValley, isNotEmpty);
        expect(s.levelSectionIcyFields, isNotEmpty);
        expect(s.levelSectionStoneMaze, isNotEmpty);
        expect(s.levelSectionColorGarden, isNotEmpty);
        expect(s.levelSectionDarkCellar, isNotEmpty);
      });
    }
  });
}
