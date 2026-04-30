import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/utils/theme.dart';
import '../bloc/member_bloc.dart';
import '../models/member_model.dart';
import '../widgets/redeem_points_dialog.dart';
import 'member_form_page.dart';

class MemberListPage extends StatelessWidget {
  const MemberListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<MemberBloc>()..add(const LoadMembers()),
      child: const _MemberListPageView(),
    );
  }
}

class _MemberListPageView extends StatefulWidget {
  const _MemberListPageView();

  @override
  State<_MemberListPageView> createState() => _MemberListPageViewState();
}

class _MemberListPageViewState extends State<_MemberListPageView> {
  final _searchController = TextEditingController();
  bool _showActiveOnly = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('จัดการสมาชิก'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChip(),
          Expanded(child: _buildMemberList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        tooltip: 'เพิ่มสมาชิก',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'ค้นหาสมาชิก (ชื่อ, รหัส, เบอร์โทร, อีเมล)...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<MemberBloc>().add(const ClearMemberSearch());
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            context.read<MemberBloc>().add(SearchMembersEvent(value));
          } else {
            context.read<MemberBloc>().add(const ClearMemberSearch());
          }
        },
      ),
    );
  }

  Widget _buildFilterChip() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          FilterChip(
            label: Text(_showActiveOnly ? 'เฉพาะที่เปิดใช้งาน' : 'ทั้งหมด'),
            selected: true,
            onSelected: (selected) {
              setState(() => _showActiveOnly = !_showActiveOnly);
              if (_showActiveOnly) {
                context.read<MemberBloc>().add(const LoadMembers());
              } else {
                context.read<MemberBloc>().add(const LoadAllMembers());
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMemberList() {
    return BlocConsumer<MemberBloc, MemberState>(
      listener: (context, state) {
        if (state is MemberOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
        } else if (state is MemberOperationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is MemberLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is MemberError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 48, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(state.message, textAlign: TextAlign.center),
              ],
            ),
          );
        }
        final members = state is MemberLoaded ? state.members : <MemberModel>[];
        if (members.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'ยังไม่มีสมาชิก',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _navigateToForm(),
                  icon: const Icon(Icons.add),
                  label: const Text('เพิ่มสมาชิก'),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final m = members[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                  child: Text(
                    m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('รหัส: ${m.memberCode}'),
                    if (m.phone != null && m.phone!.isNotEmpty)
                      Text('โทร: ${m.phone}'),
                    Row(
                      children: [
                        Text(
                          '${m.points} คะแนน',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            m.membershipLevel,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) => _handleMenuAction(v, m),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('แก้ไข')),
                    const PopupMenuItem(value: 'redeem', child: Text('แลกคะแนน')),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('ลบ', style: TextStyle(color: Colors.red[700])),
                    ),
                  ],
                ),
                onTap: () => _navigateToForm(member: m),
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToForm({MemberModel? member}) {
    final bloc = context.read<MemberBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: MemberFormPage(member: member),
        ),
      ),
    ).then((_) {
      if (!context.mounted) return;
      if (_showActiveOnly) {
        context.read<MemberBloc>().add(const LoadMembers());
      } else {
        context.read<MemberBloc>().add(const LoadAllMembers());
      }
    });
  }

  void _handleMenuAction(String action, MemberModel member) {
    switch (action) {
      case 'edit':
        _navigateToForm(member: member);
        break;
      case 'redeem':
        RedeemPointsDialog.show(context, member).then((_) {
          if (!context.mounted) return;
          if (_showActiveOnly) {
            context.read<MemberBloc>().add(const LoadMembers());
          } else {
            context.read<MemberBloc>().add(const LoadAllMembers());
          }
        });
        break;
      case 'delete':
        _showDeleteConfirm(member);
        break;
    }
  }

  void _showDeleteConfirm(MemberModel member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('คุณต้องการลบสมาชิก "${member.name}" หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<MemberBloc>().add(DeleteMemberEvent(member));
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }
}
