import "package:flutter/material.dart";

///Klasa zarządzająca motywami aplikacji opartymi na Material Design.
///Umoźliwia tworzenie różnych schematów kolorów (light/dark)
class MaterialTheme {
  final TextTheme textTheme;

///Konstruktor klas MaterialTheme
  ///
  /// Przyjmuje jako parametr 'TextTheme'
  const MaterialTheme(this.textTheme);

  ///Tworzy schemat kolorów dla trybu jasnego.
  ///
  /// Zwraca instancję MaterialScheme z predefiniowanymi kolorami.
  static MaterialScheme lightScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(4281747097),
      surfaceTint: Color(4282931371),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4284246976),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(0xFF5C6BC0),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4289311461),
      onSecondaryContainer: Color(4280034896),
      tertiary: Color(4286001522),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4288763545),
      onTertiaryContainer: Color(4294967295),
      error: Color(0xFFE53935),
      onError: Color(4294967295),
      errorContainer: Color(4291968574),
      onErrorContainer: Color(4294967295),
      background: Color(4294703359),
      onBackground: Color(4279966497),
      surface: Color(0xFFE8EAF6),
      onSurface: Color(4280032028),
      surfaceVariant: Color(4293059055),
      onSurfaceVariant: Color(4282730065),
      //outline: Color(4285953667),
      outline: Color(0xFF9FA8DA),
      outlineVariant: Color(4291216851),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281413681),
      inverseOnSurface: Color(4294177008),
      inversePrimary: Color(0xFFC5CAE9),
      primaryFixed: Color(4292796671),
      onPrimaryFixed: Color(4278194267),
      primaryFixedDim: Color(4290429951),
      onPrimaryFixedVariant: Color(4281286546),
      secondaryFixed: Color(4292731391),
      onSecondaryFixed: Color(4279113794),
      secondaryFixedDim: Color(4290495735),
      onSecondaryFixedVariant: Color(4282074224),
      tertiaryFixed: Color(4294957045),
      onTertiaryFixed: Color(4281860151),
      tertiaryFixedDim: Color(4294945778),
      onTertiaryFixedVariant: Color(4285541227),
      surfaceDim: Color(4292663770),
      surfaceBright: Color(4294768889),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294374387),
      surfaceContainer: Color(4293979629),
      surfaceContainerHigh: Color(4293650408),
      surfaceContainerHighest: Color(4293255906),

    );
  }
  ///Tworzy instancję ThemeData dla trybu jasnego
  ///
  /// Używa schematu kolorów stworzonego przez lighthScheme()
  ThemeData light() {
    return theme(lightScheme().toColorScheme());
  }

  ///Tworzy schemat kolorów dla trybu jasnego ze średnim kontrastem.
  static MaterialScheme lightMediumContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(4281023374),
      surfaceTint: Color(4282931371),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4284246976),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4281811051),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4285100705),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4285212519),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4288763545),
      onTertiaryContainer: Color(4294967295),
      error: Color(4287300115),
      onError: Color(4294967295),
      errorContainer: Color(4291968574),
      onErrorContainer: Color(4294967295),
      background: Color(4294703359),
      onBackground: Color(4279966497),
      surface: Color(4294768889),
      onSurface: Color(4280032028),
      surfaceVariant: Color(4293059055),
      onSurfaceVariant: Color(4282466893),
      outline: Color(4284309098),
      outlineVariant: Color(4286151302),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281413681),
      inverseOnSurface: Color(4294177008),
      inversePrimary: Color(4290429951),
      primaryFixed: Color(4284444355),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4282799529),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4285100705),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4283455878),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4289026461),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4287185282),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292663770),
      surfaceBright: Color(4294768889),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294374387),
      surfaceContainer: Color(4293979629),
      surfaceContainerHigh: Color(4293650408),
      surfaceContainerHighest: Color(4293255906),
    );
  }
///Tworzy instancję ThemeData dla trybu jasnego ze średnim kontrastem.
  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme().toColorScheme());
  }

  ///Tworzy schemat kolorów dla trybu jasnego z wysokim kontrastem.
  static MaterialScheme lightHighContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(4278195564),
      surfaceTint: Color(4282931371),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4281023374),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4279574345),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4281811051),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4282581059),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4285212519),
      onTertiaryContainer: Color(4294967295),
      error: Color(4283236358),
      onError: Color(4294967295),
      errorContainer: Color(4287300115),
      onErrorContainer: Color(4294967295),
      background: Color(4294703359),
      onBackground: Color(4279966497),
      surface: Color(4294768889),
      onSurface: Color(4278190080),
      surfaceVariant: Color(4293059055),
      onSurfaceVariant: Color(4280427310),
      outline: Color(4282466893),
      outlineVariant: Color(4282466893),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281413681),
      inverseOnSurface: Color(4294967295),
      inversePrimary: Color(4293585663),
      primaryFixed: Color(4281023374),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4279247479),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4281811051),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4280298068),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4285212519),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4283501647),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292663770),
      surfaceBright: Color(4294768889),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4294374387),
      surfaceContainer: Color(4293979629),
      surfaceContainerHigh: Color(4293650408),
      surfaceContainerHighest: Color(4293255906),
    );
  }

  ///Tworzy instancję ThemeData dla trybu jasnego z wysokim kontrastem.
  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme().toColorScheme());
  }

  ///Tworzy schemat kolorów dla trybu ciemnego.
  static MaterialScheme darkScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(4290429951),
      surfaceTint: Color(4290429951),
      onPrimary: Color(4279576187),
      primaryContainer: Color(4283654838),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4290890494),
      onSecondary: Color(4280560984),
      secondaryContainer: Color(4288192978),
      onSecondaryContainer: Color(4278850622),
      tertiary: Color(4294945778),
      onTertiary: Color(4283765075),
      tertiaryContainer: Color(4288105872),
      onTertiaryContainer: Color(4294967295),
      error: Color(4294947758),
      onError: Color(4285005835),
      errorContainer: Color(4291968574),
      onErrorContainer: Color(4294967295),
      background: Color(4279374616),
      onBackground: Color(4293124585),
      surface: Color(4279440148),
      onSurface: Color(4293255906),
      surfaceVariant: Color(4282730065),
      onSurfaceVariant: Color(4291216851),
      outline: Color(4287598749),
      outlineVariant: Color(4282730065),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293255906),
      inverseOnSurface: Color(4281413681),
      inversePrimary: Color(4282931371),
      primaryFixed: Color(4292796671),
      onPrimaryFixed: Color(4278194267),
      primaryFixedDim: Color(4290429951),
      onPrimaryFixedVariant: Color(4281286546),
      secondaryFixed: Color(4292731391),
      onSecondaryFixed: Color(4279113794),
      secondaryFixedDim: Color(4290495735),
      onSecondaryFixedVariant: Color(4282074224),
      tertiaryFixed: Color(4294957045),
      onTertiaryFixed: Color(4281860151),
      tertiaryFixedDim: Color(4294945778),
      onTertiaryFixedVariant: Color(4285541227),
      surfaceDim: Color(4279440148),
      surfaceBright: Color(4282005818),
      surfaceContainerLowest: Color(4279111183),
      surfaceContainerLow: Color(4280032028),
      surfaceContainer: Color(4280295200),
      surfaceContainerHigh: Color(4280953386),
      surfaceContainerHighest: Color(4281676853),
    );
  }
///Tworzy instancję ThemeData dla trybu ciemnego.
  ThemeData dark() {
    return theme(darkScheme().toColorScheme());
  }

  ///Tworzy schemat kolorów dla trybu ciemnego ze średnim kontrastem.
  static MaterialScheme darkMediumContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(4290824191),
      surfaceTint: Color(4290429951),
      onPrimary: Color(4278193230),
      primaryContainer: Color(4286352354),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4290890494),
      onSecondary: Color(4278785086),
      secondaryContainer: Color(4288192978),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4294947570),
      onTertiary: Color(4281270319),
      tertiaryContainer: Color(4291130811),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294949300),
      onError: Color(4281794563),
      errorContainer: Color(4294531670),
      onErrorContainer: Color(4278190080),
      background: Color(4279374616),
      onBackground: Color(4293124585),
      surface: Color(4279440148),
      onSurface: Color(4294834938),
      surfaceVariant: Color(4282730065),
      onSurfaceVariant: Color(4291480023),
      outline: Color(4288848559),
      outlineVariant: Color(4286743183),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293255906),
      inverseOnSurface: Color(4280953386),
      inversePrimary: Color(4281417875),
      primaryFixed: Color(4292796671),
      onPrimaryFixed: Color(4278192449),
      primaryFixedDim: Color(4290429951),
      onPrimaryFixedVariant: Color(4280036736),
      secondaryFixed: Color(4292731391),
      onSecondaryFixed: Color(4278389815),
      secondaryFixedDim: Color(4290495735),
      onSecondaryFixedVariant: Color(4280955742),
      tertiaryFixed: Color(4294957045),
      onTertiaryFixed: Color(4280746022),
      tertiaryFixedDim: Color(4294945778),
      onTertiaryFixedVariant: Color(4284225881),
      surfaceDim: Color(4279440148),
      surfaceBright: Color(4282005818),
      surfaceContainerLowest: Color(4279111183),
      surfaceContainerLow: Color(4280032028),
      surfaceContainer: Color(4280295200),
      surfaceContainerHigh: Color(4280953386),
      surfaceContainerHighest: Color(4281676853),
    );
  }

  ///Tworzy instancję ThemeData dla trybu ciemnego ze średnim kontrastem.
  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme().toColorScheme());
  }

  ///Tworzy schemat kolorów dla trybu ciemnego z wysokim kontrastem.
  static MaterialScheme darkHighContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(4294834943),
      surfaceTint: Color(4290429951),
      onPrimary: Color(4278190080),
      primaryContainer: Color(4290824191),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4294769407),
      onSecondary: Color(4278190080),
      secondaryContainer: Color(4290758908),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4294965754),
      onTertiary: Color(4278190080),
      tertiaryContainer: Color(4294947570),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294965753),
      onError: Color(4278190080),
      errorContainer: Color(4294949300),
      onErrorContainer: Color(4278190080),
      background: Color(4279374616),
      onBackground: Color(4293124585),
      surface: Color(4279440148),
      onSurface: Color(4294967295),
      surfaceVariant: Color(4282730065),
      onSurfaceVariant: Color(4294834943),
      outline: Color(4291480023),
      outlineVariant: Color(4291480023),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293255906),
      inverseOnSurface: Color(4278190080),
      inversePrimary: Color(4278919028),
      primaryFixed: Color(4293191167),
      onPrimaryFixed: Color(4278190080),
      primaryFixedDim: Color(4290824191),
      onPrimaryFixedVariant: Color(4278193230),
      secondaryFixed: Color(4293125631),
      onSecondaryFixed: Color(4278190080),
      secondaryFixedDim: Color(4290758908),
      onSecondaryFixedVariant: Color(4278719036),
      tertiaryFixed: Color(4294958581),
      onTertiaryFixed: Color(4278190080),
      tertiaryFixedDim: Color(4294947570),
      onTertiaryFixedVariant: Color(4281270319),
      surfaceDim: Color(4279440148),
      surfaceBright: Color(4282005818),
      surfaceContainerLowest: Color(4279111183),
      surfaceContainerLow: Color(4280032028),
      surfaceContainer: Color(4280295200),
      surfaceContainerHigh: Color(4280953386),
      surfaceContainerHighest: Color(4281676853),
    );
  }

  ///Tworzy instancję ThemeData dla trybu ciemnego z wysokim kontrastem.
  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme().toColorScheme());
  }

  ///Tworzy obiekt 'ThemeData' na podstawie dostarczonego 'ColorScheme'
  ///
  /// Ustawia różne właściwości motywu, takie jak tekst, tło, kolor.
  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.background,
    canvasColor: colorScheme.surface,
  );

///Lista rozszerzonych kolorów potencjalnie używanych w aplikacji.
  List<ExtendedColor> get extendedColors => [
  ];
}
///Klasa reprezentująca schemat kolorów w Material Design.
///Zawiera wszystkie potrzebne kolory dla różnych elementów interfejsów.
class MaterialScheme {
  ///Konstruktor klasy 'MaterialScheme'
  ///
  /// Przyjmuje wszystkie potrzebne kolory jako parametry.
  const MaterialScheme({
    required this.brightness,
    required this.primary,
    required this.surfaceTint,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.background,
    required this.onBackground,
    required this.surface,
    required this.onSurface,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.shadow,
    required this.scrim,
    required this.inverseSurface,
    required this.inverseOnSurface,
    required this.inversePrimary,
    required this.primaryFixed,
    required this.onPrimaryFixed,
    required this.primaryFixedDim,
    required this.onPrimaryFixedVariant,
    required this.secondaryFixed,
    required this.onSecondaryFixed,
    required this.secondaryFixedDim,
    required this.onSecondaryFixedVariant,
    required this.tertiaryFixed,
    required this.onTertiaryFixed,
    required this.tertiaryFixedDim,
    required this.onTertiaryFixedVariant,
    required this.surfaceDim,
    required this.surfaceBright,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
  });

  final Brightness brightness;
  final Color primary;
  final Color surfaceTint;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color background;
  final Color onBackground;
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;
  final Color shadow;
  final Color scrim;
  final Color inverseSurface;
  final Color inverseOnSurface;
  final Color inversePrimary;
  final Color primaryFixed;
  final Color onPrimaryFixed;
  final Color primaryFixedDim;
  final Color onPrimaryFixedVariant;
  final Color secondaryFixed;
  final Color onSecondaryFixed;
  final Color secondaryFixedDim;
  final Color onSecondaryFixedVariant;
  final Color tertiaryFixed;
  final Color onTertiaryFixed;
  final Color tertiaryFixedDim;
  final Color onTertiaryFixedVariant;
  final Color surfaceDim;
  final Color surfaceBright;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
}
///Roszerzenie na klasę 'MaterialScheme', umożliwiające konwersję na 'ColorScheme'.
extension MaterialSchemeUtils on MaterialScheme {
  ///Konwertuje 'MaterialScheme' na obiekt 'ColorScheme'.
  ///
  /// Umożliwia użycie schematu kolorów w 'ThemeData'.
  ColorScheme toColorScheme() {
    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      background: background,
      onBackground: onBackground,
      surface: surface,
      onSurface: onSurface,
      surfaceVariant: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: shadow,
      scrim: scrim,
      inverseSurface: inverseSurface,
      onInverseSurface: inverseOnSurface,
      inversePrimary: inversePrimary,
    );
  }
}
///Klasa reprezentująca rozszerzony kolor.
class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  ///Konstruktor klasy 'ExtendedColor'.
  ///
  /// Przyjmuje kolory dla różnych wariantów kontrastu i trybów jasnego/ciemnego.
  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}
///Klasa reprezentująca rodzinę kolorów z odpowiednimi kontrastami.
class ColorFamily {
  ///Konstruktor klasy 'ColorFamily'
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
