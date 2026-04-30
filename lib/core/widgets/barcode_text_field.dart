import 'package:flutter/material.dart';
import '../utils/barcode_service.dart';
import '../di/injector.dart';

class BarcodeTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final bool enabled;
  final int? maxLines;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final bool showScanButton;
  final VoidCallback? onChanged;

  const BarcodeTextField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.enabled = true,
    this.maxLines = 1,
    this.keyboardType,
    this.prefixIcon,
    this.showScanButton = true,
    this.onChanged,
  });

  @override
  State<BarcodeTextField> createState() => _BarcodeTextFieldState();
}

class _BarcodeTextFieldState extends State<BarcodeTextField> {
  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        border: const OutlineInputBorder(),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.showScanButton
            ? _isScanning
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: widget.enabled ? _scanBarcode : null,
                    tooltip: 'สแกนบาร์โค้ด',
                  )
            : null,
      ),
      validator: widget.validator,
      enabled: widget.enabled && !_isScanning,
      maxLines: widget.maxLines,
      keyboardType: widget.keyboardType,
      onChanged: (value) {
        widget.onChanged?.call();
      },
    );
  }

  Future<void> _scanBarcode() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
    });

    try {
      final barcodeService = getIt<BarcodeService>();
      final result = await barcodeService.scanBarcode(context);

      if (result != null && mounted) {
        widget.controller.text = result;
        widget.onChanged?.call();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('สแกนบาร์โค้ดสำเร็จ: $result'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการสแกน: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }
}
