import 'package:flutter/cupertino.dart';

class AppTheme {
  const AppTheme._();

  /// Brand green, lighter in dark mode for contrast.
  static const brand = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF1F7A4D),
    darkColor: Color(0xFF4CC38A),
  );

  static CupertinoThemeData get theme => const CupertinoThemeData(
    primaryColor: brand,
    applyThemeToAll: true,
  );
}
