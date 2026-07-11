import 'package:flutter/material.dart';
import 'package:app_ramos_candidatura/app_config/const/app_consts.dart';
import 'package:muller_package/muller_package.dart' hide AppRadius, AppFontSizes, AppSpacing;

class LoginFormField {
  final TextEditingController controller = TextEditingController();
  late final FocusNode focusNode;
  late final Widget formulario;

  LoginFormField({
    required String hint,
    double? width,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    focusNode = FocusNode();
    formulario = _LoginFormFieldWidget(
      controller: controller,
      focusNode: focusNode,
      hint: hint,
      width: width,
      icon: icon,
      obscureText: obscureText,
      validator: validator,
    );
  }

  String get value => controller.text;
}

class _LoginFormFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final double? width;
  final IconData icon;
  final bool obscureText;
  final String? Function(String?)? validator;

  const _LoginFormFieldWidget({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.width,
    required this.icon,
    required this.obscureText,
    required this.validator,
  });

  @override
  State<_LoginFormFieldWidget> createState() => _LoginFormFieldWidgetState();
}

class _LoginFormFieldWidgetState extends State<_LoginFormFieldWidget> {
  bool _focused = false;
  bool _hover = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _focused = widget.focusNode.hasFocus);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  Color get _iconColor => _focused ? RamosColors.primary : AppColors.grey600;

  Color get _borderColor {
    if (_focused) return RamosColors.primary;
    if (_hover) return RamosColors.primary.withValues(alpha: 0.55);
    return AppColors.grey200;
  }

  InputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    final border = _border(_borderColor, width: _focused ? AppBorder.active : AppBorder.thin);

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: SizedBox(
          width: widget.width ?? double.infinity,
          child: TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            validator: widget.validator,
            obscureText: widget.obscureText ? _obscure : false,
            keyboardType: widget.obscureText
                ? TextInputType.visiblePassword
                : TextInputType.emailAddress,
            textInputAction:
                widget.obscureText ? TextInputAction.done : TextInputAction.next,
            style: TextStyle(
              fontFamily: 'lato',
              fontSize: AppFontSizes.small,
              color: AppColors.grey900,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              filled: true,
              fillColor: const Color(0xFFF4F6F6),
              prefixIcon: Icon(widget.icon, color: _iconColor),
              suffixIcon: widget.obscureText
                  ? IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: _focused ? RamosColors.primary : AppColors.grey600,
                      ),
                    )
                  : null,
              border: border,
              enabledBorder: border,
              focusedBorder: border,
              errorBorder: _border(AppColors.red, width: AppBorder.active),
              focusedErrorBorder: _border(AppColors.red, width: AppBorder.active),
              hintStyle: TextStyle(
                fontFamily: 'lato',
                fontSize: AppFontSizes.verySmall,
                color: AppColors.grey600,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
          ),
        ),
      ),
    );
  }
}
