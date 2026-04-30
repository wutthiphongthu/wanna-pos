import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injector.dart';
import '../../../auth/widgets/logout_menu.dart';
import '../../../categories/widgets/category_quick_dialog.dart';
import '../../../categories/bloc/category_bloc.dart';
import '../../../categories/pages/category_management_page.dart';

class BackendMainPage extends StatelessWidget {
  final VoidCallback? onMenuTap;
  final VoidCallback? onNavigateToStock;

  const BackendMainPage({
    super.key,
    this.onMenuTap,
    this.onNavigateToStock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: SafeArea(
        child: Column(
          children: [
            _BackendHeader(
              onMenuTap: onMenuTap,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ยินดีต้อนรับ',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ระบบจัดการข้อมูลหลังบ้าน PPOS',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green[100],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Management Options
              const Text(
                'ตัวเลือกการจัดการ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _ManagementCard(
                      title: 'จัดการสินค้า',
                      subtitle: 'เพิ่ม/แก้ไข/ลบสินค้า',
                      icon: Icons.inventory,
                      color: Theme.of(context).colorScheme.primary,
                      onTap: onNavigateToStock ?? () {},
                    ),
                    _ManagementCard(
                      title: 'จัดการหมวดหมู่',
                      subtitle: 'เพิ่ม/แก้ไข/ลบหมวดหมู่สินค้า',
                      icon: Icons.category,
                      color: Colors.purple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider(
                              create: (context) => getIt<CategoryBloc>(),
                              child: const CategoryManagementPage(),
                            ),
                          ),
                        );
                      },
                    ),
                    _ManagementCard(
                      title: 'รายงานการขาย',
                      subtitle: 'สถิติและรายงาน',
                      icon: Icons.analytics,
                      color: Colors.purple,
                      onTap: () {
                        // TODO: Navigate to sales reports
                      },
                    ),
                    _ManagementCard(
                      title: 'ตั้งค่าระบบ',
                      subtitle: 'การตั้งค่าต่างๆ',
                      icon: Icons.settings,
                      color: Colors.grey,
                      onTap: () {
                        // TODO: Navigate to system settings
                      },
                    ),
                  ],
                ),
              ),

              // Quick Actions
              const SizedBox(height: 20),

              const Text(
                'การดำเนินการด่วน',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Quick backup
                      },
                      icon: const Icon(Icons.backup),
                      label: const Text('สำรองข้อมูล'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Quick sync
                      },
                      icon: const Icon(Icons.sync),
                      label: const Text('ซิงค์ข้อมูล'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      ],
    ),
  ),
);
  }
}

class _BackendHeader extends StatelessWidget {
  final VoidCallback? onMenuTap;

  const _BackendHeader({this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onMenuTap,
            icon: const Icon(Icons.menu, color: Colors.white, size: 28),
          ),
          const Expanded(
            child: Text(
              'จัดการหลังบ้าน',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.category, color: Colors.white),
            onPressed: () =>
                CategoryDialogHelper.showCategoryManagementDialog(context),
            tooltip: 'จัดการหมวดหมู่ด่วน',
          ),
          const LogoutMenu(),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _ManagementCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ManagementCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: color,
                ),
              ),

              const SizedBox(height: 16),

              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
