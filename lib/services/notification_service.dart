/// Push notification altyapısı.
///
/// Bildirim senaryoları:
///   D1 — Streak reminder: Gün sonuna doğru (akşam 20:00) streak kırmamak için hatırlatma
///   D2 — Daily puzzle: Her gün 10:00'da günlük bulmaca hatırlatması
///   D3 — Comeback: 3 gün inaktif → "Seni özledik" bildirimi
library;

import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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

  /// Kaynak temizliği.
  void dispose();
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

  @override
  void dispose() {}
}

/// Firebase Messaging + flutter_local_notifications tabanlı gerçek implementasyon.
class FirebaseNotificationService implements NotificationService {
  FirebaseNotificationService({this.onTokenChanged});

  /// Token değiştiğinde (ilk alım + yenileme) çağrılır.
  final void Function(String token)? onTokenChanged;

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
  StreamSubscription<String>? _tokenRefreshSub;

  @override
  Future<void> initialize() async {
    try {
      tz.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      await _local.initialize(
        const InitializationSettings(android: androidSettings, iOS: iosSettings),
      );

      const channel = AndroidNotificationChannel(
        'gloo_default',
        'Gloo Notifications',
        importance: Importance.defaultImportance,
      );
      await _local
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // CR.11-C3: Bildirim iznini iste
      await requestPermission();

      // CR.11-C2: İlk token'ı al ve sync et
      final token = await _fcm.getToken();
      if (token != null) onTokenChanged?.call(token);

      // Token yenilendiğinde sync et
      _tokenRefreshSub = _fcm.onTokenRefresh.listen((token) {
        onTokenChanged?.call(token);
      });

      if (kDebugMode) debugPrint('FirebaseNotificationService: initialized');
    } catch (e) {
      if (kDebugMode) debugPrint('FirebaseNotificationService: init error: $e');
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      if (kDebugMode) debugPrint('FirebaseNotificationService: permission error: $e');
      return false;
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      if (kDebugMode) debugPrint('FirebaseNotificationService: getToken error: $e');
      return null;
    }
  }

  @override
  Future<void> scheduleNotification({
    required NotificationType type,
    required DateTime scheduledAt,
    required String title,
    required String body,
  }) async {
    try {
      await _local.zonedSchedule(
        type.index,
        title,
        body,
        tz.TZDateTime.from(scheduledAt, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'gloo_default',
            'Gloo Notifications',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('FirebaseNotificationService: scheduleNotification error: $e');
    }
  }

  @override
  Future<void> cancelNotification(NotificationType type) async {
    try {
      await _local.cancel(type.index);
    } catch (e) {
      if (kDebugMode) debugPrint('FirebaseNotificationService: cancelNotification error: $e');
    }
  }

  @override
  Future<void> cancelAll() async {
    try {
      await _local.cancelAll();
    } catch (e) {
      if (kDebugMode) debugPrint('FirebaseNotificationService: cancelAll error: $e');
    }
  }

  @override
  Future<void> scheduleStreakReminder({
    required String title,
    required String body,
  }) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 20, 0);
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      await _local.zonedSchedule(
        NotificationType.streakReminder.index,
        title,
        body,
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'gloo_default',
            'Gloo Notifications',
            importance: Importance.defaultImportance,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('FirebaseNotificationService: streakReminder error: $e');
    }
  }

  @override
  Future<void> scheduleDailyPuzzleReminder({
    required String title,
    required String body,
  }) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 10, 0);
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      await _local.zonedSchedule(
        NotificationType.dailyPuzzle.index,
        title,
        body,
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'gloo_default',
            'Gloo Notifications',
            importance: Importance.defaultImportance,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('FirebaseNotificationService: dailyPuzzle error: $e');
    }
  }

  @override
  Future<void> scheduleComebackNotification({
    required String title,
    required String body,
  }) async {
    try {
      final scheduled = tz.TZDateTime.now(tz.local).add(const Duration(days: 3));
      await _local.zonedSchedule(
        NotificationType.comeback.index,
        title,
        body,
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'gloo_default',
            'Gloo Notifications',
            importance: Importance.defaultImportance,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('FirebaseNotificationService: comeback error: $e');
    }
  }

  /// Token yenileme subscription'ını temizler.
  @override
  void dispose() {
    _tokenRefreshSub?.cancel();
  }
}
