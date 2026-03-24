import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase istemci konfigürasyonu.
///
/// Üretim ortamı için [supabaseUrl] ve [supabaseAnonKey] değerleri
/// Supabase dashboard'dan alınıp buraya yazılmalıdır.
///
/// RLS politikaları GDD 4.8'de tanımlanan SQL ile Supabase dashboard'da
/// veya migration dosyaları ile uygulanmalıdır.
class SupabaseConfig {
  SupabaseConfig._();

  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Supabase key'leri --dart-define ile verilmis mi?
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Supabase runtime'da initialize edilmis mi?
  static bool _initialized = false;

  /// Runtime'da initialize edilip edilmedigini dondurur.
  static bool get isInitialized => _initialized;

  static SupabaseClient get client => Supabase.instance.client;

  /// `main()` içinde çağrılır — Firebase init'ten sonra.
  static Future<void> initialize() async {
    if (!isConfigured) {
      if (kDebugMode)
        debugPrint('SupabaseConfig: placeholder credentials — skipping init');
      return;
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    _initialized = true;
    if (kDebugMode) debugPrint('SupabaseConfig: initialized');

    // Anonim oturum aç (GDPR uyumlu — kişisel veri tutulmaz)
    final session = client.auth.currentSession;
    if (session == null) {
      await client.auth.signInAnonymously();
      if (kDebugMode) debugPrint('SupabaseConfig: anonymous session created');

      // Yeni anonim kullanici icin profil olustur (friend_code collision retry)
      final uid = currentUserId;
      if (uid != null) {
        for (int attempt = 0; attempt < 5; attempt++) {
          try {
            await client.from('profiles').upsert({
              'id': uid,
              'username': 'Player_${uid.substring(0, 6)}',
              'friend_code': _generateFriendCode(),
            });
            if (kDebugMode)
              debugPrint('SupabaseConfig: profile created for $uid');
            break;
          } catch (e) {
            if (attempt == 4) {
              if (kDebugMode)
                debugPrint('SupabaseConfig: profile creation failed after 5 attempts ($e)');
            }
          }
        }
      }
    }
  }

  /// Geçerli kullanıcı ID'si (anonim veya kayıtlı).
  static String? get currentUserId {
    if (!isConfigured || !_initialized) return null;
    return client.auth.currentUser?.id;
  }

  static String _generateFriendCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no I/O/0/1 confusion
    final rng = Random();
    final code = List.generate(4, (_) => chars[rng.nextInt(chars.length)]).join();
    return 'GLO-$code';
  }
}
