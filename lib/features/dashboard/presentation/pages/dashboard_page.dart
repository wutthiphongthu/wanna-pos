import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar (Blue Background)
            // _buildTopNavigationBar(),

            // // Central Content Area (Blue Background with Pattern)
            // _buildCentralContent(),

            // Lower Content Area (White Background with Statistics)
            Expanded(
              child: SingleChildScrollView(
                child: _buildLowerContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavigationBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.blue[700],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Left Side
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.menu, color: Colors.white, size: 24),
              ),
              const Icon(Icons.keyboard_arrow_down,
                  color: Colors.white, size: 20),
              const SizedBox(width: 16),
              const Text(
                'แดชบอร์ด',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Right Side Icons
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon:
                    const Icon(Icons.grid_view, color: Colors.white, size: 20),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.location_on,
                    color: Colors.white, size: 20),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications,
                    color: Colors.white, size: 20),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 8),
              const Text(
                'วุฒิพงษ์ ทุมมานาม',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              const Icon(Icons.keyboard_arrow_down,
                  color: Colors.white, size: 16),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.flag, color: Colors.white, size: 20),
              ),
              IconButton(
                onPressed: () {},
                icon:
                    const Icon(Icons.camera_alt, color: Colors.white, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCentralContent() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[600]!,
            Colors.blue[700]!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Left Card (Orange, Cloud-shaped)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange[400],
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'วรรณา มินิมาร์ท',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'จำหน่าย สินค้าอุปโภค บริโภค',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange[100],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 24),
                // Right Text and Search Bar
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'วรรณามินิมาร์ท',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue[500],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Smart (111 วัน) | POS: POS #1 | ขายปลีก',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue[100],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search,
                                color: Colors.grey, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'ค้นหาเมนู',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down,
                                color: Colors.grey),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Action Buttons
            SizedBox(
              height: 60,
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                        'ขาย', Icons.shopping_cart, Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                        'รับซื้อ', Icons.receipt, Colors.purple),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                        'สต็อก', Icons.inventory, Colors.pink),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                        'รายงาน', Icons.analytics, Colors.green),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                        'ลูกค้า', Icons.people, Colors.amber,
                        isSelected: true),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                        'นำเข้า', Icons.file_download, Colors.lightBlue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                        'เอกสาร', Icons.description, Colors.indigo),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child:
                        _buildActionButton('กิจกรรม', Icons.event, Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color,
      {bool isSelected = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? Border.all(color: color, width: 2) : null,
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? color.withOpacity(0.2)
                    : Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLowerContent() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sales Date Bar (Light Blue)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[100]!, Colors.blue[200]!],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[300]!),
            ),
            child: Row(
              children: [
                Row(
                  children: [
                    Icon(Icons.today, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'ยอดขายวันนี้ 28/08/2025 17:29',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[800],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                _buildSmallButton('ขาย', Colors.blue[700]!),
                const SizedBox(width: 12),
                _buildSmallButton('รับซื้อ', Colors.blue[700]!),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Filter/Selection Bar (White)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.business,
                          color: Colors.blue, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '(สำนักงานใหญ่) วรรณามินิมาร์ท',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down,
                        color: Colors.grey, size: 20),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.people,
                          color: Colors.green, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'พนักงานทั้งหมด',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down,
                        color: Colors.grey, size: 20),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Sales Statistics Card (White)
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with Filter and Summary
                  Row(
                    children: [
                      // Filter Section
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.filter_list,
                                color: Colors.blue[600],
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'เมื่อวาน',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[700],
                                ),
                              ),
                              const Spacer(),
                              Icon(Icons.keyboard_arrow_down,
                                  color: Colors.blue[600], size: 20),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 20),

                      // Summary Info
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.trending_up,
                              color: Colors.green[600],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'สรุปยอดขาย',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Main Statistics Row
                  Row(
                    children: [
                      // Total Sales (Large)
                      Expanded(
                        flex: 2,
                        child: _buildMainStatCard(
                          'ยอดรวม',
                          '฿3,586.00',
                          Icons.attach_money,
                          Colors.blue,
                          subtitle: 'ยอดขายรวมทั้งหมด',
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Growth Rate (Large)
                      Expanded(
                        flex: 2,
                        child: _buildMainStatCard(
                          'การเติบโต',
                          '-36%',
                          Icons.trending_down,
                          Colors.red,
                          subtitle: 'เทียบกับวันก่อนหน้า',
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Currency Selector
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.attach_money,
                                    color: Colors.blue, size: 20),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'สกุลเงิน',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Thai Baht',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down,
                                  color: Colors.grey, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Secondary Statistics Row
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildSecondaryStatCard(
                            'บิลยกเลิก',
                            '0',
                            Icons.cancel,
                            Colors.grey,
                            subtitle: 'รายการที่ยกเลิก',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSecondaryStatCard(
                            'บิลขาย',
                            '62',
                            Icons.receipt,
                            Colors.blue,
                            subtitle: 'รายการขายสำเร็จ',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSecondaryStatCard(
                            'เฉลี่ย/บิล',
                            '฿57.84',
                            Icons.analytics,
                            Colors.green,
                            subtitle: 'ยอดเฉลี่ยต่อบิล',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSecondaryStatCard(
                            'ลูกค้าใหม่',
                            '8',
                            Icons.person_add,
                            Colors.orange,
                            subtitle: 'ลูกค้าใหม่วันนี้',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSecondaryStatCard(
                            'สินค้าขายดี',
                            '15',
                            Icons.star,
                            Colors.purple,
                            subtitle: 'สินค้าขายดี',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallButton(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMainStatCard(
      String title, String value, IconData icon, Color color,
      {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              if (subtitle != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryStatCard(
      String title, String value, IconData icon, Color color,
      {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const Spacer(),
              if (subtitle != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 9,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
