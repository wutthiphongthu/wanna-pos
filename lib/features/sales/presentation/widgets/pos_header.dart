import 'package:flutter/material.dart';

class POSHeader extends StatelessWidget {
  final VoidCallback? onMenuTap;
  final TextEditingController searchController;

  const POSHeader({
    super.key,
    this.onMenuTap,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onMenuTap,
            icon: const Icon(Icons.menu, size: 28),
          ),
          const SizedBox(width: 16),
          Text(
            'Lorem',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: searchController,
                builder: (context, value, _) {
                  return TextField(
                    controller: searchController,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'ค้นหาชื่อสินค้า รหัส หรือบาร์โค้ด...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: value.text.isNotEmpty
                          ? IconButton(
                              tooltip: 'ล้าง',
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                searchController.clear();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 24),
          Builder(
            builder: (context) {
              final scheme = Theme.of(context).colorScheme;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: scheme.primary.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.restaurant, color: scheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Dine In',
                      style: TextStyle(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, color: scheme.primary, size: 20),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
