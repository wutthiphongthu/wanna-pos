import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

@injectable
class BarcodeService {
  // ตรวจสอบและขอ permission กล้อง
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.status;

    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    } else if (status.isPermanentlyDenied) {
      // แนะนำให้ไปตั้งค่า
      await openAppSettings();
      return false;
    }

    return false;
  }

  // เปิด barcode scanner และคืนค่าผลลัพธ์
  Future<String?> scanBarcode(BuildContext context) async {
    // ตรวจสอบ permission ก่อน
    final hasPermission = await requestCameraPermission();
    if (!hasPermission) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ไม่ได้รับอนุญาตให้ใช้กล้อง'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }

    // เปิด scanner
    return await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const BarcodeScannerPage(),
      ),
    );
  }
}

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  final MobileScannerController controller = MobileScannerController();
  bool _isScanning = true;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      if (barcode.rawValue != null) {
        setState(() {
          _isScanning = false;
        });

        // ส่งผลลัพธ์กลับ
        Navigator.pop(context, barcode.rawValue);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('สแกนบาร์โค้ด'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Scanner View
          MobileScanner(
            controller: controller,
            onDetect: _onBarcodeDetected,
          ),

          // Overlay
          Container(
            decoration: ShapeDecoration(
              shape: QrScannerOverlayShape(
                borderColor: Colors.white,
                borderRadius: 16,
                borderLength: 40,
                borderWidth: 4,
                cutOutSize: 250,
              ),
            ),
          ),

          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'วางบาร์โค้ดไว้ในกรอบเพื่อสแกน',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Manual Input Button
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () => _showManualInput(),
                icon: const Icon(Icons.keyboard),
                label: const Text('พิมพ์บาร์โค้ดเอง'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showManualInput() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ป้อนบาร์โค้ดเอง'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'บาร์โค้ด',
            hintText: '1234567890123',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context); // ปิด dialog
                Navigator.pop(context, controller.text); // ส่งผลลัพธ์กลับ
              }
            },
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }
}

// Custom overlay shape สำหรับ scanner
class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path path = Path()..addRect(rect);
    Path holePath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: rect.center,
          width: cutOutSize,
          height: cutOutSize,
        ),
        Radius.circular(borderRadius),
      ));
    return Path.combine(PathOperation.difference, path, holePath);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderOffset = borderWidth / 2;
    final height = rect.height;
    final borderWidthSize = width / 2;
    final borderHeightSize = height / 2;
    final centerWidth = width / 2 + cutOutSize / 2;
    final centerHeight = height / 2 + cutOutSize / 2;

    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final boxPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final cutOutRect = Rect.fromCenter(
      center: rect.center,
      width: cutOutSize,
      height: cutOutSize,
    );

    canvas.saveLayer(
      rect,
      Paint(),
    );
    canvas.drawRect(rect, Paint()..color = overlayColor);
    canvas.drawRRect(
      RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)),
      boxPaint,
    );

    canvas.restore();

    // Draw border lines
    final path = Path();

    // Top left
    path.moveTo(cutOutRect.left - borderOffset, cutOutRect.top + borderLength);
    path.lineTo(cutOutRect.left - borderOffset, cutOutRect.top + borderRadius);
    path.quadraticBezierTo(
        cutOutRect.left - borderOffset,
        cutOutRect.top - borderOffset,
        cutOutRect.left + borderRadius,
        cutOutRect.top - borderOffset);
    path.lineTo(cutOutRect.left + borderLength, cutOutRect.top - borderOffset);

    // Top right
    path.moveTo(cutOutRect.right - borderLength, cutOutRect.top - borderOffset);
    path.lineTo(cutOutRect.right - borderRadius, cutOutRect.top - borderOffset);
    path.quadraticBezierTo(
        cutOutRect.right + borderOffset,
        cutOutRect.top - borderOffset,
        cutOutRect.right + borderOffset,
        cutOutRect.top + borderRadius);
    path.lineTo(cutOutRect.right + borderOffset, cutOutRect.top + borderLength);

    // Bottom right
    path.moveTo(
        cutOutRect.right + borderOffset, cutOutRect.bottom - borderLength);
    path.lineTo(
        cutOutRect.right + borderOffset, cutOutRect.bottom - borderRadius);
    path.quadraticBezierTo(
        cutOutRect.right + borderOffset,
        cutOutRect.bottom + borderOffset,
        cutOutRect.right - borderRadius,
        cutOutRect.bottom + borderOffset);
    path.lineTo(
        cutOutRect.right - borderLength, cutOutRect.bottom + borderOffset);

    // Bottom left
    path.moveTo(
        cutOutRect.left + borderLength, cutOutRect.bottom + borderOffset);
    path.lineTo(
        cutOutRect.left + borderRadius, cutOutRect.bottom + borderOffset);
    path.quadraticBezierTo(
        cutOutRect.left - borderOffset,
        cutOutRect.bottom + borderOffset,
        cutOutRect.left - borderOffset,
        cutOutRect.bottom - borderRadius);
    path.lineTo(
        cutOutRect.left - borderOffset, cutOutRect.bottom - borderLength);

    canvas.drawPath(path, borderPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}
