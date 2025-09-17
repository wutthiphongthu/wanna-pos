import 'package:flutter/material.dart';

class POSBottomActions extends StatelessWidget {
  const POSBottomActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, -2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // เคลียร์
          Expanded(
            child: POSActionButton(
              icon: Icons.delete_outline,
              label: 'เคลียร์',
              subtitle: '(Ctrl+E)',
              color: Colors.red[600]!,
              onPressed: () {
                // TODO: Clear cart
              },
            ),
          ),

          const SizedBox(width: 12),

          // ลูกค้า
          Expanded(
            child: POSActionButton(
              icon: Icons.person_outline,
              label: 'ลูกค้า',
              subtitle: '(Ctrl+M)',
              color: Colors.blue[600]!,
              onPressed: () {
                // TODO: Select customer
              },
            ),
          ),

          const SizedBox(width: 12),

          // สินค้า
          Expanded(
            child: POSActionButton(
              icon: Icons.qr_code_scanner,
              label: 'สินค้า',
              subtitle: '(Ctrl+O)',
              color: Colors.blue[600]!,
              onPressed: () {
                // TODO: Scan product
              },
            ),
          ),

          const SizedBox(width: 12),

          // พิก
          Expanded(
            child: POSActionButton(
              icon: Icons.shopping_cart_outlined,
              label: 'พิก',
              subtitle: '(Ctrl+P)',
              color: Colors.blue[600]!,
              onPressed: () {
                // TODO: Pick order
              },
            ),
          ),

          const SizedBox(width: 12),

          // สรุป
          Expanded(
            child: POSActionButton(
              icon: Icons.receipt_long_outlined,
              label: 'สรุป',
              subtitle: '',
              color: Colors.blue[600]!,
              onPressed: () {
                // TODO: Show summary
              },
            ),
          ),

          const SizedBox(width: 12),

          // More options
          Expanded(
            child: POSActionButton(
              icon: Icons.more_horiz,
              label: '',
              subtitle: '',
              color: Colors.grey[600]!,
              onPressed: () {
                // TODO: Show more options
              },
            ),
          ),
        ],
      ),
    );
  }
}

class POSActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onPressed;

  const POSActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            border: Border.all(
              color: color == Colors.red ? Colors.red[300]! : Colors.blue[300]!,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                offset: const Offset(0, 2),
                blurRadius: 4,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24,
                color: color,
              ),
              if (label.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (subtitle.isNotEmpty) ...[
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
