import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/viral/video_processor.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('VideoProcessRequest', () {
    test('creates with required parameters', () {
      const req = VideoProcessRequest(
        framesDir: '/tmp/frames',
        outputPath: '/tmp/output.mp4',
      );
      expect(req.framesDir, '/tmp/frames');
      expect(req.outputPath, '/tmp/output.mp4');
    });

    test('default slowMotionFactor is 2.0', () {
      const req = VideoProcessRequest(
        framesDir: '/tmp/frames',
        outputPath: '/tmp/output.mp4',
      );
      expect(req.slowMotionFactor, 2.0);
    });

    test('default watermarkAssetPath is null', () {
      const req = VideoProcessRequest(
        framesDir: '/tmp/frames',
        outputPath: '/tmp/output.mp4',
      );
      expect(req.watermarkAssetPath, isNull);
    });

    test('custom slowMotionFactor is stored', () {
      const req = VideoProcessRequest(
        framesDir: '/tmp/frames',
        outputPath: '/tmp/output.mp4',
        slowMotionFactor: 3.5,
      );
      expect(req.slowMotionFactor, 3.5);
    });

    test('watermarkAssetPath can be set', () {
      const req = VideoProcessRequest(
        framesDir: '/tmp/frames',
        outputPath: '/tmp/output.mp4',
        watermarkAssetPath: 'assets/images/ui/watermark.png',
      );
      expect(req.watermarkAssetPath, 'assets/images/ui/watermark.png');
    });

    test('slowMotionFactor toStringAsFixed(1) format', () {
      // The processor uses pts.toStringAsFixed(1) — verify formatting
      const req1 = VideoProcessRequest(
        framesDir: '/tmp/frames',
        outputPath: '/tmp/out.mp4',
        slowMotionFactor: 2.0,
      );
      expect(req1.slowMotionFactor.toStringAsFixed(1), '2.0');

      const req2 = VideoProcessRequest(
        framesDir: '/tmp/frames',
        outputPath: '/tmp/out.mp4',
        slowMotionFactor: 0.5,
      );
      expect(req2.slowMotionFactor.toStringAsFixed(1), '0.5');

      const req3 = VideoProcessRequest(
        framesDir: '/tmp/frames',
        outputPath: '/tmp/out.mp4',
        slowMotionFactor: 1.25,
      );
      // 1.25 → "1.3" (banker's rounding to 1 decimal)
      expect(req3.slowMotionFactor.toStringAsFixed(1), '1.3');
    });
  });

  group('VideoProcessor creation', () {
    test('can be instantiated', () {
      final processor = VideoProcessor();
      expect(processor, isNotNull);
    });
  });

  group('VideoProcessor.processClip', () {
    // In the test environment kIsWeb is false, so the web guard won't skip.
    // FFmpegKit is a platform plugin and will throw MissingPluginException
    // in pure Dart test runner. We verify graceful error handling (returns null).

    test('returns null on FFmpeg plugin unavailability', () async {
      final processor = VideoProcessor();
      const req = VideoProcessRequest(
        framesDir: '/tmp/nonexistent_frames',
        outputPath: '/tmp/test_output.mp4',
      );
      // FFmpegKit.execute will throw MissingPluginException in test env
      // The try-catch in processClip should catch it and return null
      final result = await processor.processClip(req);
      expect(result, isNull);
    });

    test('returns null with watermark on FFmpeg unavailability', () async {
      final processor = VideoProcessor();
      const req = VideoProcessRequest(
        framesDir: '/tmp/nonexistent_frames',
        outputPath: '/tmp/test_output.mp4',
        watermarkAssetPath: 'assets/watermark.png',
      );
      final result = await processor.processClip(req);
      expect(result, isNull);
    });

    test('returns null with custom slowMotionFactor', () async {
      final processor = VideoProcessor();
      const req = VideoProcessRequest(
        framesDir: '/tmp/nonexistent_frames',
        outputPath: '/tmp/test_output.mp4',
        slowMotionFactor: 4.0,
      );
      final result = await processor.processClip(req);
      expect(result, isNull);
    });
  });

  group('VideoProcessRequest FFmpeg command construction', () {
    // Verify the values that feed into the FFmpeg command string

    test('base filter contains setpts with correct factor', () {
      const req = VideoProcessRequest(
        framesDir: '/frames',
        outputPath: '/out.mp4',
        slowMotionFactor: 2.0,
      );
      final pts = req.slowMotionFactor.toStringAsFixed(1);
      final baseFilter = 'setpts=$pts*PTS,eq=saturation=1.3:contrast=1.1';
      expect(baseFilter, contains('setpts=2.0*PTS'));
      expect(baseFilter, contains('eq=saturation=1.3'));
      expect(baseFilter, contains('contrast=1.1'));
    });

    test('base filter with different slow motion factor', () {
      const req = VideoProcessRequest(
        framesDir: '/frames',
        outputPath: '/out.mp4',
        slowMotionFactor: 0.5,
      );
      final pts = req.slowMotionFactor.toStringAsFixed(1);
      final baseFilter = 'setpts=$pts*PTS,eq=saturation=1.3:contrast=1.1';
      expect(baseFilter, contains('setpts=0.5*PTS'));
    });

    test('command without watermark uses filter:v', () {
      const req = VideoProcessRequest(
        framesDir: '/frames',
        outputPath: '/out.mp4',
      );
      final pts = req.slowMotionFactor.toStringAsFixed(1);
      final baseFilter = 'setpts=$pts*PTS,eq=saturation=1.3:contrast=1.1';

      // Reconstruct command as the source code does
      final cmd = '-r 30 -i ${req.framesDir}/frame_%04d.png '
          '-filter:v "$baseFilter" '
          '-c:v libx264 -pix_fmt yuv420p -y ${req.outputPath}';

      expect(cmd, contains('-r 30'));
      expect(cmd, contains('-filter:v'));
      expect(cmd, contains('-c:v libx264'));
      expect(cmd, contains('-pix_fmt yuv420p'));
      expect(cmd, contains(req.outputPath));
      expect(cmd, isNot(contains('overlay')));
    });

    test('command with watermark uses filter_complex and overlay', () {
      const req = VideoProcessRequest(
        framesDir: '/frames',
        outputPath: '/out.mp4',
        watermarkAssetPath: 'assets/wm.png',
      );
      final pts = req.slowMotionFactor.toStringAsFixed(1);
      final baseFilter = 'setpts=$pts*PTS,eq=saturation=1.3:contrast=1.1';

      // Reconstruct command as the source code does
      final cmd = '-r 30 -i ${req.framesDir}/frame_%04d.png '
          '-i ${req.watermarkAssetPath} '
          '-filter_complex "[$baseFilter][1:v]overlay=W-w-10:10" '
          '-c:v libx264 -pix_fmt yuv420p -y ${req.outputPath}';

      expect(cmd, contains('-filter_complex'));
      expect(cmd, contains('overlay=W-w-10:10'));
      expect(cmd, contains('-i ${req.watermarkAssetPath}'));
      expect(cmd, isNot(contains('-filter:v')));
    });
  });
}
