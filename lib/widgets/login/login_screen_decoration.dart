import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart' hide AppRadius, AppFontSizes, AppSpacing;
import 'package:app_ramos_candidatura/app_config/const/app_consts.dart';

class LoginScreenBackground extends StatelessWidget {
  final Widget child;

  const LoginScreenBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppGradients.loginPanel,
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.medium),
          child: child,
        ),
      ),
    );
  }
}

class LoginGlassCard extends StatelessWidget {
  final Widget child;

  const LoginGlassCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.card + 4);

    final card = Container(
      constraints: const BoxConstraints(maxWidth: 440),
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.giant,
        vertical: AppSpacing.giant,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: kIsWeb ? 0.9 : 0.97),
        borderRadius: radius,
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey900.withValues(alpha: 0.16),
            blurRadius: kIsWeb ? 48 : 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );

    if (kIsWeb) {
      return ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: card,
        ),
      );
    }

    return card;
  }
}
