import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/theme.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_event.dart';
import '../bloc/category_state.dart';
import '../models/category_model.dart';

class CategoryFormDialog extends StatefulWidget {
  final CategoryModel? category;

  const CategoryFormDialog({super.key, this.category});

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedIcon = 'category';
  Color _selectedColor = AppTheme.primaryColor;
  bool _isActive = true;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _availableIcons = [
    {'name': 'category', 'icon': Icons.category, 'label': 'ทั่วไป'},
    {'name': 'restaurant', 'icon': Icons.restaurant, 'label': 'อาหาร'},
    {'name': 'local_drink', 'icon': Icons.local_drink, 'label': 'เครื่องดื่ม'},
    {'name': 'home', 'icon': Icons.home, 'label': 'ของใช้'},
    {'name': 'electrical_services', 'icon': Icons.electrical_services, 'label': 'เครื่องใช้ไฟฟ้า'},
    {'name': 'checkroom', 'icon': Icons.checkroom, 'label': 'เสื้อผ้า'},
    {'name': 'sports', 'icon': Icons.sports, 'label': 'กีฬา'},
    {'name': 'book', 'icon': Icons.book, 'label': 'หนังสือ'},
    {'name': 'toys', 'icon': Icons.toys, 'label': 'ของเล่น'},
    {'name': 'health_and_safety', 'icon': Icons.health_and_safety, 'label': 'สุขภาพ'},
  ];

  final List<Color> _availableColors = [
    AppTheme.primaryColor,
    Colors.green,
    AppTheme.secondaryColor,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.brown,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _populateForm();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _populateForm() {
    final category = widget.category!;
    _nameController.text = category.name;
    _descriptionController.text = category.description;
    _selectedIcon = category.iconName ?? 'category';
    _selectedColor = _parseColor(category.color) ?? AppTheme.primaryColor;
    _isActive = category.isActive;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CategoryBloc, CategoryState>(
      listener: (context, state) {
        if (state is CategoryOperationSuccess) {
          setState(() {
            _isLoading = false;
          });
          Navigator.pop(context);
        } else if (state is CategoryOperationFailure) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: _selectedColor.withOpacity(0.1),
                      child: Icon(
                        _getIconData(_selectedIcon),
                        color: _selectedColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.category == null ? 'เพิ่มหมวดหมู่ใหม่' : 'แก้ไขหมวดหมู่',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Name Field
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'ชื่อหมวดหมู่ *',
                            hintText: 'เช่น อาหาร, เครื่องดื่ม',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'กรุณากรอกชื่อหมวดหมู่';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Description Field
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'รายละเอียด',
                            hintText: 'รายละเอียดของหมวดหมู่',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Icon Selection
                        Text(
                          'เลือกไอคอน',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildIconSelector(),
                        
                        const SizedBox(height: 24),
                        
                        // Color Selection
                        Text(
                          'เลือกสี',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildColorSelector(),
                        
                        const SizedBox(height: 24),
                        
                        // Status Toggle
                        SwitchListTile(
                          title: const Text('เปิดใช้งาน'),
                          subtitle: const Text('หมวดหมู่จะแสดงในระบบ'),
                          value: _isActive,
                          onChanged: (value) {
                            setState(() {
                              _isActive = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        child: const Text('ยกเลิก'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveCategory,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(widget.category == null ? 'เพิ่ม' : 'อัปเดต'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconSelector() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: _availableIcons.length,
        itemBuilder: (context, index) {
          final iconData = _availableIcons[index];
          final isSelected = _selectedIcon == iconData['name'];
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIcon = iconData['name'];
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? _selectedColor.withOpacity(0.1) : Colors.grey[50],
                border: Border.all(
                  color: isSelected ? _selectedColor : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                iconData['icon'],
                color: isSelected ? _selectedColor : Colors.grey[600],
                size: 24,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorSelector() {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: _availableColors.map((color) {
          final isSelected = _selectedColor == color;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = color;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _saveCategory() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final now = DateTime.now();
    final category = CategoryModel(
      id: widget.category?.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      iconName: _selectedIcon,
      color: '#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
      isActive: _isActive,
      createdAt: widget.category?.createdAt ?? now,
      updatedAt: now,
    );

    if (widget.category == null) {
      context.read<CategoryBloc>().add(CreateCategory(category));
    } else {
      context.read<CategoryBloc>().add(UpdateCategory(category));
    }
  }

  Color? _parseColor(String? colorString) {
    if (colorString == null) return null;
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return null;
    }
  }

  IconData _getIconData(String iconName) {
    return _availableIcons
        .firstWhere(
          (icon) => icon['name'] == iconName,
          orElse: () => _availableIcons.first,
        )['icon'];
  }
}
