import 'package:flutter/material.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/theme.dart';
import '../../../members/models/member_model.dart';
import '../../../members/repositories/member_repository.dart';

/// Dialog to search and select a member for points accumulation.
class MemberSelectorDialog extends StatefulWidget {
  final MemberModel? currentMember;

  const MemberSelectorDialog({super.key, this.currentMember});

  static Future<MemberModel?> show(BuildContext context, {MemberModel? current}) {
    return showDialog<MemberModel>(
      context: context,
      builder: (ctx) => MemberSelectorDialog(currentMember: current),
    );
  }

  @override
  State<MemberSelectorDialog> createState() => _MemberSelectorDialogState();
}

class _MemberSelectorDialogState extends State<MemberSelectorDialog> {
  final _repo = getIt<MemberRepository>();
  final _searchController = TextEditingController();
  final _quickPhoneController = TextEditingController();
  List<MemberModel> _members = [];
  bool _loading = false;
  bool _quickAddLoading = false;
  String _searchTerm = '';

  static String _generateMemberCode() {
    final now = DateTime.now();
    return 'M${now.millisecondsSinceEpoch % 100000}';
  }

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _quickPhoneController.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    setState(() => _loading = true);
    final result = _searchTerm.isEmpty
        ? await _repo.getActiveMembers()
        : await _repo.searchMembers(_searchTerm);
    result.fold(
      (_) => setState(() => _members = []),
      (list) => setState(() => _members = list),
    );
    setState(() => _loading = false);
  }

  Future<void> _quickAddByPhone() async {
    final phone = _quickPhoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกเบอร์โทรศัพท์')),
      );
      return;
    }
    setState(() => _quickAddLoading = true);
    final now = DateTime.now();
    final model = MemberModel(
      memberCode: _generateMemberCode(),
      name: 'ลูกค้า $phone',
      phone: phone,
      membershipLevel: AppConstants.membershipLevels.first,
      points: 0,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
    final result = await _repo.insertMember(model);
    if (!mounted) return;
    setState(() => _quickAddLoading = false);
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message), backgroundColor: Colors.red),
        );
      },
      (newId) {
        final newMember = model.copyWith(id: newId);
        Navigator.pop(context, newMember);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('เลือกลูกค้า'),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // เพิ่มลูกค้าแบบรวดเร็ว (กรอกแค่เบอร์โทร)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person_add, size: 18, color: AppTheme.primaryColor),
                      const SizedBox(width: 6),
                      Text(
                        'เพิ่มลูกค้าแบบรวดเร็ว',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _quickPhoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: 'เบอร์โทรศัพท์',
                            prefixIcon: const Icon(Icons.phone, size: 20),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onSubmitted: (_) => _quickAddByPhone(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: _quickAddLoading ? null : _quickAddByPhone,
                        icon: _quickAddLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.add, size: 20),
                        label: Text(_quickAddLoading ? 'กำลังเพิ่ม...' : 'เพิ่ม'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ค้นหาชื่อ, รหัส, เบอร์โทร...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (v) {
                _searchTerm = v;
                _loadMembers();
              },
            ),
            const SizedBox(height: 12),
            if (widget.currentMember != null) ...[
              Row(
                children: [
                  Icon(Icons.person, color: AppTheme.primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${widget.currentMember!.name} (${widget.currentMember!.points} คะแนน)',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, null),
                    child: const Text('ยกเลิกสมาชิก'),
                  ),
                ],
              ),
              const Divider(),
            ],
            Text(
              'เลือกสมาชิกเพื่อสะสมคะแนน (หรือปิดเพื่อขายแบบไม่ระบุลูกค้า)',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            const Text('รายชื่อสมาชิก', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Flexible(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _members.isEmpty
                      ? Center(
                          child: Text(
                            'ไม่พบสมาชิก',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _members.length,
                          itemBuilder: (_, i) {
                            final m = _members[i];
                            return ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                                child: Text(
                                  m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                                  style: TextStyle(color: AppTheme.primaryColor),
                                ),
                              ),
                              title: Text(m.name),
                              subtitle: Text('${m.memberCode} • ${m.points} คะแนน'),
                              onTap: () => Navigator.pop(context, m),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ปิด (ขายแบบไม่ระบุลูกค้า)'),
        ),
      ],
    );
  }
}
