import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F0B19),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // الهيدر العلوي للملف الشخصي مع صورة المستخدم والـ ID
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                    Spacer(),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('♂', style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(width: 6),
                            Text('Taison Sasa', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 2),
                        Text('ID: 312603557', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    Spacer(),
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                    ),
                  ],
                ),
              ),

              // قسم التأثيرات والرتبة والعرش
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF2A1135), Color(0xFF140D22)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('التأثير: 0', style: TextStyle(color: Colors.amber, fontSize: 13)),
                        SizedBox(height: 5),
                        Text('رتبتي: 100+', style: TextStyle(color: Colors.white, fontSize: 13)),
                      ],
                    ),
                    Spacer(),
                    Icon(Icons.king_bed, color: Colors.amber, size: 45), // رمز العرش الملكي
                  ],
                ),
              ),
              SizedBox(height: 15),

              // عدادات (الأصدقاء، فالو، المتابعون، الزوار)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('0', 'الأصدقاء'),
                  _buildStatItem('2', 'فالو کر رہے ہیں'),
                  _buildStatItem('0', 'المتابعون'),
                  _buildStatItem('1', 'الزوار'),
                ],
              ),
              SizedBox(height: 20),

              // أزرار المحفظة ونبيل
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Color(0xFFFF7043), Color(0xFFFFCA28)]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.account_balance_wallet, color: Colors.white),
                            SizedBox(width: 8),
                            Text('المحفظة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Color(0xFFFFCA28), Color(0xFFFFE082)]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.military_tech, color: Colors.white),
                            SizedBox(width: 8),
                            Text('نبيل', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),

              // بانر الـ VIP
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF7B1FA2), Color(0xFFAB47BC)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.diamond, color: Colors.cyanAccent),
                    SizedBox(width: 10),
                    Text('VIP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 2)),
                  ],
                ),
              ),
              SizedBox(height: 15),

              // قائمة الخيارات (القوائم الشخصية)
              _buildMenuItem(Icons.card_giftcard, 'ادعو الأصدقاء'),
              _buildMenuItem(Icons.military_tech, 'ميدالية'),
              _buildMenuItem(Icons.store, 'المتجر'),
              _buildMenuItem(Icons.checkroom, 'عناصر خاصتي'),
              _buildMenuItem(Icons.chat_bubble_outline, 'ملاحظات'),
              _buildMenuItem(Icons.settings, 'الإعدادات'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(count, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 3),
        Text(label, style: TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Color(0xFF1E1A2E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.pinkAccent, size: 20),
          SizedBox(width: 12),
          Text(title, style: TextStyle(color: Colors.white, fontSize: 14)),
          Spacer(),
          Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
        ],
      ),
    );
  }
}
