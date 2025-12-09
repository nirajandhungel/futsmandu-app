import 'package:flutter/material.dart';

class AppTheme {
  // inDrive Nepal-inspired Color Palette (Neon Green Theme)
  static const Color primaryColor = Color.fromARGB(255, 17, 224, 31); // Neon green
  static const Color darkPrimaryColor = Color.fromARGB(255, 0, 143, 10); // Neon green
  static const Color secondaryColor = Color(0xFF141414); // Dark background
  static const Color accentColor = Color(0xFF1ED760); // Lighter green accent
  static const Color backgroundColor = Color(0xFFFAFAFA); // Light mode background
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFE53935); // Red for errors
  static const Color successColor = Color(0xFF00C853); // Success green
  static const Color warningColor = Color(0xFFFFB300); // Amber for warnings
  // static const Color textPrimaryLight = Color(0xFF000000); // Black for light mode
  // static const Color textSecondaryLight = Color(0xFF424242); // Dark gray
  // static const Color textTertiaryLight = Color(0xFF757575); // Medium gray
  static const Color textPrimaryDark = Color(0xFFFFFFFF); // White for dark mode
  static const Color textSecondaryDark = Color(0xFFE0E0E0); // Light gray
  static const Color textTertiaryDark = Color(0xFFBDBDBD); // Medium light gray
  // static const Color dividerColorLight = Color(0xFFE0E0E0);
  static const Color dividerColorDark = Color(0xFF424242);
  // static const Color cardColorLight = Color(0xFFFFFFFF);
  static const Color cardColorDark = Color(0xFF1E1E1E);
  static const Color shadowColor = Color(0x1A000000);
  
  // Dark theme colors from your spec
  static const Color backgroundDark = Color(0xFF141414);
  static const Color buttonPrimaryBg = Color(0xFFC0F11C);
  static const Color buttonPrimaryText = Color(0xFF000000);
  static const Color buttonSecondaryBg = Color(0xFF141414);
  static const Color buttonSecondaryText = Color(0xFFFFFFFF);
  
  // Status colors
  static const Color onlineColor = Color(0xFF00E676); // Bright green for online
  static const Color offlineColor = Color(0xFF9E9E9E); // Gray for offline
  static const Color busyColor = Color(0xFFFF6D00); // Orange for busy
  
  // Gradients
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFD4FF38), // Brighter neon
      Color(0xFFC0F11C), // Primary neon
    ],
  );
  
  static const Gradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1A1A1A),
      Color(0xFF141414),
    ],
  );

  // Font Families (as per your spec)
  static const String fontFamilyPrimary = 'Rubik';
  static const String fontFamilySecondary = 'OpenSans';
  
  // Make sure to add these fonts to your pubspec.yaml
  /*
  fonts:
    - family: Rubik
      fonts:
        - asset: fonts/Rubik-Regular.ttf
        - asset: fonts/Rubik-Medium.ttf
          weight: 500
        - asset: fonts/Rubik-SemiBold.ttf
          weight: 600
        - asset: fonts/Rubik-Bold.ttf
          weight: 700
    - family: OpenSans
      fonts:
        - asset: fonts/OpenSans-Regular.ttf
        - asset: fonts/OpenSans-SemiBold.ttf
          weight: 600
  */

  // Text Themes
  // static TextTheme lightTextTheme = TextTheme(
  //   displayLarge: const TextStyle(
  //     fontSize: 32,
  //     fontWeight: FontWeight.w700,
  //     color: textPrimaryLight,
  //     fontFamily: fontFamilyPrimary,
  //     height: 1.2,
  //   ),
  //   displayMedium: const TextStyle(
  //     fontSize: 28,
  //     fontWeight: FontWeight.w700,
  //     color: textPrimaryLight,
  //     fontFamily: fontFamilyPrimary,
  //     height: 1.2,
  //   ),
  //   displaySmall: const TextStyle(
  //     fontSize: 24,
  //     fontWeight: FontWeight.w600,
  //     color: textPrimaryLight,
  //     fontFamily: fontFamilyPrimary,
  //     height: 1.3,
  //   ),
  //   headlineMedium: const TextStyle(
  //     fontSize: 20,
  //     fontWeight: FontWeight.w600,
  //     color: textPrimaryLight,
  //     fontFamily: fontFamilyPrimary,
  //     height: 1.4,
  //   ),
  //   headlineSmall: const TextStyle(
  //     fontSize: 18,
  //     fontWeight: FontWeight.w600,
  //     color: textPrimaryLight,
  //     fontFamily: fontFamilyPrimary,
  //     height: 1.4,
  //   ),
  //   titleLarge: const TextStyle(
  //     fontSize: 16,
  //     fontWeight: FontWeight.w600,
  //     color: textPrimaryLight,
  //     fontFamily: fontFamilyPrimary,
  //     height: 1.4,
  //   ),
  //   titleMedium: const TextStyle(
  //     fontSize: 14,
  //     fontWeight: FontWeight.w500,
  //     color: textPrimaryLight,
  //     fontFamily: fontFamilyPrimary,
  //     height: 1.4,
  //   ),
  //   titleSmall: const TextStyle(
  //     fontSize: 12,
  //     fontWeight: FontWeight.w500,
  //     color: textSecondaryLight,
  //     fontFamily: fontFamilyPrimary,
  //     height: 1.4,
  //   ),
  //   bodyLarge: const TextStyle(
  //     fontSize: 16,
  //     fontWeight: FontWeight.normal,
  //     color: textPrimaryLight,
  //     fontFamily: fontFamilySecondary,
  //     height: 1.5,
  //   ),
  //   bodyMedium: const TextStyle(
  //     fontSize: 14,
  //     fontWeight: FontWeight.normal,
  //     color: textPrimaryLight,
  //     fontFamily: fontFamilySecondary,
  //     height: 1.5,
  //   ),
  //   bodySmall: const TextStyle(
  //     fontSize: 12,
  //     fontWeight: FontWeight.normal,
  //     color: textSecondaryLight,
  //     fontFamily: fontFamilySecondary,
  //     height: 1.5,
  //   ),
  //   labelLarge: TextStyle(
  //     fontSize: 14,
  //     fontWeight: FontWeight.w600,
  //     color: primaryColor,
  //     fontFamily: fontFamilyPrimary,
  //     height: 1.4,
  //   ),
  //   labelMedium: const TextStyle(
  //     fontSize: 12,
  //     fontWeight: FontWeight.w500,
  //     color: textSecondaryLight,
  //     fontFamily: fontFamilyPrimary,
  //     height: 1.4,
  //   ),
  //   labelSmall: const TextStyle(
  //     fontSize: 10,
  //     fontWeight: FontWeight.normal,
  //     color: textTertiaryLight,
  //     fontFamily: fontFamilySecondary,
  //     height: 1.4,
  //   ),
  // );

  static TextTheme darkTextTheme = TextTheme(
    displayLarge: const TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: textPrimaryDark,
      fontFamily: fontFamilyPrimary,
      height: 1.2,
    ),
    displayMedium: const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: textPrimaryDark,
      fontFamily: fontFamilyPrimary,
      height: 1.2,
    ),
    displaySmall: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: textPrimaryDark,
      fontFamily: fontFamilyPrimary,
      height: 1.3,
    ),
    headlineMedium: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: textPrimaryDark,
      fontFamily: fontFamilyPrimary,
      height: 1.4,
    ),
    headlineSmall: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: textPrimaryDark,
      fontFamily: fontFamilyPrimary,
      height: 1.4,
    ),
    titleLarge: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: textPrimaryDark,
      fontFamily: fontFamilyPrimary,
      height: 1.4,
    ),
    titleMedium: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: textPrimaryDark,
      fontFamily: fontFamilyPrimary,
      height: 1.4,
    ),
    titleSmall: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: textSecondaryDark,
      fontFamily: fontFamilyPrimary,
      height: 1.4,
    ),
    bodyLarge: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: textPrimaryDark,
      fontFamily: fontFamilySecondary,
      height: 1.5,
    ),
    bodyMedium: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: textPrimaryDark,
      fontFamily: fontFamilySecondary,
      height: 1.5,
    ),
    bodySmall: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: textSecondaryDark,
      fontFamily: fontFamilySecondary,
      height: 1.5,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: primaryColor,
      fontFamily: fontFamilyPrimary,
      height: 1.4,
    ),
    labelMedium: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: textSecondaryDark,
      fontFamily: fontFamilyPrimary,
      height: 1.4,
    ),
    labelSmall: const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.normal,
      color: textTertiaryDark,
      fontFamily: fontFamilySecondary,
      height: 1.4,
    ),
  );

  // Light Theme
  // static ThemeData lightTheme = ThemeData(
  //   useMaterial3: true,
  //   colorScheme: const ColorScheme.light(
  //     primary: primaryColor,
  //     secondary: accentColor,
  //     surface: surfaceColor,
  //     background: backgroundColor,
  //     error: errorColor,
  //     onPrimary: buttonPrimaryText,
  //     onSecondary: Colors.white,
  //     onSurface: textPrimaryLight,
  //     onBackground: textPrimaryLight,
  //     onError: Colors.white,
  //     brightness: Brightness.light,
  //   ),
  //   scaffoldBackgroundColor: backgroundColor,
  //   fontFamily: fontFamilySecondary,
  //   textTheme: lightTextTheme,
    
  //   // AppBar Theme
  //   appBarTheme: const AppBarTheme(
  //     elevation: 0,
  //     centerTitle: true,
  //     backgroundColor: Colors.white,
  //     foregroundColor: textPrimaryLight,
  //     titleTextStyle: TextStyle(
  //       fontFamily: fontFamilyPrimary,
  //       fontSize: 20,
  //       fontWeight: FontWeight.w600,
  //       color: textPrimaryLight,
  //     ),
  //     iconTheme: IconThemeData(color: textPrimaryLight),
  //     actionsIconTheme: IconThemeData(color: primaryColor),
  //   ),
    
  //   // Button Themes
  //   elevatedButtonTheme: ElevatedButtonThemeData(
  //     style: ElevatedButton.styleFrom(
  //       backgroundColor: primaryColor,
  //       foregroundColor: buttonPrimaryText,
  //       elevation: 0,
  //       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(radiusM),
  //       ),
  //       textStyle: const TextStyle(
  //         fontFamily: fontFamilyPrimary,
  //         fontSize: 16,
  //         fontWeight: FontWeight.w600,
  //       ),
  //     ),
  //   ),
    
  //   outlinedButtonTheme: OutlinedButtonThemeData(
  //     style: OutlinedButton.styleFrom(
  //       foregroundColor: primaryColor,
  //       side: const BorderSide(color: primaryColor, width: 1.5),
  //       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(radiusM),
  //       ),
  //       textStyle: const TextStyle(
  //         fontFamily: fontFamilyPrimary,
  //         fontSize: 16,
  //         fontWeight: FontWeight.w600,
  //       ),
  //     ),
  //   ),
    
  //   textButtonTheme: TextButtonThemeData(
  //     style: TextButton.styleFrom(
  //       foregroundColor: primaryColor,
  //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  //       textStyle: const TextStyle(
  //         fontFamily: fontFamilyPrimary,
  //         fontSize: 14,
  //         fontWeight: FontWeight.w500,
  //       ),
  //     ),
  //   ),
    
  //   // Input Decoration Theme
  //   inputDecorationTheme: InputDecorationTheme(
  //     filled: true,
  //     fillColor: Colors.white,
  //     border: OutlineInputBorder(
  //       borderRadius: BorderRadius.circular(radiusM),
  //       borderSide: const BorderSide(color: dividerColorLight),
  //       gapPadding: 0,
  //     ),
  //     enabledBorder: OutlineInputBorder(
  //       borderRadius: BorderRadius.circular(radiusM),
  //       borderSide: const BorderSide(color: dividerColorLight),
  //     ),
  //     focusedBorder: OutlineInputBorder(
  //       borderRadius: BorderRadius.circular(radiusM),
  //       borderSide: const BorderSide(color: primaryColor, width: 2),
  //     ),
  //     errorBorder: OutlineInputBorder(
  //       borderRadius: BorderRadius.circular(radiusM),
  //       borderSide: const BorderSide(color: errorColor),
  //     ),
  //     focusedErrorBorder: OutlineInputBorder(
  //       borderRadius: BorderRadius.circular(radiusM),
  //       borderSide: const BorderSide(color: errorColor, width: 2),
  //     ),
  //     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  //     hintStyle: const TextStyle(
  //       color: textTertiaryLight,
  //       fontSize: 14,
  //       fontWeight: FontWeight.normal,
  //       fontFamily: fontFamilySecondary,
  //     ),
  //     labelStyle: const TextStyle(
  //       color: textSecondaryLight,
  //       fontSize: 14,
  //       fontWeight: FontWeight.w500,
  //       fontFamily: fontFamilySecondary,
  //     ),
  //     floatingLabelStyle: TextStyle(
  //       color: primaryColor,
  //       fontSize: 14,
  //       fontWeight: FontWeight.w600,
  //       fontFamily: fontFamilyPrimary,
  //     ),
  //   ),
    
  //   // Card Theme
  //   cardTheme: CardThemeData(
  //     elevation: 2,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(radiusM),
  //     ),
  //     color: cardColorLight,
  //     margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  //     surfaceTintColor: Colors.transparent,
  //   ),
    
  //   // Dialog Theme
  //   dialogTheme: DialogThemeData(
  //     backgroundColor: Colors.white,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(radiusL),
  //     ),
  //     elevation: 4,
  //   ),
    
  //   // Bottom Sheet Theme
  //   bottomSheetTheme: const BottomSheetThemeData(
  //     backgroundColor: Colors.white,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(
  //         top: Radius.circular(radiusL),
  //       ),
  //     ),
  //   ),
    
  //   // Chip Theme
  //   chipTheme: ChipThemeData(
  //     backgroundColor: backgroundColor,
  //     selectedColor: primaryColor,
  //     labelStyle: const TextStyle(
  //       fontSize: 12,
  //       fontWeight: FontWeight.w500,
  //       fontFamily: fontFamilyPrimary,
  //     ),
  //     secondaryLabelStyle: const TextStyle(
  //       fontSize: 12,
  //       fontWeight: FontWeight.w500,
  //       color: buttonPrimaryText,
  //       fontFamily: fontFamilyPrimary,
  //     ),
  //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(20),
  //     ),
  //   ),
    
  //   // Divider Theme
  //   dividerTheme: const DividerThemeData(
  //     color: dividerColorLight,
  //     thickness: 1,
  //     space: 0,
  //   ),
    
  //   // Floating Action Button Theme
  //   floatingActionButtonTheme: const FloatingActionButtonThemeData(
  //     backgroundColor: primaryColor,
  //     foregroundColor: buttonPrimaryText,
  //     shape: CircleBorder(),
  //   ),
  // );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      surface: backgroundDark,
      background: backgroundDark,
      error: errorColor,
      onPrimary: buttonPrimaryText,
      onSecondary: Colors.white,
      onSurface: textPrimaryDark,
      onBackground: textPrimaryDark,
      onError: Colors.white,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: backgroundDark,
    fontFamily: fontFamilySecondary,
    textTheme: darkTextTheme,
    
    // AppBar Theme (Dark)
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: backgroundDark,
      foregroundColor: textPrimaryDark,
      titleTextStyle: TextStyle(
        fontFamily: fontFamilyPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryDark,
      ),
      iconTheme: IconThemeData(color: textPrimaryDark),
      actionsIconTheme: IconThemeData(color: primaryColor),
    ),
    
    // Button Themes (Dark)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: buttonPrimaryText,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
        textStyle: const TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
        textStyle: const TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(
          fontFamily: fontFamilyPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    
    // Input Decoration Theme (Dark)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardColorDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: dividerColorDark),
        gapPadding: 0,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: dividerColorDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(
        color: textTertiaryDark,
        fontSize: 14,
        fontWeight: FontWeight.normal,
        fontFamily: fontFamilySecondary,
      ),
      labelStyle: const TextStyle(
        color: textSecondaryDark,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: fontFamilySecondary,
      ),
      floatingLabelStyle: TextStyle(
        color: primaryColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFamily: fontFamilyPrimary,
      ),
    ),
    
    // Card Theme (Dark)
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusM),
      ),
      color: cardColorDark,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      surfaceTintColor: Colors.transparent,
    ),
    
    // Dialog Theme (Dark)
    dialogTheme: DialogThemeData(
      backgroundColor: cardColorDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusL),
      ),
      elevation: 4,
    ),
    
    // Bottom Sheet Theme (Dark)
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: cardColorDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(radiusL),
        ),
      ),
    ),
    
    // Chip Theme (Dark)
    chipTheme: ChipThemeData(
      backgroundColor: backgroundDark,
      selectedColor: primaryColor,
      labelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        fontFamily: fontFamilyPrimary,
        color: textPrimaryDark,
      ),
      secondaryLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: buttonPrimaryText,
        fontFamily: fontFamilyPrimary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    
    // Divider Theme (Dark)
    dividerTheme: const DividerThemeData(
      color: dividerColorDark,
      thickness: 1,
      space: 0,
    ),
    
    // Floating Action Button Theme (Dark)
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: buttonPrimaryText,
      shape: CircleBorder(),
    ),
  );

  // Spacing (as per your spec)
  static const double spacingUnit = 4.0;
  static const double gutter = 16.0;
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;

  // Border Radius (as per your spec - 12px)
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusRound = 50.0;

  // Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: shadowColor,
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: shadowColor,
      blurRadius: 4,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  // // Custom widget styles (for inDrive-specific components)
  // static BoxDecoration get cardDecorationLight => BoxDecoration(
  //   color: surfaceColor,
  //   borderRadius: BorderRadius.circular(radiusM),
  //   boxShadow: cardShadow,
  // );

  static BoxDecoration get cardDecorationDark => BoxDecoration(
    color: cardColorDark,
    borderRadius: BorderRadius.circular(radiusM),
    boxShadow: cardShadow,
  );

  static BoxDecoration get primaryButtonDecoration => BoxDecoration(
    gradient: primaryGradient,
    borderRadius: BorderRadius.circular(radiusM),
    boxShadow: buttonShadow,
  );

  // static BoxDecoration get secondaryButtonDecorationLight => BoxDecoration(
  //   color: Colors.white,
  //   borderRadius: BorderRadius.circular(radiusM),
  //   border: Border.all(color: primaryColor, width: 1.5),
  //   boxShadow: buttonShadow,
  // );

  static BoxDecoration get secondaryButtonDecorationDark => BoxDecoration(
    color: backgroundDark,
    borderRadius: BorderRadius.circular(radiusM),
    border: Border.all(color: primaryColor, width: 1.5),
    boxShadow: buttonShadow,
  );

  // Custom text styles for inDrive app
  // static TextStyle get appBarTitleLight => const TextStyle(
  //   fontSize: 20,
  //   fontWeight: FontWeight.w600,
  //   color: textPrimaryLight,
  //   fontFamily: fontFamilyPrimary,
  // );

  static TextStyle get appBarTitleDark => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimaryDark,
    fontFamily: fontFamilyPrimary,
  );

  static TextStyle get priceText => const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: primaryColor,
    fontFamily: fontFamilyPrimary,
  );

  // static TextStyle get distanceTextLight => const TextStyle(
  //   fontSize: 12,
  //   fontWeight: FontWeight.w500,
  //   color: textSecondaryLight,
  //   fontFamily: fontFamilyPrimary,
  // );

  static TextStyle get distanceTextDark => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textSecondaryDark,
    fontFamily: fontFamilyPrimary,
  );

  // static TextStyle get driverNameLight => const TextStyle(
  //   fontSize: 16,
  //   fontWeight: FontWeight.w600,
  //   color: textPrimaryLight,
  //   fontFamily: fontFamilyPrimary,
  // );

  static TextStyle get driverNameDark => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimaryDark,
    fontFamily: fontFamilyPrimary,
  );

  static TextStyle get ratingText => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: warningColor,
    fontFamily: fontFamilyPrimary,
  );

  // static TextStyle get vehicleInfoLight => const TextStyle(
  //   fontSize: 12,
  //   fontWeight: FontWeight.normal,
  //   color: textTertiaryLight,
  //   fontFamily: fontFamilySecondary,
  // );

  static TextStyle get vehicleInfoDark => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textTertiaryDark,
    fontFamily: fontFamilySecondary,
  );

  static TextStyle get badgeText => const TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: buttonPrimaryText,
    fontFamily: fontFamilyPrimary,
  );

  // Ride status styles
  static TextStyle get rideConfirmedText => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: successColor,
    fontFamily: fontFamilyPrimary,
  );

  static TextStyle get ridePendingText => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: warningColor,
    fontFamily: fontFamilyPrimary,
  );

  static TextStyle get rideCancelledText => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: errorColor,
    fontFamily: fontFamilyPrimary,
  );

  // Special inDrive components
  // static BoxDecoration get offerCardDecorationLight => BoxDecoration(
  //   color: primaryColor.withOpacity(0.1),
  //   borderRadius: BorderRadius.circular(radiusM),
  //   border: Border.all(color: primaryColor.withOpacity(0.3), width: 1),
  // );

  static BoxDecoration get offerCardDecorationDark => BoxDecoration(
    color: primaryColor.withOpacity(0.15),
    borderRadius: BorderRadius.circular(radiusM),
    border: Border.all(color: primaryColor.withOpacity(0.4), width: 1),
  );
}

// Extension for easy access with theme mode support
extension ThemeExtension on BuildContext {
  AppTheme get appTheme => AppTheme();
  
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  
  Color get primaryColor => AppTheme.primaryColor;
  
  // Color get backgroundColor => isDarkMode 
  //     ? AppTheme.backgroundDark 
  //     : AppTheme.backgroundColor;
  
  // Color get textPrimary => isDarkMode
  //     ? AppTheme.textPrimaryDark
  //     : AppTheme.textPrimaryLight;
  
  // Color get textSecondary => isDarkMode
  //     ? AppTheme.textSecondaryDark
  //     : AppTheme.textSecondaryLight;
  
  // Color get cardColor => isDarkMode
  //     ? AppTheme.cardColorDark
  //     : AppTheme.cardColorLight;
  
  // TextStyle get titleLarge => isDarkMode
  //     ? AppTheme.darkTextTheme.titleLarge!
  //     : AppTheme.lightTextTheme.titleLarge!;
  
  // TextStyle get driverName => isDarkMode
  //     ? AppTheme.driverNameDark
  //     : AppTheme.driverNameLight;
  
  // BoxDecoration get cardDecoration => isDarkMode
  //     ? AppTheme.cardDecorationDark
  //     : AppTheme.cardDecorationLight;
  
  // BoxDecoration get secondaryButtonDecoration => isDarkMode
  //     ? AppTheme.secondaryButtonDecorationDark
  //     : AppTheme.secondaryButtonDecorationLight;
}

// Helper class for responsive design
class AppSpacing {
  static double get spacingUnit => AppTheme.spacingUnit;
  static double get gutter => AppTheme.gutter;
  
  static EdgeInsets get pagePadding => EdgeInsets.symmetric(
    horizontal: AppTheme.gutter,
    vertical: AppTheme.paddingM,
  );
  
  static EdgeInsets get cardPadding => EdgeInsets.all(AppTheme.paddingM);
  
  static EdgeInsets get buttonPadding => EdgeInsets.symmetric(
    horizontal: AppTheme.paddingL,
    vertical: AppTheme.paddingM,
  );
}