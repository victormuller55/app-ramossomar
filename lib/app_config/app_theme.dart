import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_ramos_candidatura/app_config/const/app_consts.dart';

const SystemUiOverlayStyle kAppSystemUiOverlay = SystemUiOverlayStyle(
  statusBarColor: RamosColors.primaryDark,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
  systemStatusBarContrastEnforced: false,
  systemNavigationBarColor: RamosColors.primaryDark,
  systemNavigationBarIconBrightness: Brightness.light,
  systemNavigationBarDividerColor: RamosColors.primaryDark,
  systemNavigationBarContrastEnforced: false,
);

ThemeData buildAppTheme({required bool isIOS}) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: RamosColors.primary,
    primary: RamosColors.primary,
    secondary: RamosColors.secondary,
    brightness: Brightness.light,
  );

  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: colorScheme,
    primaryColor: RamosColors.primary,
    scaffoldBackgroundColor: isIOS ? const Color(0xFFF2F2F7) : const Color(0xFFFAFAFA),
    appBarTheme: const AppBarTheme(
      backgroundColor: RamosColors.primaryDark,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: kAppSystemUiOverlay,
    ),
    dividerColor: isIOS ? const Color(0xFFC6C6C8) : const Color(0xFFEEEEEE),
  );

  if (!isIOS) return base;

  // Tema iOS moderno: fonte do sistema (SF Pro atual) + widgets .adaptive
  return base.copyWith(
    platform: TargetPlatform.iOS,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
    cupertinoOverrideTheme: const CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: RamosColors.primary,
      applyThemeToAll: true,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
    // Sem fontFamily fixa — o iOS usa SF Pro do sistema (versão atual do OS)
    textTheme: base.textTheme.apply(
      bodyColor: const Color(0xFF1C1C1E),
      displayColor: const Color(0xFF1C1C1E),
    ),
    dialogTheme: DialogThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    switchTheme: SwitchThemeData(
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return RamosColors.primary;
        return null;
      }),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: RamosColors.secondary,
        foregroundColor: Colors.black,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 17,
          letterSpacing: -0.41,
        ),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      iconColor: RamosColors.primary,
      textColor: Color(0xFF1C1C1E),
    ),
  );
}
