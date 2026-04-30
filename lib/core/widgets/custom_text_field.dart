import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/number_formatter.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final bool enabled;
  final int? maxLines;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final bool readOnly;
  final String? prefixText;
  final VoidCallback? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.enabled = true,
    this.maxLines = 1,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.readOnly = false,
    this.prefixText,
    this.onChanged,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: const OutlineInputBorder(),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        prefixText: prefixText,
      ),
      validator: validator,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onTap: onTap,
      readOnly: readOnly,
      onChanged: onChanged != null ? (_) => onChanged!() : null,
    );
  }
}

class RequiredTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final String? requiredMessage;
  final bool enabled;
  final int? maxLines;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;

  const RequiredTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.requiredMessage,
    this.enabled = true,
    this.maxLines = 1,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      labelText: '$labelText *',
      hintText: hintText,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return requiredMessage ?? 'กรุณากรอก$labelText';
        }
        return null;
      },
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      prefixText: prefixText,
    );
  }
}

class NumberTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final bool isRequired;
  final bool allowDecimal;
  final String? prefixText;
  final double? minValue;
  final double? maxValue;

  const NumberTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.isRequired = false,
    this.allowDecimal = false,
    this.prefixText,
    this.minValue,
    this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      labelText: isRequired ? '$labelText *' : labelText,
      hintText: hintText,
      keyboardType: allowDecimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      prefixText: prefixText,
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return 'กรุณากรอก$labelText';
        }

        if (value != null && value.trim().isNotEmpty) {
          final number =
              allowDecimal ? double.tryParse(value) : int.tryParse(value);

          if (number == null) {
            return 'กรุณากรอกตัวเลขที่ถูกต้อง';
          }

          if (minValue != null && number < minValue!) {
            return 'ค่าต้องมากกว่าหรือเท่ากับ $minValue';
          }

          if (maxValue != null && number > maxValue!) {
            return 'ค่าต้องน้อยกว่าหรือเท่ากับ $maxValue';
          }
        }

        return null;
      },
    );
  }
}

class CurrencyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool showCurrencySymbol;
  final bool isRequired;

  const CurrencyTextField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.enabled = true,
    this.showCurrencySymbol = true,
    this.isRequired = false,
  });

  @override
  State<CurrencyTextField> createState() => _CurrencyTextFieldState();
}

class _CurrencyTextFieldState extends State<CurrencyTextField> {
  bool _isFormatting = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (_isFormatting) return;

    final text = widget.controller.text;
    final value = NumberFormatter.parseFormattedNumber(text);

    if (value != null && text.isNotEmpty) {
      _isFormatting = true;

      final formatted = widget.showCurrencySymbol
          ? NumberFormatter.formatCurrency(value)
          : NumberFormatter.formatCurrencyValue(value);

      if (text != formatted) {
        widget.controller.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(
            offset: formatted.length.clamp(0, formatted.length),
          ),
        );
      }

      _isFormatting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: widget.controller,
      labelText: widget.isRequired && widget.labelText != null
          ? '${widget.labelText} *'
          : widget.labelText,
      hintText:
          widget.hintText ?? (widget.showCurrencySymbol ? '฿0.00' : '0.00'),
      validator: widget.validator ??
          (value) {
            if (widget.isRequired && (value == null || value.trim().isEmpty)) {
              return 'กรุณากรอก${widget.labelText ?? 'ราคา'}';
            }

            if (value != null && value.trim().isNotEmpty) {
              final number = NumberFormatter.parseFormattedNumber(value);
              if (number == null) {
                return 'กรุณากรอกจำนวนเงินที่ถูกต้อง';
              }
              if (number < 0) {
                return 'จำนวนเงินต้องมากกว่าหรือเท่ากับ 0';
              }
            }

            return null;
          },
      enabled: widget.enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9฿,.]')),
      ],
      prefixIcon:
          widget.showCurrencySymbol ? const Icon(Icons.monetization_on) : null,
    );
  }
}
