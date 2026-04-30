import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/sync/sync_manager.dart';
import '../../../../core/utils/theme.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../auth/bloc/auth_event.dart';
import '../../../auth/bloc/auth_state.dart';

class POSMenuDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onSelectMenu;

  const POSMenuDrawer({
    super.key,
    this.selectedIndex = 0,
    this.onSelectMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header: แสดงร้านและบทบาทผู้ใช้
          BlocBuilder<AuthBloc, AuthState>(
            buildWhen: (prev, curr) => curr is AuthAuthenticated,
            builder: (context, state) {
              final isOwner = state is AuthAuthenticated && state.isOwner;
              final roleLabel = state is AuthAuthenticated
                  ? (isOwner ? 'เจ้าของร้าน' : 'พนักงานขาย')
                  : '';
              final storeName =
                  state is AuthAuthenticated ? state.storeName : '';
              final userFullName =
                  state is AuthAuthenticated ? state.userFullName : '';
              return Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 24,
                  bottom: 24,
                  left: 24,
                  right: 24,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PPOS',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (storeName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        storeName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                    if (userFullName.isNotEmpty || roleLabel.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        '$userFullName · $roleLabel',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ] else
                      Text(
                        'ระบบขายจุดขาย',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _DrawerMenuItem(
                  icon: Icons.point_of_sale,
                  title: 'หน้าขาย',
                  subtitle: 'ระบบขายสินค้า',
                  isSelected: selectedIndex == 0,
                  onTap: () => _selectAndClose(context, 0),
                ),
                _DrawerMenuItem(
                  icon: Icons.admin_panel_settings,
                  title: 'จัดการหลังบ้าน',
                  subtitle: 'ระบบจัดการข้อมูล',
                  isSelected: selectedIndex == 1,
                  onTap: () => _selectAndClose(context, 1),
                ),
                _DrawerMenuItem(
                  icon: Icons.dashboard,
                  title: 'แดชบอร์ด',
                  subtitle: 'ภาพรวมระบบ',
                  isSelected: selectedIndex == 2,
                  onTap: () => _selectAndClose(context, 2),
                ),
                _DrawerMenuItem(
                  icon: Icons.inventory_2,
                  title: 'สินค้าและสต็อก',
                  subtitle: 'จัดการสินค้าและคลัง',
                  isSelected: selectedIndex == 3,
                  onTap: () => _selectAndClose(context, 3),
                ),
                _DrawerMenuItem(
                  icon: Icons.people_alt,
                  title: 'CRM',
                  subtitle: 'ลูกค้า ลีด โอกาสขาย',
                  isSelected: selectedIndex == 4,
                  onTap: () => _selectAndClose(context, 4),
                ),
              ],
            ),
          ),

          // Footer - Sync + Logout
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.sync, color: Colors.grey[600]),
            title: Text(
              'ซิงก์ข้อมูล',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'ดึง/ส่งสินค้ากับคลาวด์',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            onTap: () async {
              final messenger = ScaffoldMessenger.maybeOf(context);
              Navigator.pop(context);
              await getIt<SyncManager>().syncAllManual();
              messenger?.showSnackBar(
                const SnackBar(
                  content: Text('ซิงก์เสร็จแล้ว (หรือออฟไลน์)'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.grey[600]),
            title: Text(
              'ออกจากระบบ',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  void _selectAndClose(BuildContext context, int index) {
    onSelectMenu?.call(index);
    Navigator.pop(context);
  }

  void _showLogoutDialog(BuildContext context) {
    // เก็บ AuthBloc ก่อน (context ของ Drawer ยังใช้ได้ตอนนี้)
    final authBloc = context.read<AuthBloc>();
    // แสดง dialog ก่อน ไม่ปิด drawer ก่อน เพราะปิดแล้ว context จะถูก dispose แล้ว showDialog จะผิดพลาด
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ออกจากระบบ'),
        content: const Text('คุณต้องการออกจากระบบใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              authBloc.add(LogoutRequested());
            },
            child: const Text(
              'ออกจากระบบ',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.2)
              : AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      onTap: onTap,
    );
  }
}
