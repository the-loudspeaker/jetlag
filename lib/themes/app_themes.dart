import 'package:flutter/material.dart';

class AppThemes {
  AppThemes._();

  static final ThemeData light = _buildTheme(
    ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light),
  );

  static final ThemeData dark = _buildTheme(
    ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
  );

  static const List<String> mapTileSubdomains = ['a', 'b', 'c', 'd'];
  static const String mapTileFallbackUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String mapTileLightUrl =
      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png';
  static const String mapTileDarkUrl =
      'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png';
  static const String mapTileDarkLabelUrl =
      'https://{s}.basemaps.cartocdn.com/dark_only_labels/{z}/{x}/{y}{r}.png';

  static String tileLayerUrl(Brightness brightness) =>
      brightness == Brightness.dark ? mapTileDarkUrl : mapTileLightUrl;

  static ThemeData _buildTheme(ColorScheme scheme) {
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: scheme.surfaceTint,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerHighest,
        surfaceTintColor: scheme.surfaceTint,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: scheme.primary),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.surface,
        contentTextStyle: TextStyle(color: scheme.onSurface),
      ),
    );
  }
}
