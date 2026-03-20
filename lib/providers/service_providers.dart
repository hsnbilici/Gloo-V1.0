import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio/audio_manager.dart';
import '../audio/haptic_manager.dart';
import '../data/remote/pvp_realtime_service.dart';
import '../data/remote/remote_repository.dart';
import '../services/ad_manager.dart';
import '../services/analytics_service.dart';
import '../services/purchase_service.dart';

/// Singleton servislerin Riverpod provider sarmalayicilari.
///
/// Singleton pattern korunur (geriye uyumluluk). Provider'lar testlerde
/// override ile mock/fake inject edilmesini saglar.
final audioManagerProvider = Provider<AudioManager>((ref) => AudioManager());

final hapticManagerProvider = Provider<HapticManager>((ref) => HapticManager());

final adManagerProvider = Provider<AdManager>((ref) => AdManager());

final purchaseServiceProvider =
    Provider<PurchaseService>((ref) => PurchaseService());

final analyticsServiceProvider =
    Provider<AnalyticsService>((ref) => AnalyticsService());

final remoteRepositoryProvider =
    Provider<RemoteRepository>((ref) => RemoteRepository());

final pvpRealtimeServiceProvider = Provider<PvpRealtimeService>((ref) {
  final service = PvpRealtimeService();
  ref.onDispose(() => service.dispose());
  return service;
});
