import '../di/injector.dart';
import '../../features/stock/models/product_model.dart';
import '../../features/stock/repositories/product_repository.dart';
import '../../features/categories/services/category_service_interface.dart';

class SampleData {
  static Future<void> seedProducts() async {
    final productRepository = getIt<ProductRepository>();

    // ตรวจสอบว่ามีสินค้าอยู่แล้วหรือไม่
    final existingProducts = await productRepository.getAllProducts();
    existingProducts.fold(
      (failure) =>
          print('Error checking existing products: ${failure.message}'),
      (products) async {
        if (products.isNotEmpty) {
          print(
              'Products already exist (${products.length} items). Skipping seed.');
          return;
        }

        // ดึงข้อมูลหมวดหมู่ที่มีอยู่
        final categoryService = getIt<ICategoryService>();
        final categories = await categoryService.getAllCategories();
        final categoryMap = <String, int>{};

        for (final category in categories) {
          categoryMap[category.name] = category.id!;
        }

        // สร้างข้อมูลสินค้าตัวอย่าง
        final sampleProducts = _createSampleProducts(categoryMap);

        print('Seeding ${sampleProducts.length} sample products...');

        for (final product in sampleProducts) {
          final result = await productRepository.insertProduct(product);
          result.fold(
            (failure) =>
                print('Failed to insert ${product.name}: ${failure.message}'),
            (id) => print('Successfully inserted ${product.name} with ID: $id'),
          );
        }

        print('Sample products seeding completed!');
      },
    );
  }

  static List<ProductModel> _createSampleProducts(
      Map<String, int> categoryMap) {
    final now = DateTime.now();

    return [
      // อุปกรณ์อิเล็กทรอนิกส์
      ProductModel(
        productCode: 'ELE001',
        name: 'iPhone 15 Pro',
        description: 'สมาร์ทโฟน iPhone 15 Pro ความจุ 128GB สี Natural Titanium',
        price: 39900.0,
        cost: 35000.0,
        stockQuantity: 15,
        minStockLevel: 5,
        category: 'อิเล็กทรอนิกส์',
        categoryId: categoryMap['อิเล็กทรอนิกส์'],
        barcode: '1234567890123',
        imageUrls: [],
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      ProductModel(
        productCode: 'ELE002',
        name: 'Samsung Galaxy S24',
        description:
            'สมาร์ทโฟน Samsung Galaxy S24 ความจุ 256GB สี Phantom Black',
        price: 29900.0,
        cost: 25000.0,
        stockQuantity: 12,
        minStockLevel: 3,
        category: 'อิเล็กทรอนิกส์',
        categoryId: categoryMap['อิเล็กทรอนิกส์'],
        barcode: '2345678901234',
        imageUrls: [],
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      ProductModel(
        productCode: 'ELE003',
        name: 'MacBook Air M2',
        description: 'แล็ปท็อป MacBook Air ชิป M2 หน้าจอ 13 นิ้ว ความจุ 256GB',
        price: 42900.0,
        cost: 38000.0,
        stockQuantity: 8,
        minStockLevel: 2,
        category: 'อิเล็กทรอนิกส์',
        categoryId: categoryMap['อิเล็กทรอนิกส์'],
        barcode: '3456789012345',
        imageUrls: [],
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      ProductModel(
        productCode: 'ELE004',
        name: 'iPad Pro 11"',
        description: 'แท็บเล็ต iPad Pro หน้าจอ 11 นิ้ว ชิป M2 ความจุ 128GB',
        price: 31900.0,
        cost: 28000.0,
        stockQuantity: 10,
        minStockLevel: 3,
        category: 'อิเล็กทรอนิกส์',
        categoryId: categoryMap['อิเล็กทรอนิกส์'],
        barcode: '4567890123456',
        imageUrls: [],
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      ProductModel(
        productCode: 'ELE005',
        name: 'AirPods Pro 2',
        description:
            'หูฟังไร้สาย AirPods Pro รุ่นที่ 2 พร้อม Active Noise Cancellation',
        price: 8990.0,
        cost: 7500.0,
        stockQuantity: 25,
        minStockLevel: 10,
        category: 'อิเล็กทรอนิกส์',
        categoryId: categoryMap['อิเล็กทรอนิกส์'],
        barcode: '5678901234567',
        imageUrls: [],
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      // เสื้อผ้า
      ProductModel(
        productCode: 'CLO001',
        name: 'เสื้อยืดคอกลม',
        description: 'เสื้อยืดคอกลมผ้าคอตตอน 100% สีขาว ไซส์ M',
        price: 299.0,
        cost: 150.0,
        stockQuantity: 50,
        minStockLevel: 20,
        category: 'เสื้อผ้า',
        categoryId: categoryMap['เสื้อผ้า'],
        barcode: '6789012345678',
        imageUrls: [],
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      ProductModel(
        productCode: 'CLO002',
        name: 'กางเกงยีนส์',
        description: 'กางเกงยีนส์ขายาวสีน้ำเงิน ไซส์ 32 ทรงสลิม',
        price: 1290.0,
        cost: 800.0,
        stockQuantity: 30,
        minStockLevel: 10,
        category: 'เสื้อผ้า',
        categoryId: categoryMap['เสื้อผ้า'],
        barcode: '7890123456789',
        imageUrls: [],
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      ProductModel(
        productCode: 'CLO003',
        name: 'เสื้อเชิ้ตแขนยาว',
        description: 'เสื้อเชิ้ตแขนยาวผ้าคอตตอนสีฟ้าอ่อน ไซส์ L',
        price: 890.0,
        cost: 500.0,
        stockQuantity: 20,
        minStockLevel: 5,
        category: 'เสื้อผ้า',
        categoryId: categoryMap['เสื้อผ้า'],
        barcode: '8901234567890',
        imageUrls: [],
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      // อาหารและเครื่องดื่ม
      ProductModel(
        productCode: 'FOD001',
        name: 'กาแฟ Americano',
        description: 'กาแฟ Americano เข้มข้น หอมกรุ่น ขนาด 16 oz',
        price: 85.0,
        cost: 35.0,
        stockQuantity: 100,
        minStockLevel: 50,
        category: 'อาหารและเครื่องดื่ม',
        categoryId: categoryMap['อาหารและเครื่องดื่ม'],
        barcode: '9012345678901',
        imageUrls: [],
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      ProductModel(
        productCode: 'FOD002',
        name: 'น้ำแร่',
        description: 'น้ำแร่ธรรมชาติ ขนาด 500ml',
        price: 15.0,
        cost: 8.0,
        stockQuantity: 200,
        minStockLevel: 100,
        category: 'อาหารและเครื่องดื่ม',
        categoryId: categoryMap['อาหารและเครื่องดื่ม'],
        barcode: '0123456789012',
        imageUrls: [],
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      ProductModel(
        productCode: 'FOD003',
        name: 'แซนด์วิชทูน่า',
        description: 'แซนด์วิชทูน่าสดใหม่พร้อมผักสลัด',
        price: 95.0,
        cost: 45.0,
        stockQuantity: 20,
        minStockLevel: 10,
        category: 'อาหารและเครื่องดื่ม',
        categoryId: categoryMap['อาหารและเครื่องดื่ม'],
        barcode: '1357924680135',
        imageUrls: [],
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      // ของใช้ในบ้าน
      ProductModel(
        productCode: 'HOM001',
        name: 'ผ้าเช็ดตัว',
        description: 'ผ้าเช็ดตัวผ้าฝ้าย 100% ขนาด 70x140 ซม. สีขาว',
        price: 450.0,
        cost: 250.0,
        stockQuantity: 40,
        minStockLevel: 15,
        category: 'ของใช้ในบ้าน',
        categoryId: categoryMap['ของใช้ในบ้าน'],
        barcode: '2468135792468',
        imageUrls: [],
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      ProductModel(
        productCode: 'HOM002',
        name: 'หมอนนอน',
        description: 'หมอนนอนใยโพลีเอสเตอร์ นุ่มสบาย ขนาดมาตรฐาน',
        price: 350.0,
        cost: 200.0,
        stockQuantity: 25,
        minStockLevel: 10,
        category: 'ของใช้ในบ้าน',
        categoryId: categoryMap['ของใช้ในบ้าน'],
        barcode: '3691472583691',
        imageUrls: [],
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      ProductModel(
        productCode: 'HOM003',
        name: 'แก้วน้ำ',
        description: 'แก้วน้ำแก้วใส ความจุ 300ml แพ็ค 6 ใบ',
        price: 180.0,
        cost: 100.0,
        stockQuantity: 60,
        minStockLevel: 20,
        category: 'ของใช้ในบ้าน',
        categoryId: categoryMap['ของใช้ในบ้าน'],
        barcode: '4815926374815',
        imageUrls: [],
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      // ของเล่น
      ProductModel(
        productCode: 'TOY001',
        name: 'ตุ๊กตาหมี',
        description: 'ตุ๊กตาหมีผ้านุ่ม สีน้ำตาล ขนาด 30 ซม.',
        price: 590.0,
        cost: 300.0,
        stockQuantity: 15,
        minStockLevel: 5,
        category: 'ของเล่น',
        categoryId: categoryMap['ของเล่น'],
        barcode: '5927384061592',
        imageUrls: [],
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      ProductModel(
        productCode: 'TOY002',
        name: 'รถของเล่น',
        description: 'รถของเล่นโลหะ สีแดง มีเสียงและไฟ',
        price: 250.0,
        cost: 150.0,
        stockQuantity: 30,
        minStockLevel: 10,
        category: 'ของเล่น',
        categoryId: categoryMap['ของเล่น'],
        barcode: '6048517392604',
        imageUrls: [],
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      // เครื่องเขียน
      ProductModel(
        productCode: 'STA001',
        name: 'ปากกาลูกลื่น',
        description: 'ปากกาลูกลื่นสีน้ำเงิน หมึกเจล แพ็ค 10 ด้าม',
        price: 120.0,
        cost: 70.0,
        stockQuantity: 80,
        minStockLevel: 30,
        category: 'เครื่องเขียน',
        categoryId: categoryMap['เครื่องเขียน'],
        barcode: '7159263847159',
        imageUrls: [],
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      ProductModel(
        productCode: 'STA002',
        name: 'สมุดโน้ต',
        description: 'สมุดโน้ตปกแข็ง 200 หน้า ลายเส้น',
        price: 85.0,
        cost: 45.0,
        stockQuantity: 50,
        minStockLevel: 20,
        category: 'เครื่องเขียน',
        categoryId: categoryMap['เครื่องเขียน'],
        barcode: '8260371948260',
        imageUrls: [],
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      // สุขภาพและความงาม
      ProductModel(
        productCode: 'HEA001',
        name: 'ครีมกันแดด',
        description: 'ครีมกันแดด SPF 50+ ป้องกัน UVA/UVB ขนาด 50ml',
        price: 320.0,
        cost: 180.0,
        stockQuantity: 35,
        minStockLevel: 15,
        category: 'สุขภาพและความงาม',
        categoryId: categoryMap['สุขภาพและความงาม'],
        barcode: '9371482059371',
        imageUrls: [],
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      ProductModel(
        productCode: 'HEA002',
        name: 'แชมพูสำหรับผมธรรมดา',
        description: 'แชมพูสำหรับผมธรรมดา สูตรอ่อนโยน ขนาด 400ml',
        price: 180.0,
        cost: 100.0,
        stockQuantity: 45,
        minStockLevel: 20,
        category: 'สุขภาพและความงาม',
        categoryId: categoryMap['สุขภาพและความงาม'],
        barcode: '0482593617048',
        imageUrls: [],
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
