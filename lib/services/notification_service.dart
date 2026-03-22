/// Push notification altyapısı.
///
/// `firebase_messaging` paketi henüz eklenmemiş durumda.
/// Bu dosya bildirim senaryolarını ve interface'i tanımlar.
/// Paket eklendiğinde stub implementasyonları gerçek kodla değiştirilecek.
///
/// Bildirim senaryoları:
///   D1 — Streak reminder: Gün sonuna doğru (akşam 20:00) streak kırmamak için hatırlatma
///   D2 — Daily puzzle: Her gün 10:00'da günlük bulmaca hatırlatması
///   D3 — Comeback: 3 gün inaktif → "Seni özledik" bildirimi
library;

/// Bildirim türleri.
enum NotificationType {
  /// Günlük giriş serisini koruma hatırlatması.
  streakReminder,

  /// Günlük bulmaca hatırlatması.
  dailyPuzzle,

  /// Geri dönüş teşviki (3+ gün inaktif).
  comeback,
}

/// Push notification servisi interface'i.
///
/// `firebase_messaging` entegrasyonu hazır olduğunda bu interface'i
/// implemente eden sınıf oluşturulacak.
abstract class NotificationService {
  /// Servisi başlat (firebase_messaging + flutter_local_notifications kurulumu).
  Future<void> initialize();

  /// Bildirim izni iste. `true` dönerse izin verilmiş demektir.
  Future<bool> requestPermission();

  /// FCM token'ı döner (sunucuya kayıt için).
  Future<String?> getToken();

  /// Yerel zamanlı bildirim planla.
  Future<void> scheduleNotification({
    required NotificationType type,
    required DateTime scheduledAt,
    required String title,
    required String body,
  });

  /// Belirli tipteki planlanmış bildirimi iptal et.
  Future<void> cancelNotification(NotificationType type);

  /// Tüm planlanmış bildirimleri iptal et.
  Future<void> cancelAll();

  /// Streak hatırlatmasını planla (her gün 20:00).
  Future<void> scheduleStreakReminder({
    required String title,
    required String body,
  });

  /// Günlük bulmaca hatırlatmasını planla (her gün 10:00).
  Future<void> scheduleDailyPuzzleReminder({
    required String title,
    required String body,
  });

  /// Geri dönüş bildirimini planla (3 gün sonra).
  Future<void> scheduleComebackNotification({
    required String title,
    required String body,
  });
}

/// Stub implementasyon — firebase_messaging eklenene kadar no-op.
class StubNotificationService implements NotificationService {
  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<String?> getToken() async => null;

  @override
  Future<void> scheduleNotification({
    required NotificationType type,
    required DateTime scheduledAt,
    required String title,
    required String body,
  }) async {}

  @override
  Future<void> cancelNotification(NotificationType type) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> scheduleStreakReminder({
    required String title,
    required String body,
  }) async {}

  @override
  Future<void> scheduleDailyPuzzleReminder({
    required String title,
    required String body,
  }) async {}

  @override
  Future<void> scheduleComebackNotification({
    required String title,
    required String body,
  }) async {}
}
