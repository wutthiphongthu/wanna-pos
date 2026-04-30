import 'package:flutter/material.dart';
import '../../features/categories/models/category_model.dart';
import '../../features/categories/widgets/category_quick_dialog.dart';

class CategorySelector extends StatefulWidget {
  final CategoryModel? selectedCategory;
  final Function(CategoryModel?) onCategoryChanged;
  final String? labelText;
  final bool isRequired;
  final bool enabled;

  const CategorySelector({
    super.key,
    this.selectedCategory,
    required this.onCategoryChanged,
    this.labelText,
    this.isRequired = false,
    this.enabled = true,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.isRequired ? '${widget.labelText} *' : widget.labelText!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
        ],
        InkWell(
          onTap: widget.enabled ? _showCategorySelection : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.enabled ? Colors.grey[400]! : Colors.grey[300]!,
              ),
              borderRadius: BorderRadius.circular(8),
              color: widget.enabled ? Colors.white : Colors.grey[50],
            ),
            child: Row(
              children: [
                if (widget.selectedCategory != null) ...[
                  CircleAvatar(
                    radius: 16,
                    backgroundColor:
                        _parseCategoryColor(widget.selectedCategory!.color)
                            .withOpacity(0.1),
                    child: Icon(
                      _parseCategoryIcon(widget.selectedCategory!.iconName),
                      size: 18,
                      color:
                          _parseCategoryColor(widget.selectedCategory!.color),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.selectedCategory!.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        if (widget.selectedCategory!.description.isNotEmpty)
                          Text(
                            widget.selectedCategory!.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: widget.enabled ? _clearSelection : null,
                    tooltip: 'ล้างการเลือก',
                  ),
                ] else ...[
                  Icon(Icons.category, color: Colors.grey[400]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'เลือกหมวดหมู่สินค้า',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
                if (widget.enabled)
                  Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCategorySelection() {
    CategoryDialogHelper.showCategorySelectionDialog(
      context,
      onCategorySelected: (category) {
        widget.onCategoryChanged(category);
      },
    );
  }

  void _clearSelection() {
    widget.onCategoryChanged(null);
  }

  Color _parseCategoryColor(String? colorString) {
    if (colorString == null) return const Color(0xFFF89E2B);
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFFF89E2B);
    }
  }

  IconData _parseCategoryIcon(String? iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'local_drink':
        return Icons.local_drink;
      case 'home':
        return Icons.home;
      case 'electrical_services':
        return Icons.electrical_services;
      case 'checkroom':
        return Icons.checkroom;
      case 'sports':
        return Icons.sports;
      case 'book':
        return Icons.book;
      case 'toys':
        return Icons.toys;
      case 'health_and_safety':
        return Icons.health_and_safety;
      default:
        return Icons.category;
    }
  }
}

// Validator สำหรับ CategorySelector
class CategoryValidator {
  static String? required(CategoryModel? category, [String? message]) {
    if (category == null) {
      return message ?? 'กรุณาเลือกหมวดหมู่';
    }
    return null;
  }
}
