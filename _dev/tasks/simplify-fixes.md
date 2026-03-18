# Simplify Fix Planı

> Kaynak: Önceki inceleme raporundaki bulgular
> Tarih: 2026-03-17
> Kural: Sadece aksiyon alınabilir, test/build kırma riski düşük fix'ler

---

## YÜKSEK Öncelik

### F.1 — Shop ekranında copy-paste ürün tile'ları
**Dosya:** `lib/features/shop/shop_screen.dart:222-291`
**Sorun:** 5 adet `_ProductTile` widget'ı neredeyse aynı yapıda, sadece `icon`, `label`, `desc`, `productId`, `color`, `delay` farklı. Her biri ~12 satır.
**Çözüm:** Ürün metadata'sını bir listeye çıkar, `for` loop ile build et.
```dart
// Ürün metadata listesi
const _products = [
  (id: PurchaseService.kSoundCrystal, icon: Icons.graphic_eq_rounded, labelKey: 'shopSoundCrystal', ...),
  ...
];

// Build'de loop
for (final p in _products) {
  _ProductTile(icon: p.icon, label: l[p.labelKey], ...)
}
```
**Not:** `l10n` string erişimi getter olduğu için `labelKey` string olarak tutulamaz. Bunun yerine `List<({..., String Function(AppStrings) label, ...})>` veya build metodu içinde inline map kullanılmalı.
**Risk:** Düşük — UI davranışı değişmez, sadece yapısal refactoring.

---

## ORTA Öncelik

### F.2 — Timer tick'te gereksiz state rebuild
**Dosya:** `lib/features/game_screen/game_callbacks.dart:129-134`
**Sorun:** `onTimerTick` her saniye `updateRemainingSeconds(seconds)` çağırıyor, `copyWith` her seferinde çalışıyor (değer aynı olsa bile).
**Çözüm:** Notifier'a değer karşılaştırma ekle — `if (state.remainingSeconds == seconds) return;`
**Risk:** Çok düşük — gereksiz rebuild önlenir.

### F.3 — localRepository.future.then() tekrarı
**Dosya:** `lib/features/game_screen/game_callbacks.dart:174, 192, 201, 233`
**Sorun:** Her callback'te `ref.read(localRepositoryProvider.future).then((repo) {...})` yeni closure oluşturuyor.
**Çözüm:** `setupCallbacks()` başında repo'yu bir kez resolve et:
```dart
ref.read(localRepositoryProvider.future).then((repo) {
  _cachedRepo = repo;
});
```
Sonra callback'lerde doğrudan `_cachedRepo?.saveGelOzu(balance)` kullan.
**Risk:** Düşük — `SharedPreferences` zaten senkron init oluyor, `future` provider sadece async wrapper.

### F.4 — PvP broadcast callback'leri stream close sonrası temizlenmiyor
**Dosya:** `lib/data/remote/pvp_realtime_service.dart:250-312`
**Sorun:** `onBroadcast()` callback'leri `StreamController` kapatıldığında bile Supabase channel'da aktif kalıyor. `leaveDuelRoom` düzgün temizliyor ama erken disconnect'te leak olabilir.
**Çözüm:** `_closeDuelControllers()` çağrıldığında zaten `_duelControllers.clear()` yapılıyor ve `leaveDuelRoom` channel'ı `unsubscribe()` ediyor. Bu yeterli — channel unsubscribe olunca callback'ler de GC edilir. **False positive — fix gerekmez.**

### F.5 — N+1 rank sorgusu
**Dosya:** `lib/data/remote/remote_repository.dart:86-126`
**Sorun:** `getUserRank()` 2 sıralı Supabase sorgusu yapıyor (kullanıcı skoru + üstündeki sayı).
**Çözüm:** Supabase RPC fonksiyonu ile tek sorguda yapılabilir (`get_user_rank` RPC). Ancak bu **backend değişikliği** gerektirir (Supabase SQL function). Kod tarafı:
```dart
final result = await _client.rpc('get_user_rank', params: {'p_mode': mode, 'p_weekly': weekly});
```
**Risk:** Orta — Supabase migration gerektirir, sadece kod değişikliği yetmez.
**Karar:** Backend gerektirdiğinden şimdilik ertelenebilir. Leaderboard sık çağrılmıyorsa tolere edilir.

### F.6 — PvP metotlarında `isConfigured` guard tutarsızlığı
**Dosya:** `lib/data/remote/pvp_realtime_service.dart`
**Sorun:** `joinDuelRoom` (satır 178) guard var, ama `broadcastScore` (189), `sendObstacle` (202), `broadcastGameOver` (234) sadece `_duelChannel == null` kontrolü yapıyor.
**Çözüm:** `_duelChannel == null` zaten yeterli guard — eğer Supabase configured değilse `joinDuelRoom` dönecek ve `_duelChannel` null kalacak, diğer metotlar da early return yapacak. **False positive — fix gerekmez.**

---

## DÜŞÜK Öncelik

### F.7 — main.dart ErrorWidget'ta hardcoded renk
**Dosya:** `lib/main.dart:78`
**Sorun:** `Color(0xFF010C14)` yerine `kBgDark` sabiti kullanılmalı.
**Çözüm:** `import 'core/constants/color_constants.dart'` ekle, `Color(0xFF010C14)` → `kBgDark`.
**Risk:** Sıfır.

### F.8 — removeRange() O(n) hot path'te
**Dosya:** `lib/features/game_screen/game_callbacks.dart:82-84, 224-226`
**Sorun:** `burstCells.removeRange(0, len - 200)` her lineClear'da çalışıyor.
**Çözüm:** Pratik etki ihmal edilebilir — liste en fazla 200 eleman ve bu işlem nadir tetiklenir. **Ertelenir.**

---

## Uygulama Durumu

| Adım | Fix | Dosya | Durum |
|------|-----|-------|-------|
| 1 | F.7 | main.dart | ✅ Tamamlandı |
| 2 | F.2 | game_provider.dart | ✅ Tamamlandı |
| 3 | F.3 | game_callbacks.dart + game_screen.dart | ✅ Tamamlandı |
| 4 | F.1 | shop_screen.dart | ✅ Tamamlandı |
| 5 | F.5 | remote_repository.dart | ⏸ Ertelendi (backend gerekli) |

> **Doğrulama:** `flutter analyze`: 0 error/warning | `flutter test`: 1204/1204 passed

## Elenenler (False Positive / Ertelenen)

- F.4: Broadcast callback leak → channel unsubscribe ile zaten temizleniyor
- F.6: PvP guard tutarsızlığı → `_duelChannel == null` zaten yeterli
- F.8: removeRange O(n) → pratik etki yok, ertelendi
- AnalyticsService `_enabled` guard → tüm metotlarda zaten mevcut (yeniden kontrol edildi, tutarlı)
