import 'dart:io';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

@injectable
class ImageService {
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  // ขอ permission สำหรับกล้องและ storage
  Future<bool> requestPermissions() async {
    try {
      // สำหรับ Android - เฉพาะกล้อง (ไม่ต้องขอ storage permission สำหรับ image_picker)
      if (Platform.isAndroid) {
        final cameraStatus = await Permission.camera.status;

        if (!cameraStatus.isGranted) {
          final result = await Permission.camera.request();
          return result.isGranted;
        }
        return true;
      }

      // สำหรับ iOS
      if (Platform.isIOS) {
        final permissions = <Permission>[
          Permission.camera,
          Permission.photos,
        ];

        // ตรวจสอบสิทธิ์ปัจจุบัน
        final Map<Permission, PermissionStatus> statuses = {};
        for (final permission in permissions) {
          statuses[permission] = await permission.status;
        }

        // รายการสิทธิ์ที่ยังไม่ได้อนุญาต
        final List<Permission> deniedPermissions = [];
        statuses.forEach((permission, status) {
          if (!status.isGranted) {
            deniedPermissions.add(permission);
          }
        });

        // ถ้ามีสิทธิ์ที่ยังไม่ได้อนุญาต ให้ขอสิทธิ์
        if (deniedPermissions.isNotEmpty) {
          final Map<Permission, PermissionStatus> requestResults =
              await deniedPermissions.request();

          // ตรวจสอบผลการขอสิทธิ์
          bool allGranted = true;
          requestResults.forEach((permission, status) {
            if (!status.isGranted) {
              allGranted = false;
            }
          });

          return allGranted;
        }
        return true;
      }

      return true;
    } catch (e) {
      print('Error requesting permissions: $e');
      return false;
    }
  }

  // แสดง dialog เลือกแหล่งที่มาของรูปภาพ
  Future<File?> pickImage(BuildContext context) async {
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      if (context.mounted) {
        await _showPermissionDialog(context);
      }
      return null;
    }

    return await showModalBottomSheet<File?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ImageSourceBottomSheet(
        onSourceSelected: (source) async {
          final result = await _pickImageFromSource(source, context);
          if (context.mounted) {
            Navigator.pop(context, result);
          }
          return result;
        },
      ),
    );
  }

  Future<File?> _pickImageFromSource(
      ImageSource source, BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return null;

      // ใช้รูปภาพโดยตรงโดยไม่ crop (เพื่อหลีกเลี่ยงปัญหา compatibility)
      return File(image.path);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการเลือกรูปภาพ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  // บันทึกรูปภาพลง local storage
  Future<String?> saveImageLocally(File imageFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/images');

      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final fileName = '${_uuid.v4()}.jpg';
      final localPath = '${imagesDir.path}/$fileName';

      await imageFile.copy(localPath);
      return localPath;
    } catch (e) {
      print('Error saving image locally: $e');
      return null;
    }
  }

  // Upload รูปภาพไปยัง server (Mock implementation)
  Future<String?> uploadImage(
    File imageFile, {
    Function(double)? onProgress,
  }) async {
    try {
      // จำลองการ upload
      await Future.delayed(const Duration(seconds: 1));

      // จำลอง progress
      if (onProgress != null) {
        for (int i = 0; i <= 100; i += 10) {
          await Future.delayed(const Duration(milliseconds: 100));
          onProgress(i / 100);
        }
      }

      // Mock server response - ในการใช้งานจริงจะเป็น API call
      final fileName = '${_uuid.v4()}.jpg';
      final mockUrl = 'https://api.dohome.com/uploads/products/$fileName';

      // TODO: Implement actual upload to server
      /*
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://your-api.com/upload'),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
      
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        // Parse response and return URL
        return jsonDecode(responseData)['url'];
      }
      */

      return mockUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // ลบรูปภาพจาก local storage
  Future<bool> deleteLocalImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting local image: $e');
      return false;
    }
  }

  // แสดง dialog เมื่อไม่ได้รับสิทธิ์
  Future<void> _showPermissionDialog(BuildContext context) async {
    // ตรวจสอบสิทธิ์แต่ละประเภท
    final cameraStatus = await Permission.camera.status;
    final storageStatus = Platform.isAndroid
        ? await Permission.storage.status
        : await Permission.photos.status;

    List<String> deniedPermissions = [];
    if (!cameraStatus.isGranted) {
      deniedPermissions.add('กล้อง');
    }
    if (!storageStatus.isGranted) {
      deniedPermissions
          .add(Platform.isAndroid ? 'พื้นที่จัดเก็บข้อมูล' : 'รูปภาพ');
    }

    String permissionText = deniedPermissions.join(' และ ');
    bool isPermanentlyDenied =
        cameraStatus.isPermanentlyDenied || storageStatus.isPermanentlyDenied;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('จำเป็นต้องได้รับสิทธิ์การเข้าถึง'),
          content: Text(
            isPermanentlyDenied
                ? 'แอปนี้จำเป็นต้องได้รับสิทธิ์การเข้าถึง$permissionText '
                    'เพื่อให้คุณสามารถเพิ่มรูปภาพสินค้าได้\n\n'
                    'กรุณาไปที่การตั้งค่าแอปและอนุญาตสิทธิ์ที่จำเป็น'
                : 'แอปนี้จำเป็นต้องได้รับสิทธิ์การเข้าถึง$permissionText '
                    'เพื่อให้คุณสามารถเพิ่มรูปภาพสินค้าได้\n\n'
                    'กรุณาอนุญาตสิทธิ์เมื่อระบบถาม',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child:
                  Text(isPermanentlyDenied ? 'ไปที่การตั้งค่า' : 'ลองอีกครั้ง'),
              onPressed: () async {
                Navigator.of(context).pop();
                if (isPermanentlyDenied) {
                  await openAppSettings();
                } else {
                  // ลองขอสิทธิ์อีกครั้ง
                  await requestPermissions();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // ตรวจสอบว่าเป็น URL หรือ local path
  bool isNetworkImage(String imagePath) {
    return imagePath.startsWith('http://') || imagePath.startsWith('https://');
  }

  // ตรวจสอบสิทธิ์เฉพาะกล้อง
  Future<bool> checkCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  // ตรวจสอบสิทธิ์เฉพาะ storage/photos
  Future<bool> checkStoragePermission() async {
    final Permission permission =
        Platform.isAndroid ? Permission.storage : Permission.photos;
    final status = await permission.status;
    return status.isGranted;
  }

  // ขอสิทธิ์เฉพาะกล้อง
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // ขอสิทธิ์เฉพาะ storage/photos
  Future<bool> requestStoragePermission() async {
    final Permission permission =
        Platform.isAndroid ? Permission.storage : Permission.photos;
    final status = await permission.request();
    return status.isGranted;
  }

  // สร้าง ImageProvider สำหรับแสดงรูป
  ImageProvider getImageProvider(String imagePath) {
    if (isNetworkImage(imagePath)) {
      return NetworkImage(imagePath);
    } else {
      return FileImage(File(imagePath));
    }
  }
}

class _ImageSourceBottomSheet extends StatelessWidget {
  final Future<File?> Function(ImageSource) onSourceSelected;

  const _ImageSourceBottomSheet({required this.onSourceSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'เลือกแหล่งที่มาของรูปภาพ',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _SourceOption(
                  icon: Icons.camera_alt,
                  label: 'ถ่ายรูป',
                  onTap: () async {
                    await onSourceSelected(ImageSource.camera);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SourceOption(
                  icon: Icons.photo_library,
                  label: 'เลือกจากแกลเลอรี่',
                  onTap: () async {
                    await onSourceSelected(ImageSource.gallery);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
