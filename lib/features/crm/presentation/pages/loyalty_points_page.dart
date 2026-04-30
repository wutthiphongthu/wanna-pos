import 'package:flutter/material.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/theme.dart';
import '../../../loyalty/models/loyalty_points_config.dart';
import '../../../loyalty/pages/loyalty_points_config_page.dart';
import '../../../loyalty/services/loyalty_points_config_service_interface.dart';
import '../../../members/pages/member_list_page.dart';

/// หน้าแสดงข้อมูลระบบสะสมคะแนน
class LoyaltyPointsPage extends StatefulWidget {
  const LoyaltyPointsPage({super.key});

  @override
  State<LoyaltyPointsPage> createState() => _LoyaltyPointsPageState();
}

class _LoyaltyPointsPageState extends State<LoyaltyPointsPage> {
  final _configService = getIt<ILoyaltyPointsConfigService>();
  LoyaltyPointsConfig? _config;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    setState(() => _loading = true);
    final config = await _configService.getConfig();
    if (mounted) {
      setState(() {
        _config = config;
        _loading = false;
      });
    }
  }

  void _navigateToConfig() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoyaltyPointsConfigPage()),
    ).then((_) async {
      if (mounted) await _loadConfig();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('การสะสมคะแนน'),
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
                  _InfoCard(
                    icon: Icons.stars,
                    title: 'อัตราการสะสม',
                    children: [
                      Text(
                        '1 คะแนน ต่อ ${_config?.pointsPerBaht ?? 10} บาทที่ซื้อ',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      _buildCategoryModeText(),
                      const SizedBox(height: 8),
                      const Text('คูณตามระดับสมาชิก:', style: TextStyle(fontWeight: FontWeight.w600)),
                      ...AppConstants.membershipPointMultiplier.entries.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(left: 16, top: 4),
                          child: Text('${e.key}: ${e.value}x'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _InfoCard(
                    icon: Icons.card_giftcard,
                    title: 'การแลกคะแนน',
                    children: [
                      Text('1 คะแนน = ${AppConstants.bahtPerPoint} บาท ส่วนลด'),
                      const SizedBox(height: 8),
                      const Text(
                        'สามารถแลกคะแนนได้ที่หน้า จัดการสมาชิก โดยเลือกเมนู "แลกคะแนน" ของสมาชิก',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _navigateToConfig,
                    icon: const Icon(Icons.settings),
                    label: const Text('ตั้งค่าสะสมคะแนน'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MemberListPage()),
                      );
                    },
                    icon: const Icon(Icons.people),
                    label: const Text('จัดการสมาชิก'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCategoryModeText() {
    final mode = _config?.categoryMode ?? 'all';
    final names = _config?.categoryNames ?? [];
    String modeText;
    switch (mode) {
      case 'all':
        modeText = 'ทุกหมวดหมู่ร่วมสะสมคะแนน';
        break;
      case 'include':
        modeText = names.isEmpty
            ? 'เฉพาะหมวดหมู่ที่เลือก (ยังไม่ได้เลือก)'
            : 'เฉพาะหมวดหมู่: ${names.join(", ")}';
        break;
      case 'exclude':
        modeText = names.isEmpty
            ? 'ยกเว้นหมวดหมู่ที่เลือก (ยังไม่ได้เลือก)'
            : 'ยกเว้นหมวดหมู่: ${names.join(", ")}';
        break;
      default:
        modeText = 'ทุกหมวดหมู่ร่วมสะสมคะแนน';
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        modeText,
        style: TextStyle(color: Colors.grey[700], fontSize: 14),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
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
                Icon(icon, color: AppTheme.primaryColor, size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}
