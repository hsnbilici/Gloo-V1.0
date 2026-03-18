import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/game/pvp/matchmaking.dart';
import 'package:gloo/core/l10n/strings_en.dart';
import 'package:gloo/core/l10n/strings_tr.dart';

void main() {
  group('EloLeague l10n', () {
    test('English league names', () {
      final l = StringsEn();
      expect(EloLeague.bronze.leagueName(l), 'Bronze');
      expect(EloLeague.silver.leagueName(l), 'Silver');
      expect(EloLeague.gold.leagueName(l), 'Gold');
      expect(EloLeague.diamond.leagueName(l), 'Diamond');
      expect(EloLeague.glooMaster.leagueName(l), 'Gloo Master');
    });

    test('Turkish league names', () {
      final l = StringsTr();
      expect(EloLeague.bronze.leagueName(l), 'Bronz');
      expect(EloLeague.diamond.leagueName(l), 'Elmas');
    });

    test('all leagues have names', () {
      final l = StringsEn();
      for (final league in EloLeague.values) {
        expect(league.leagueName(l), isNotEmpty);
      }
    });
  });
}
