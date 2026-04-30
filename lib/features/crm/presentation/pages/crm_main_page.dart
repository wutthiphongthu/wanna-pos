import 'package:flutter/material.dart';
import '../../../../core/utils/theme.dart';
import '../../../members/pages/member_list_page.dart';
import 'loyalty_points_page.dart';

class CRMMainPage extends StatelessWidget {
  final VoidCallback? onMenuTap;

  const CRMMainPage({super.key, this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: onMenuTap,
        ),
        title: const Text('CRM'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryDarkColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'จัดการลูกค้าสัมพันธ์',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'ลูกค้า ลีด โอกาสขาย และกิจกรรม',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'ฟังก์ชัน CRM',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              _CRMOptionCard(
                icon: Icons.card_giftcard,
                title: 'การสะสมคะแนน',
                subtitle: 'สะสมคะแนน แลกของรางวัล ระดับสมาชิก',
                color: AppTheme.warningColor,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoyaltyPointsPage()),
                ),
              ),
              const SizedBox(height: 12),
              _CRMOptionCard(
                icon: Icons.people,
                title: 'ลูกค้า / สมาชิก',
                subtitle: 'จัดการข้อมูลลูกค้า สมาชิก และคะแนนสะสม',
                color: AppTheme.primaryColor,
                onTap: () => _navigateToMembers(context),
              ),
              const SizedBox(height: 12),
              _CRMOptionCard(
                icon: Icons.person_search,
                title: 'ลีด / โอกาสขาย',
                subtitle: 'ติดตามลีดและโอกาสในการขาย',
                color: AppTheme.secondaryColor,
                onTap: () => _showComingSoon(context, 'ลีด / โอกาสขาย'),
              ),
              const SizedBox(height: 12),
              _CRMOptionCard(
                icon: Icons.event_note,
                title: 'กิจกรรม',
                subtitle: 'นัดหมาย โทรติดตาม และบันทึกกิจกรรม',
                color: AppTheme.infoColor,
                onTap: () => _showComingSoon(context, 'กิจกรรม'),
              ),
              const SizedBox(height: 12),
              _CRMOptionCard(
                icon: Icons.analytics,
                title: 'รายงาน CRM',
                subtitle: 'สรุปยอดและประสิทธิภาพการขาย',
                color: AppTheme.successColor,
                onTap: () => _showComingSoon(context, 'รายงาน CRM'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _navigateToMembers(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MemberListPage(),
      ),
    );
  }

  static void _showComingSoon(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(name),
        content: Text(
          'ฟังก์ชัน $name จะพร้อมใช้งานในเวอร์ชันถัดไป',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }
}

class _CRMOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _CRMOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
