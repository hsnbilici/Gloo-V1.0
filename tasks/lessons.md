# Lessons Learned

## 2026-03-02 — Xcode 26 CocoaPods Umbrella Header Uyumsuzlugu

### Hata
`flutter build ios --simulator --no-codesign` komutu Xcode 26.3 ile asagidaki fatal hatalarla basarisiz oldu:

```
Error (Xcode): double-quoted include "FPPSharePlusPlugin.h" in framework header, expected angle-bracketed instead
Error (Xcode): 'Flutter/Flutter.h' file not found
Error (Xcode): (fatal) could not build module 'share_plus'
```

Ikinci hata dalgasi:
```
Error: 'PromisesObjC/FBLPromise.h' file not found
Error: could not build module 'FBLPromises'
```

### Kok Neden
Xcode 26.3, framework umbrella header'larinda `#import "Header.h"` (double-quoted) kullanimini artik fatal error olarak degerlendiriyor. Onceki Xcode surumlerinde `CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = NO` ile susturulab iliyordu.

Etkilenen podlar:
- `share_plus 10.1.4`: umbrella header'da `#import "FPPSharePlusPlugin.h"` (double-quoted)
- `PromisesObjC 2.4.0`: umbrella header'da `#import "FBLPromise+All.h"` ve diger double-quoted import'lar + dogru framework adi `FBLPromises` (pod adi `PromisesObjC` degil)

### Cozum
`ios/Podfile`'a iki degisiklik:

1. `platform :ios, '16.0'` (eksik deployment target uyarisi giderildi)

2. `post_install` hook'ta umbrella header patch:
```ruby
installer.pod_targets.each do |pod_target|
  umbrella_path = File.join(
    File.dirname(installer.pods_project.path),
    'Target Support Files',
    pod_target.name,
    "#{pod_target.name}-umbrella.h"
  )
  next unless File.exist?(umbrella_path)
  content = File.read(umbrella_path)
  product_module = pod_target.product_module_name
  fixed = content.gsub(/#import "([^"]+\.h)"/) do
    header_name = $1
    "#import <#{product_module}/#{header_name}>"
  end
  File.write(umbrella_path, fixed) if fixed != content
end
```

`pod_target.product_module_name` kullanimi kritik: `PromisesObjC` pod'unun module adi `FBLPromises` oldugu icin `aggregate_target.name` yerine bu kullanilmali.

### Onleyici Kurallar
1. Yeni bir Xcode major versiyonuna gectikten sonra ILCE `flutter build ios --simulator` calistir. Eger CocoaPods podlar varsa umbrella header uyumluluklarini kontrol et.
2. `CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = NO` artik Xcode 26'da yeterli degil — umbrella header'lari gercekten patch etmek gerekiyor.
3. `post_install` hook'ta pod target'lara erisirken `installer.pod_targets` kullan, `installer.aggregate_targets` degil.
4. Pod module adi (framework adi) ile pod adi farkli olabilir: `pod_target.product_module_name` kullan.
5. `flutter build ios` komutu ic olarak `pod install` cagiriyor — bu yuzden manuel `pod install` ile fix yapilsa bile `flutter build` sirasinda tekrar uzerine yaziliyor. Fix'i her zaman `post_install` hook'ta uygula.
