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
