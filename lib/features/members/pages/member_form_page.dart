import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/theme.dart';
import '../../../../core/utils/constants.dart';
import '../bloc/member_bloc.dart';
import '../models/member_model.dart';

class MemberFormPage extends StatelessWidget {
  final MemberModel? member;

  const MemberFormPage({super.key, this.member});

  @override
  Widget build(BuildContext context) {
    return BlocListener<MemberBloc, MemberState>(
      listener: (context, state) {
        if (state is MemberOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        } else if (state is MemberOperationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: _MemberFormPageContent(member: member),
    );
  }
}

class _MemberFormPageContent extends StatefulWidget {
  final MemberModel? member;

  const _MemberFormPageContent({this.member});

  @override
  State<_MemberFormPageContent> createState() => _MemberFormPageContentState();
}

class _MemberFormPageContentState extends State<_MemberFormPageContent> {
  final _formKey = GlobalKey<FormState>();
  final _memberCodeController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _membershipLevel = AppConstants.membershipLevels.first;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.member != null) {
      _populateForm();
    } else {
      _memberCodeController.text = _generateMemberCode();
    }
  }

  String _generateMemberCode() {
    final now = DateTime.now();
    return 'M${now.millisecondsSinceEpoch % 100000}';
  }

  void _populateForm() {
    final m = widget.member!;
    _memberCodeController.text = m.memberCode;
    _nameController.text = m.name;
    _emailController.text = m.email ?? '';
    _phoneController.text = m.phone ?? '';
    _membershipLevel = m.membershipLevel;
    _isActive = m.isActive;
  }

  @override
  void dispose() {
    _memberCodeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.member == null ? 'เพิ่มสมาชิก' : 'แก้ไขสมาชิก'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text('บันทึก', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _memberCodeController,
                decoration: const InputDecoration(
                  labelText: 'รหัสสมาชิก *',
                  hintText: 'เช่น M001',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'กรุณากรอกรหัสสมาชิก' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'ชื่อ-นามสกุล *',
                  hintText: 'กรอกชื่อสมาชิก',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'กรุณากรอกชื่อ' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'เบอร์โทรศัพท์',
                  hintText: 'เช่น 0812345678',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'อีเมล',
                  hintText: 'เช่น member@example.com',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _membershipLevel,
                decoration: const InputDecoration(
                  labelText: 'ระดับสมาชิก',
                  border: OutlineInputBorder(),
                ),
                items: AppConstants.membershipLevels
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (v) => setState(() => _membershipLevel = v ?? _membershipLevel),
              ),
              const SizedBox(height: 32),
              SwitchListTile(
                title: const Text('เปิดใช้งาน'),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final now = DateTime.now();
    final model = MemberModel(
      id: widget.member?.id,
      memberCode: _memberCodeController.text.trim(),
      name: _nameController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      membershipLevel: _membershipLevel,
      points: widget.member?.points ?? 0,
      isActive: _isActive,
      createdAt: widget.member?.createdAt ?? now,
      updatedAt: now,
    );

    if (widget.member == null) {
      context.read<MemberBloc>().add(CreateMemberEvent(model));
    } else {
      context.read<MemberBloc>().add(UpdateMemberEvent(model));
    }
  }
}
