import 'package:flutter_test/flutter_test.dart';
import 'package:cultivatec_flutter/data/models/level_system.dart';

void main() {
  group('levelThresholds', () {
    test('are ordered by level with no gaps', () {
      for (var i = 0; i < levelThresholds.length; i++) {
        expect(levelThresholds[i].level, i + 1, reason: 'Los niveles deben ir de 1 a N sin saltos');
      }
    });

    test('require strictly increasing XP', () {
      for (var i = 1; i < levelThresholds.length; i++) {
        expect(levelThresholds[i].xp, greaterThan(levelThresholds[i - 1].xp),
            reason: 'El XP del nivel ${levelThresholds[i].level} debe superar al anterior');
      }
    });

    test('have unique titles', () {
      final titles = levelThresholds.map((t) => t.title).toSet();
      expect(titles.length, levelThresholds.length);
    });
  });

  group('calculateLevel', () {
    test('starts a brand new player at level 1', () {
      final info = calculateLevel(0);
      expect(info.level, 1);
      expect(info.xpInLevel, 0);
      expect(info.isMaxLevel, isFalse);
      expect(info.progress, 0.0);
    });

    test('clamps negative XP to level 1', () {
      expect(calculateLevel(-50).level, 1);
    });

    test('promotes exactly at the threshold', () {
      final second = levelThresholds[1];
      expect(calculateLevel(second.xp - 1).level, 1);
      expect(calculateLevel(second.xp).level, second.level);
    });

    test('reports progress within the current level', () {
      final second = levelThresholds[1];
      final info = calculateLevel(second.xp ~/ 2);
      expect(info.level, 1);
      expect(info.progress, greaterThan(0.0));
      expect(info.progress, lessThan(1.0));
    });

    test('keeps progress inside 0..1 for every threshold', () {
      for (final t in levelThresholds) {
        final info = calculateLevel(t.xp);
        expect(info.progress, inInclusiveRange(0.0, 1.0));
      }
    });

    test('caps at the last level instead of overflowing', () {
      final last = levelThresholds.last;
      final info = calculateLevel(last.xp * 10);
      expect(info.level, last.level);
      expect(info.isMaxLevel, isTrue);
      expect(info.progress, 1.0);
      expect(info.xpNeeded, 0);
    });
  });
}
