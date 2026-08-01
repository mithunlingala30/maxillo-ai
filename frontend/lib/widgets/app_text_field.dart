import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool enabled;
  final void Function(String)? onChanged;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          enabled: enabled,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 14, color: AppColors.heading),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

class AppDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final void Function(T?) onChanged;

  const AppDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          value: value,
          items: items
              .map((e) => DropdownMenuItem<T>(
                    value: e,
                    child: Text(labelBuilder(e), style: const TextStyle(fontSize: 14)),
                  ))
              .toList(),
          onChanged: onChanged,
          decoration: const InputDecoration(),
        ),
      ],
    );
  }
}
