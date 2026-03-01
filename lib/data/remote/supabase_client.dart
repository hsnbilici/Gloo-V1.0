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

  static const supabaseUrl = 'https://lcumiadyvwharxhrbtkm.supabase.co';
  static const supabaseAnonKey =
      'sb_publishable_p1_zSGuHlfDtwZQWp0tMSg_SidU7y9K';

  /// Placeholder degerler doldurulan gercek projeden mi yoksa sahte mi?
  static bool get isConfigured =>
      supabaseUrl != 'https://YOUR_PROJECT.supabase.co' &&
      supabaseAnonKey != 'YOUR_ANON_KEY';

  /// Supabase runtime'da initialize edilmis mi?
  static bool _initialized = false;

  /// Runtime'da initialize edilip edilmedigini dondurur.
  static bool get isInitialized => _initialized;

  static SupabaseClient get client => Supabase.instance.client;

  /// `main()` içinde çağrılır — Firebase init'ten sonra.
  static Future<void> initialize() async {
    if (!isConfigured) {
      if (kDebugMode) debugPrint('SupabaseConfig: placeholder credentials — skipping init');
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

      // Yeni anonim kullanici icin profil olustur
      final uid = currentUserId;
      if (uid != null) {
        try {
          await client.from('profiles').upsert({
            'id': uid,
            'username': 'Player_${uid.substring(0, 6)}',
          });
          if (kDebugMode) debugPrint('SupabaseConfig: profile created for $uid');
        } catch (e) {
          if (kDebugMode) debugPrint('SupabaseConfig: profile creation failed ($e)');
        }
      }
    }
  }

  /// Geçerli kullanıcı ID'si (anonim veya kayıtlı).
  static String? get currentUserId {
    if (!isConfigured || !_initialized) return null;
    return client.auth.currentUser?.id;
  }
}
