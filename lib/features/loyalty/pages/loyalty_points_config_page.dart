import 'package:flutter/material.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/utils/theme.dart';
import '../../categories/models/category_model.dart';
import '../../categories/services/category_service_interface.dart';
import '../models/loyalty_points_config.dart';
import '../services/loyalty_points_config_service_interface.dart';

/// หน้ากำหนดอัตราสะสมคะแนนและหมวดหมู่ที่ร่วมรายการ
class LoyaltyPointsConfigPage extends StatefulWidget {
  const LoyaltyPointsConfigPage({super.key});

  @override
  State<LoyaltyPointsConfigPage> createState() => _LoyaltyPointsConfigPageState();
}

class _LoyaltyPointsConfigPageState extends State<LoyaltyPointsConfigPage> {
  final _configService = getIt<ILoyaltyPointsConfigService>();
  final _categoryService = getIt<ICategoryService>();
  final _pointsPerBahtController = TextEditingController();

  LoyaltyPointsConfig _config = const LoyaltyPointsConfig();
  List<CategoryModel> _allCategories = [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pointsPerBahtController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final config = await _configService.getConfig();
    final categories = await _categoryService.getActiveCategories();
    setState(() {
      _config = config;
      _allCategories = categories;
      _pointsPerBahtController.text = config.pointsPerBaht.toString();
      _loading = false;
    });
  }

  Future<void> _save() async {
    final pts = int.tryParse(_pointsPerBahtController.text);
    if (pts == null || pts < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาระบุอัตราคะแนนที่ถูกต้อง (จำนวนเต็มมากกว่า 0)')),
      );
      return;
    }

    setState(() => _saving = true);
    await _configService.saveConfig(_config.copyWith(pointsPerBaht: pts));
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกการตั้งค่าเรียบร้อยแล้ว'), backgroundColor: Colors.green),
      );
    }
  }

  void _toggleCategory(CategoryModel cat) {
    final names = List<String>.from(_config.categoryNames);
    final idx = names.indexWhere((n) => n.toLowerCase() == cat.name.toLowerCase());
    if (idx >= 0) {
      names.removeAt(idx);
    } else {
      names.add(cat.name);
    }
    setState(() => _config = _config.copyWith(categoryNames: names));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('ตั้งค่าสะสมคะแนน'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildRateSection(),
                  const SizedBox(height: 24),
                  _buildCategorySection(),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('บันทึก'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildRateSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tune, color: AppTheme.primaryColor, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'อัตราการสะสม',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '1 คะแนน ต่อกี่บาทที่ซื้อ',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _pointsPerBahtController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '10',
                suffixText: 'บาท',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ตัวอย่าง: 10 = ซื้อ 100 บาท ได้ 10 คะแนน',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.category, color: AppTheme.primaryColor, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'หมวดหมู่ที่ร่วมรายการ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'all', label: Text('ทุกหมวดหมู่')),
                ButtonSegment(value: 'include', label: Text('เฉพาะที่เลือก')),
                ButtonSegment(value: 'exclude', label: Text('ยกเว้นที่เลือก')),
              ],
              selected: {_config.categoryMode},
              onSelectionChanged: (s) => setState(() => _config = _config.copyWith(categoryMode: s.first)),
            ),
            if (_config.categoryMode != 'all') ...[
              const SizedBox(height: 16),
              Text(
                _config.categoryMode == 'include'
                    ? 'เลือกหมวดหมู่ที่ร่วมสะสมคะแนน'
                    : 'เลือกหมวดหมู่ที่ไม่ร่วมสะสมคะแนน',
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 12),
              ..._allCategories.map((cat) {
                final selected = _config.categoryNames.any((n) => n.toLowerCase() == cat.name.toLowerCase());
                return CheckboxListTile(
                  value: selected,
                  onChanged: (_) => _toggleCategory(cat),
                  title: Text(cat.name),
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }),
              if (_allCategories.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'ยังไม่มีหมวดหมู่สินค้า',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
