import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/locale_provider.dart';
import 'router.dart';

class GlooApp extends ConsumerWidget {
  const GlooApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

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
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF3CAC), // Canlı pembe
          secondary: Color(0xFF39FF14), // Fosforlu yeşil
          tertiary: Color(0xFF8B5CF6), // Mor
          surface: Color(0xFF0A0A0F), // Derin siyah
        ),
        fontFamily: 'Syne',
      ),
      routerConfig: router,
    );
  }
}
