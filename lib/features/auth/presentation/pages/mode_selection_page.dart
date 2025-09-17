import 'package:flutter/material.dart';
import '../../widgets/logout_menu.dart';

class ModeSelectionPage extends StatelessWidget {
  const ModeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          const LogoutMenu(),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                kToolbarHeight -
                48, // AppBar height + padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header
                const Text(
                  'เลือกโหมดการทำงาน',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'กรุณาเลือกโหมดที่ต้องการใช้งาน',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 40),

                // Mode Selection Cards
                Column(
                  children: [
                    Row(
                      children: [
                        // Sales Mode
                        Expanded(
                          child: _ModeCard(
                            title: 'หน้าขาย',
                            subtitle: 'ระบบขายสินค้า',
                            icon: Icons.point_of_sale,
                            color: Colors.blue,
                            onTap: () {
                              Navigator.pushReplacementNamed(context, '/pos');
                            },
                          ),
                        ),

                        const SizedBox(width: 20),

                        // Backend Management Mode
                        Expanded(
                          child: _ModeCard(
                            title: 'จัดการหลังบ้าน',
                            subtitle: 'ระบบจัดการข้อมูล',
                            icon: Icons.admin_panel_settings,
                            color: Colors.green,
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                  context, '/backend');
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Dashboard Mode
                    SizedBox(
                      width: 180,
                      child: _ModeCard(
                        title: 'แดชบอร์ด',
                        subtitle: 'ภาพรวมระบบ',
                        icon: Icons.dashboard,
                        color: Colors.purple,
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/dashboard');
                        },
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
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ModeCard({
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 6),

              // Subtitle
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
