import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/color_constants.dart';
import '../core/constants/color_constants_light.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import 'router.dart';

/// Body text stillerinde platform default fontunu kullanan TextTheme.
/// Display/heading stilleri ThemeData.fontFamily = 'Syne' üzerinden kalır.
/// bodyLarge / bodyMedium / bodySmall → fontFamily temizlenir → sistem fontu.
TextTheme _bodySystemFontTextTheme(Brightness brightness) {
  const bodyOverride = TextStyle(fontFamily: '');
  return ThemeData(brightness: brightness).textTheme.copyWith(
        bodyLarge: bodyOverride,
        bodyMedium: bodyOverride,
        bodySmall: bodyOverride,
      );
}

class GlooApp extends ConsumerWidget {
  const GlooApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Gloo',
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: const [
        Locale('tr'),
        Locale('en'),
        Locale('de'),
        Locale('zh'),
        Locale('ja'),
        Locale('ko'),
        Locale('ru'),
        Locale('es'),
        Locale('ar'),
        Locale('hi'),
        Locale('pt'),
        Locale('fr'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: kThemePrimary,
          secondary: kThemeSecondary,
          tertiary: kThemeTertiary,
          surface: kSurfaceLight,
        ),
        fontFamily: 'Syne',
        textTheme: _bodySystemFontTextTheme(Brightness.light),
        focusColor: kCyan.withValues(alpha: 0.3),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: kThemePrimary,
          secondary: kThemeSecondary,
          tertiary: kThemeTertiary,
          surface: kSurfaceBlack,
        ),
        fontFamily: 'Syne',
        textTheme: _bodySystemFontTextTheme(Brightness.dark),
        focusColor: kCyan.withValues(alpha: 0.3),
      ),
      routerConfig: router,
    );
  }
}
