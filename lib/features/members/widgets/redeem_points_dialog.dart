import 'package:flutter/material.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/number_formatter.dart';
import '../models/member_model.dart';
import '../repositories/member_repository.dart';

/// Dialog to redeem member points for discount.
class RedeemPointsDialog extends StatefulWidget {
  final MemberModel member;

  const RedeemPointsDialog({super.key, required this.member});

  static Future<void> show(BuildContext context, MemberModel member) {
    return showDialog(
      context: context,
      builder: (ctx) => RedeemPointsDialog(member: member),
    );
  }

  @override
  State<RedeemPointsDialog> createState() => _RedeemPointsDialogState();
}

class _RedeemPointsDialogState extends State<RedeemPointsDialog> {
  final _repo = getIt<MemberRepository>();
  final _pointsController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _pointsController.dispose();
    super.dispose();
  }

  double get _discountAmount {
    final pts = int.tryParse(_pointsController.text) ?? 0;
    return pts * AppConstants.bahtPerPoint;
  }

  Future<void> _redeem() async {
    final pts = int.tryParse(_pointsController.text) ?? 0;
    if (pts <= 0) {
      setState(() => _error = 'กรุณาระบุจำนวนคะแนน');
      return;
    }
    if (pts > widget.member.points) {
      setState(() => _error = 'คะแนนไม่เพียงพอ (มี ${widget.member.points} คะแนน)');
      return;
    }
    if (widget.member.id == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await _repo.addPoints(widget.member.id!, -pts);

    if (!mounted) return;
    result.fold(
      (f) => setState(() {
        _loading = false;
        _error = f.message;
      }),
      (_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('แลก $pts คะแนน เป็นส่วนลด ${NumberFormatter.formatCurrency(_discountAmount)} เรียบร้อยแล้ว'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('แลกคะแนน'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${widget.member.name}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'คะแนนคงเหลือ: ${widget.member.points} คะแนน',
              style: TextStyle(color: Colors.grey[700]),
            ),
            Text(
              'อัตราแลก: 1 คะแนน = ${AppConstants.bahtPerPoint} บาท',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pointsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'จำนวนคะแนนที่แลก',
                hintText: '0',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                errorText: _error,
              ),
              onChanged: (_) => setState(() => _error = null),
            ),
            if (int.tryParse(_pointsController.text) != null && _discountAmount > 0) ...[
              const SizedBox(height: 8),
              Text(
                'ส่วนลด: ${NumberFormatter.formatCurrency(_discountAmount)}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('ยกเลิก'),
        ),
        FilledButton(
          onPressed: _loading ? null : _redeem,
          child: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('แลกคะแนน'),
        ),
      ],
    );
  }
}
