import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injector.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_event.dart';
import '../bloc/category_state.dart';
import '../models/category_model.dart';
import '../pages/category_management_page.dart';
import 'category_form_dialog.dart';

class CategoryQuickDialog extends StatefulWidget {
  final Function(CategoryModel)? onCategorySelected;
  final bool allowSelection;

  const CategoryQuickDialog({
    super.key,
    this.onCategorySelected,
    this.allowSelection = false,
  });

  @override
  State<CategoryQuickDialog> createState() => _CategoryQuickDialogState();
}

class _CategoryQuickDialogState extends State<CategoryQuickDialog> {
  final _searchController = TextEditingController();
  late CategoryBloc _categoryBloc;

  @override
  void initState() {
    super.initState();
    _categoryBloc = getIt<CategoryBloc>();
    _categoryBloc.add(const LoadActiveCategories());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _categoryBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _categoryBloc,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.category, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.allowSelection
                            ? 'เลือกหมวดหมู่'
                            : 'จัดการหมวดหมู่',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'ค้นหาหมวดหมู่...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _categoryBloc.add(const LoadActiveCategories());
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onChanged: (query) {
                    if (query.isEmpty) {
                      _categoryBloc.add(const LoadActiveCategories());
                    } else {
                      _categoryBloc.add(SearchCategories(query));
                    }
                  },
                ),
              ),

              // Category List
              Expanded(
                child: BlocBuilder<CategoryBloc, CategoryState>(
                  builder: (context, state) {
                    if (state is CategoryLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is CategoryError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, size: 48, color: Colors.red[300]),
                            const SizedBox(height: 12),
                            Text(
                              'เกิดข้อผิดพลาด',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () => _categoryBloc
                                  .add(const LoadActiveCategories()),
                              child: const Text('ลองใหม่'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is CategoryLoaded) {
                      final categories = state.categories;

                      if (categories.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.category,
                                  size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 12),
                              Text(
                                'ไม่มีหมวดหมู่',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'เพิ่มหมวดหมู่แรกของคุณ',
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                              const SizedBox(height: 12),
                              TextButton.icon(
                                onPressed: _showAddCategoryDialog,
                                icon: const Icon(Icons.add),
                                label: const Text('เพิ่มหมวดหมู่'),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return _buildCategoryTile(category);
                        },
                      );
                    }

                    return const Center(child: Text('ไม่พบข้อมูล'));
                  },
                ),
              ),

              // Action Buttons
              if (!widget.allowSelection) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _showAddCategoryDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('เพิ่มหมวดหมู่'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _openFullManagementPage,
                          icon: const Icon(Icons.settings),
                          label: const Text('จัดการทั้งหมด'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTile(CategoryModel category) {
    final color = _parseColor(category.color) ?? Colors.blue;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(
            _parseIcon(category.iconName),
            color: color,
            size: 20,
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: category.description.isNotEmpty
            ? Text(
                category.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: widget.allowSelection
            ? const Icon(Icons.chevron_right)
            : PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(value, category),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('แก้ไข'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(
                          category.isActive
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(category.isActive ? 'ปิดใช้งาน' : 'เปิดใช้งาน'),
                      ],
                    ),
                  ),
                ],
              ),
        onTap: widget.allowSelection
            ? () {
                Navigator.pop(context);
                widget.onCategorySelected?.call(category);
              }
            : null,
      ),
    );
  }

  void _handleMenuAction(String action, CategoryModel category) {
    switch (action) {
      case 'edit':
        _showEditCategoryDialog(category);
        break;
      case 'toggle':
        _categoryBloc.add(ToggleCategoryStatus(category.id!));
        break;
    }
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: _categoryBloc,
        child: const CategoryFormDialog(),
      ),
    );
  }

  void _showEditCategoryDialog(CategoryModel category) {
    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: _categoryBloc,
        child: CategoryFormDialog(category: category),
      ),
    );
  }

  void _openFullManagementPage() {
    Navigator.pop(context); // Close current dialog
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => getIt<CategoryBloc>(),
          child: const CategoryManagementPage(),
        ),
      ),
    );
  }

  Color? _parseColor(String? colorString) {
    if (colorString == null) return null;
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return null;
    }
  }

  IconData _parseIcon(String? iconName) {
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

// Helper function สำหรับเรียกใช้ dialog จากทุกหน้า
class CategoryDialogHelper {
  static void showCategoryManagementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CategoryQuickDialog(),
    );
  }

  static void showCategorySelectionDialog(
    BuildContext context, {
    required Function(CategoryModel) onCategorySelected,
  }) {
    showDialog(
      context: context,
      builder: (context) => CategoryQuickDialog(
        allowSelection: true,
        onCategorySelected: onCategorySelected,
      ),
    );
  }
}
