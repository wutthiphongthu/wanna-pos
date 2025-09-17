import 'package:flutter/material.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // Thai product data with dummy images
    final products = [
      {
        'id': 1,
        'name': 'สินค้าอันๆ 120บ',
        'price': 120.0,
        'image': 'https://picsum.photos/120/120?random=1'
      },
      {
        'id': 2,
        'name': 'สินค้าอันๆ 2บ',
        'price': 2.0,
        'image': 'https://picsum.photos/120/120?random=2'
      },
      {
        'id': 3,
        'name': 'สินค้าอันๆ 5บ',
        'price': 5.0,
        'image': 'https://picsum.photos/120/120?random=3'
      },
      {
        'id': 4,
        'name': 'สินค้าอันๆ 9บ',
        'price': 9.0,
        'image': 'https://picsum.photos/120/120?random=4'
      },
      {
        'id': 5,
        'name': 'สินค้าอันๆ 10บ',
        'price': 10.0,
        'image': 'https://picsum.photos/120/120?random=5'
      },
      {
        'id': 6,
        'name': 'สินค้าอันๆ 12บ',
        'price': 12.0,
        'image': 'https://picsum.photos/120/120?random=6'
      },
      {
        'id': 7,
        'name': 'สินค้าอันๆ 15บ',
        'price': 15.0,
        'image': 'https://picsum.photos/120/120?random=7'
      },
      {
        'id': 8,
        'name': 'สินค้าอันๆ 20บ',
        'price': 20.0,
        'image': 'https://picsum.photos/120/120?random=8'
      },
    ];

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

        return ProductCard(
          id: product['id'] as int,
          name: product['name'] as String,
          price: product['price'] as double,
          imageUrl: product['image'] as String,
        );
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final int id;
  final String name;
  final double price;
  final String imageUrl;

  const ProductCard({
    super.key,
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Add product to cart
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added $name to cart'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  imageUrl,
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
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.grey),
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

            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
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
                      '฿${price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
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
