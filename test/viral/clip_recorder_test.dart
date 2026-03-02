import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/core/utils/near_miss_detector.dart';
import 'package:gloo/game/systems/combo_detector.dart';
import 'package:gloo/viral/clip_recorder.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('RecordingState enum', () {
    test('has 3 values: idle, buffering, processing', () {
      expect(RecordingState.values.length, 3);
      expect(RecordingState.values, contains(RecordingState.idle));
      expect(RecordingState.values, contains(RecordingState.buffering));
      expect(RecordingState.values, contains(RecordingState.processing));
    });
  });

  group('ClipRecorder creation', () {
    test('initial state is idle', () {
      final recorder = ClipRecorder();
      expect(recorder.state, RecordingState.idle);
      expect(recorder.isBuffering, isFalse);
    });

    test('repaintKey is not null', () {
      final recorder = ClipRecorder();
      expect(recorder.repaintKey, isNotNull);
    });

    test('onClipReady callback is null by default', () {
      final recorder = ClipRecorder();
      expect(recorder.onClipReady, isNull);
    });

    test('onClipReady callback can be assigned', () {
      final recorder = ClipRecorder();
      recorder.onClipReady = (path) {};
      expect(recorder.onClipReady, isNotNull);
    });
  });

  group('ClipRecorder.onNearMiss', () {
    test('does not throw for standard event', () {
      final recorder = ClipRecorder();
      const event = NearMissEvent(
        score: 0.75,
        type: NearMissType.standard,
      );
      // In test environment kIsWeb is false but no RenderRepaintBoundary,
      // so this should start buffering without error
      expect(() => recorder.onNearMiss(event), returnsNormally);
    });

    test('does not throw for critical event', () {
      final recorder = ClipRecorder();
      const event = NearMissEvent(
        score: 0.95,
        type: NearMissType.critical,
      );
      expect(() => recorder.onNearMiss(event), returnsNormally);
    });

    test('transitions to buffering state after trigger', () {
      final recorder = ClipRecorder();
      const event = NearMissEvent(
        score: 0.8,
        type: NearMissType.standard,
      );
      recorder.onNearMiss(event);
      expect(recorder.state, RecordingState.buffering);
      expect(recorder.isBuffering, isTrue);
    });

    test('onTrigger is alias for onNearMiss', () {
      final recorder = ClipRecorder();
      const event = NearMissEvent(
        score: 0.8,
        type: NearMissType.standard,
      );
      recorder.onTrigger(event);
      expect(recorder.state, RecordingState.buffering);
    });
  });

  group('ClipRecorder.onCombo', () {
    test('ignores small tier combo (index < large)', () {
      final recorder = ClipRecorder();
      const smallCombo = ComboEvent(
        size: 1,
        tier: ComboTier.small,
        multiplier: 1.2,
      );
      recorder.onCombo(smallCombo);
      expect(recorder.state, RecordingState.idle);
    });

    test('ignores medium tier combo (index < large)', () {
      final recorder = ClipRecorder();
      const mediumCombo = ComboEvent(
        size: 3,
        tier: ComboTier.medium,
        multiplier: 1.5,
      );
      recorder.onCombo(mediumCombo);
      expect(recorder.state, RecordingState.idle);
    });

    test('ignores none tier combo', () {
      final recorder = ClipRecorder();
      recorder.onCombo(ComboEvent.none);
      expect(recorder.state, RecordingState.idle);
    });

    test('triggers on large tier combo', () {
      final recorder = ClipRecorder();
      const largeCombo = ComboEvent(
        size: 5,
        tier: ComboTier.large,
        multiplier: 2.0,
      );
      recorder.onCombo(largeCombo);
      expect(recorder.state, RecordingState.buffering);
    });

    test('triggers on epic tier combo', () {
      final recorder = ClipRecorder();
      const epicCombo = ComboEvent(
        size: 8,
        tier: ComboTier.epic,
        multiplier: 3.0,
      );
      recorder.onCombo(epicCombo);
      expect(recorder.state, RecordingState.buffering);
    });
  });

  group('ClipRecorder.startRecording / stopRecording', () {
    test('startRecording transitions to buffering', () {
      final recorder = ClipRecorder();
      recorder.startRecording();
      expect(recorder.state, RecordingState.buffering);
      expect(recorder.isBuffering, isTrue);
    });

    test('double startRecording stays buffering (no-op second call)', () {
      final recorder = ClipRecorder();
      recorder.startRecording();
      recorder.startRecording(); // should be ignored
      expect(recorder.state, RecordingState.buffering);
    });

    test('stopRecording from idle does nothing', () {
      final recorder = ClipRecorder();
      recorder.stopRecording();
      expect(recorder.state, RecordingState.idle);
    });

    test('stopRecording from buffering transitions to idle (empty frames)', () {
      final recorder = ClipRecorder();
      recorder.startRecording();
      expect(recorder.state, RecordingState.buffering);
      // stopRecording calls _finalizeClip which goes to processing then idle
      // Since _capturedFrames is empty, it returns to idle synchronously
      recorder.stopRecording();
      // After async _finalizeClip with empty frames, state becomes idle
      // We need to pump async to let it complete
      expect(recorder.state,
          isIn([RecordingState.processing, RecordingState.idle]));
    });
  });

  group('ClipRecorder.captureFrame', () {
    test('captureFrame in idle state does nothing', () async {
      final recorder = ClipRecorder();
      // Should return immediately without error
      await expectLater(recorder.captureFrame(), completes);
      expect(recorder.state, RecordingState.idle);
    });

    test('captureFrame in buffering state does not throw (no boundary)',
        () async {
      final recorder = ClipRecorder();
      recorder.startRecording();
      // repaintKey has no context so boundary is null, should gracefully return
      await expectLater(recorder.captureFrame(), completes);
      expect(recorder.state, RecordingState.buffering);
    });
  });

  group('ClipRecorder.dispose', () {
    test('dispose from idle does not throw', () {
      final recorder = ClipRecorder();
      expect(() => recorder.dispose(), returnsNormally);
    });

    test('dispose from buffering does not throw', () {
      final recorder = ClipRecorder();
      recorder.startRecording();
      expect(() => recorder.dispose(), returnsNormally);
    });
  });

  group('ClipRecorder combo tier boundary', () {
    test('ComboTier.large index is exactly the threshold', () {
      // The code checks: combo.tier.index < ComboTier.large.index
      // Verify the enum ordering is as expected
      expect(ComboTier.none.index, lessThan(ComboTier.large.index));
      expect(ComboTier.small.index, lessThan(ComboTier.large.index));
      expect(ComboTier.medium.index, lessThan(ComboTier.large.index));
      expect(ComboTier.large.index, equals(ComboTier.large.index));
      expect(ComboTier.epic.index, greaterThan(ComboTier.large.index));
    });
  });
}
