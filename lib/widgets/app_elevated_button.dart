import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart' hide AppRadius, AppFontSizes, AppSpacing;
import 'package:app_ramos_candidatura/app_config/app_platform.dart';
import 'package:app_ramos_candidatura/app_config/const/app_consts.dart';

Widget appElevatedButtonRamos({
  required String title,
  double? padding,
  double? height,
  double? width,
  double? radius,
  double? fontSize,
  Color? color,
  bool primary = true,
  bool invertedStyle = false,
  required void Function() onTap,
}) {
  var hover = false;
  final borderRadius = radius ?? (isIOSPlatform ? 12.0 : AppRadius.input);
  final buttonHeight = height ?? (isIOSPlatform ? 50.0 : 48.0);
  final label = isIOSPlatform ? title : title.toUpperCase();
  final textSize = fontSize ?? (isIOSPlatform ? 17.0 : AppFontSizes.verySmall);

  return StatefulBuilder(
    builder: (context, setState) {
      final buttonWidth = width ?? MediaQuery.of(context).size.width;

      return MouseRegion(
        onEnter: (_) => setState(() => hover = true),
        onExit: (_) => setState(() => hover = false),
        child: Padding(
          padding: EdgeInsets.only(top: padding ?? 0),
          child: _animatedElevatedButton(
            hover: hover,
            primary: primary,
            invertedStyle: invertedStyle,
            label: label,
            onTap: onTap,
            buttonHeight: buttonHeight,
            buttonWidth: buttonWidth,
            borderRadius: borderRadius,
            textSize: textSize,
          ),
        ),
      );
    },
  );
}

Widget appElevatedButtonRamosTransparent({
  required String title,
  double? width,
  double? height,
  double? radius,
  Color? color,
  required void Function() onTap,
}) {
  return appElevatedButtonRamos(
    title: title,
    width: width,
    height: height,
    radius: radius,
    color: color,
    primary: false,
    onTap: onTap,
  );
}

Widget _animatedElevatedButton({
  required bool hover,
  required bool primary,
  required bool invertedStyle,
  required String label,
  required void Function() onTap,
  required double buttonHeight,
  required double buttonWidth,
  required double borderRadius,
  required double textSize,
}) {
  final isOutline = primary ? (invertedStyle && !hover) : (invertedStyle ? hover : !hover);
  final colors = _resolveElevatedButtonColors(primary: primary, isOutline: isOutline, hover: hover);
  final letterSpacing = isIOSPlatform ? -0.41 : 1.0;
  final fontFamily = isIOSPlatform ? null : 'lato';
  final fontWeight = isIOSPlatform ? FontWeight.w600 : FontWeight.bold;

  return AnimatedContainer(
    duration: AppDuration.fast,
    curve: Curves.easeInOut,
    height: buttonHeight,
    width: buttonWidth,
    decoration: BoxDecoration(
      color: colors.backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: colors.borderColor,
        width: colors.borderWidth,
      ),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: AppDuration.fast,
            curve: Curves.easeInOut,
            style: TextStyle(
              color: colors.textColor,
              fontWeight: fontWeight,
              fontSize: textSize,
              letterSpacing: letterSpacing,
              fontFamily: fontFamily,
            ),
            child: Text(label),
          ),
        ),
      ),
    ),
  );
}

({Color backgroundColor, Color textColor, Color borderColor, double borderWidth})
    _resolveElevatedButtonColors({
  required bool primary,
  required bool isOutline,
  required bool hover,
}) {
  if (primary) {
    if (isOutline) {
      return (
        backgroundColor: AppColors.white,
        textColor: RamosColors.secondary,
        borderColor: RamosColors.secondary,
        borderWidth: AppBorder.thick,
      );
    }

    return (
      backgroundColor: hover ? const Color(0xFF9FB82A) : RamosColors.secondary,
      textColor: AppColors.black,
      borderColor: RamosColors.secondary,
      borderWidth: 0,
    );
  }

  if (isOutline) {
    return (
      backgroundColor: AppColors.white,
      textColor: RamosColors.secondary,
      borderColor: RamosColors.secondary,
      borderWidth: AppBorder.thick,
    );
  }

  return (
    backgroundColor: AppColors.white,
    textColor: AppColors.grey900,
    borderColor: AppColors.grey200,
    borderWidth: AppBorder.thin,
  );
}
