import 'package:flutter/material.dart';

enum Breakpoint {
  phone,
  tablet,
  desktop;

  static Breakpoint fromWidth(double width) {
    if (width >= 1024) return desktop;
    if (width >= 600) return tablet;
    return phone;
  }
}

int responsiveColumns(
  double width, {
  required int phone,
  required int tablet,
  required int desktop,
}) {
  return switch (Breakpoint.fromWidth(width)) {
    Breakpoint.phone => phone,
    Breakpoint.tablet => tablet,
    Breakpoint.desktop => desktop,
  };
}

double responsiveHPadding(double width) {
  return switch (Breakpoint.fromWidth(width)) {
    Breakpoint.phone => 24.0,
    Breakpoint.tablet => 40.0,
    Breakpoint.desktop => 64.0,
  };
}

double responsiveMaxWidth(double width) {
  return switch (Breakpoint.fromWidth(width)) {
    Breakpoint.phone => double.infinity,
    Breakpoint.tablet => 720.0,
    Breakpoint.desktop => 960.0,
  };
}

/// Wrapper that constrains content width on tablet/desktop
/// and applies responsive horizontal padding.
class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({
    super.key,
    required this.body,
    this.backgroundColor,
    this.appBar,
  });

  final Widget body;
  final Color? backgroundColor;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final bp = Breakpoint.fromWidth(width);

    if (bp == Breakpoint.phone) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: appBar,
        body: body,
      );
    }

    final maxW = responsiveMaxWidth(width);
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: body,
        ),
      ),
    );
  }
}
