import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muller_package/muller_package.dart' hide AppRadius, AppFontSizes, AppSpacing;
import 'package:app_ramos_candidatura/app_config/app_platform.dart';
import 'package:app_ramos_candidatura/app_config/app_theme.dart';
import 'package:app_ramos_candidatura/pages/login_page/auth_gate_page.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: kAppSystemUiOverlay,
      child: MaterialApp(
        title: 'Ramos - Candidatura',
        navigatorKey: AppContext.navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(isIOS: isIOSPlatform),
        home: const AuthGatePage(),
      ),
    );
  }
}
