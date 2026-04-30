import 'dart:io';
import 'package:flutter/material.dart';
import '../services/image_service.dart';
import '../di/injector.dart';

class ImagePickerWidget extends StatefulWidget {
  final List<String> initialImages;
  final Function(List<String>) onImagesChanged;
  final int maxImages;
  final String? labelText;
  final bool enabled;

  const ImagePickerWidget({
    super.key,
    this.initialImages = const [],
    required this.onImagesChanged,
    this.maxImages = 3,
    this.labelText,
    this.enabled = true,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  List<String> _images = [];
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _images = List.from(widget.initialImages);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
        ],
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 120),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _images.isEmpty ? _buildEmptyState() : _buildImageGrid(),
        ),
        if (_isUploading) ...[
          const SizedBox(height: 12),
          _buildUploadProgress(),
        ],
        const SizedBox(height: 8),
        Text(
          'สามารถเพิ่มรูปภาพได้สูงสุด ${widget.maxImages} รูป',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return InkWell(
      onTap: widget.enabled ? _addImage : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 48,
              color: widget.enabled ? Theme.of(context).colorScheme.primary : Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'เพิ่มรูปภาพสินค้า',
              style: TextStyle(
                fontSize: 16,
                color: widget.enabled ? Theme.of(context).colorScheme.primary : Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'แตะเพื่อเลือกรูปภาพ',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          ..._images.asMap().entries.map((entry) {
            final index = entry.key;
            final imagePath = entry.value;
            return _buildImageTile(imagePath, index);
          }),

          // Add button
          if (_images.length < widget.maxImages && widget.enabled)
            _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildImageTile(String imagePath, int index) {
    final imageService = getIt<ImageService>();

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image(
              image: imageService.getImageProvider(imagePath),
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.grey[400],
                  ),
                );
              },
            ),
          ),

          // Delete button
          if (widget.enabled)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _addImage,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            style: BorderStyle.solid,
            width: 2,
          ),
          color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Theme.of(context).colorScheme.primary, size: 32),
            const SizedBox(height: 4),
            Text(
              'เพิ่มรูป',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.cloud_upload, size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'กำลังอัปโหลด... ${(_uploadProgress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: _uploadProgress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
        ),
      ],
    );
  }

  Future<void> _addImage() async {
    if (_images.length >= widget.maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('สามารถเพิ่มรูปภาพได้สูงสุด ${widget.maxImages} รูป'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      return;
    }

    final imageService = getIt<ImageService>();
    final imageFile = await imageService.pickImage(context);

    if (imageFile != null) {
      // แสดงรูปทันทีด้วย path ของไฟล์ที่เลือก
      setState(() {
        _images.add(imageFile.path);
        _isUploading = true;
        _uploadProgress = 0.0;
      });
      widget.onImagesChanged(_images);

      try {
        // บันทึกรูปภาพลง local storage ก่อน
        final localPath = await imageService.saveImageLocally(imageFile);

        if (localPath != null) {
          // Upload รูปภาพไปยัง server
          final serverUrl = await imageService.uploadImage(
            imageFile,
            onProgress: (progress) {
              setState(() {
                _uploadProgress = progress;
              });
            },
          );

          setState(() {
            _isUploading = false;
          });

          if (serverUrl != null) {
            // อัปเดต path เป็น server URL ถ้า upload สำเร็จ
            setState(() {
              _images[_images.length - 1] = serverUrl;
            });
            widget.onImagesChanged(_images);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('อัปโหลดรูปภาพสำเร็จ'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            // อัปเดต path เป็น local path ถ้า upload ไม่สำเร็จ
            setState(() {
              _images[_images.length - 1] = localPath;
            });
            widget.onImagesChanged(_images);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      const Text('บันทึกรูปภาพในเครื่องสำเร็จ (จะอัปโหลดภายหลัง)'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
            }
          }
        } else {
          // ถ้า save local ไม่สำเร็จ ลบรูปออกจาก list
          setState(() {
            _images.removeLast();
            _isUploading = false;
          });
          widget.onImagesChanged(_images);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('ไม่สามารถบันทึกรูปภาพได้'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        // ลบรูปที่เพิ่มไว้ก่อนหน้า
        setState(() {
          _images.removeLast();
          _isUploading = false;
        });
        widget.onImagesChanged(_images);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('เกิดข้อผิดพลาด: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _removeImage(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบรูปภาพ'),
        content: const Text('คุณต้องการลบรูปภาพนี้ใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _images.removeAt(index);
                widget.onImagesChanged(_images);
              });
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }
}
