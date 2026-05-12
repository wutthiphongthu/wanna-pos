import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../stock/bloc/product_bloc.dart';
import '../../../stock/bloc/product_state.dart';
import '../../services/pinned_products_service.dart';
import '../bloc/pos_bloc.dart';
import '../../../stock/models/product_model.dart';

class ProductGrid extends StatefulWidget {
  /// ข้อความค้นหาในหน้าขาย — กรองจากชื่อ, รหัสสินค้า, บาร์โค้ด, ชื่อรอง, รหัสบาร์โค้ดกำหนดเอง
  final String searchQuery;

  const ProductGrid({super.key, this.searchQuery = ''});

  @override
  State<ProductGrid> createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  final _pinnedService = getIt<PinnedProductsService>();
  List<int> _pinnedIds = [];

  @override
  void initState() {
    super.initState();
    _loadPins();
  }

  List<ProductModel> _filterForPosSearch(List<ProductModel> all, String query) {
    final t = query.trim().toLowerCase();
    if (t.isEmpty) return all;
    bool match(ProductModel p) {
      if (p.name.toLowerCase().contains(t)) return true;
      if (p.productCode.toLowerCase().contains(t)) return true;
      final bc = p.barcode;
      if (bc != null && bc.trim().isNotEmpty && bc.toLowerCase().contains(t)) {
        return true;
      }
      final sub = p.productSubname;
      if (sub != null && sub.trim().isNotEmpty && sub.toLowerCase().contains(t)) {
        return true;
      }
      final custom = p.customBarcodeId;
      if (custom != null && custom.trim().isNotEmpty && custom.toLowerCase().contains(t)) {
        return true;
      }
      return false;
    }

    return all.where(match).toList();
  }

  Future<void> _loadPins() async {
    final ids = await _pinnedService.getPinnedProductIds();
    if (mounted) setState(() => _pinnedIds = ids);
  }

  List<ProductModel> _orderedProducts(List<ProductModel> all) {
    final byId = <int, ProductModel>{};
    for (final p in all) {
      if (p.id != null) byId[p.id!] = p;
    }
    final pinned = <ProductModel>[];
    final seen = <int>{};
    for (final id in _pinnedIds) {
      final p = byId[id];
      if (p != null) {
        pinned.add(p);
        seen.add(id);
      }
    }
    final rest = <ProductModel>[];
    for (final p in all) {
      if (p.id == null || !seen.contains(p.id)) {
        rest.add(p);
      }
    }
    return [...pinned, ...rest];
  }

  Future<void> _onTogglePin(int? productId) async {
    if (productId == null) return;
    await _pinnedService.togglePin(productId: productId);
    await _loadPins();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductBloc, ProductState>(
      listenWhen: (prev, curr) => curr is ProductLoaded,
      listener: (context, state) {
        _loadPins();
      },
      child: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final raw = state is ProductLoaded ? state.products : <ProductModel>[];
          final filtered = _filterForPosSearch(raw, widget.searchQuery);
          final products = _orderedProducts(filtered);
          final hasSearch = widget.searchQuery.trim().isNotEmpty;

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    hasSearch ? Icons.search_off : Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    hasSearch && raw.isNotEmpty
                        ? 'ไม่พบสินค้าที่ตรงกับการค้นหา'
                        : 'ยังไม่มีสินค้า',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final isPinned = product.id != null && _pinnedIds.contains(product.id);
              return ProductCard(
                product: product,
                isPinned: isPinned,
                onPinTap: () => _onTogglePin(product.id),
                onTap: () {
                  context.read<PosBloc>().add(AddToCart(product));
                },
              );
            },
          );
        },
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final bool isPinned;
  final VoidCallback onPinTap;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.isPinned,
    required this.onPinTap,
    required this.onTap,
  });

  String get _imageUrl {
    if (product.imageUrls.isNotEmpty && product.imageUrls.first.isNotEmpty) {
      return product.imageUrls.first;
    }
    return 'https://picsum.photos/120/120?random=${product.id ?? 0}';
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isPinned ? Border.all(color: primary.withValues(alpha: 0.55), width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      _imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'โหลดรูป...',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                  size: 32,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'ไม่มีรูป',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          NumberFormatter.formatCurrency(product.price),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Material(
                color: Colors.white.withValues(alpha: 0.92),
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: IconButton(
                  tooltip: isPinned ? 'เลิกปักหมุด' : 'ปักหมุดสินค้า',
                  icon: Icon(
                    isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    size: 20,
                    color: isPinned ? primary : Colors.grey[700],
                  ),
                  onPressed: onPinTap,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
