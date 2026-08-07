import 'package:flutter/material.dart';
import 'avatar_store_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool hasFreeAvatarGenerated = false;
  String currentAvatarPreset = "Default";
  int userCoins = 10000;

  void _simulateAvatarGeneration() {
    final int cost = hasFreeAvatarGenerated ? 100 : 0;

    if (userCoins < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('عذراً، رصيدك غير كافٍ لتعديل الصورة الرمزية ثلاثية الأبعاد!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Color(0xFF1E1A2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent)),
                SizedBox(height: 20),
                Text(
                  'جاري تحليل الصورة والملامح ومطابقة الصورة الرمزية ثلاثية الأبعاد...',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Cairo'),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );

    // Simulate AI generation delay
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pop(context); // Close loading dialog
      setState(() {
        userCoins -= cost;
        hasFreeAvatarGenerated = true;
        currentAvatarPreset = "Cyberpunk AI Likeness";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cost == 0
              ? 'تهانينا! تم توليد صورتك الرمزية ثلاثية الأبعاد الأولى مجاناً بنجاح!'
              : 'تم تحديث الرمزية ثلاثية الأبعاد بنجاح، وخصم 100 عملة.'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

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
                    GestureDetector(
                      onTap: _simulateAvatarGeneration,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                          ),
                          Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(color: Colors.cyan, shape: BoxShape.circle),
                            child: Icon(Icons.add_a_photo, size: 10, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // AI Likeness Avatar Customization Banner
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF12005E)]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.cyan.withOpacity(0.3), blurRadius: 10, spreadRadius: 1),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.face_retouching_natural, color: Colors.white, size: 30),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'توليد رمزيتك ثلاثية الأبعاد بالذكاء الاصطناعي',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Cairo'),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'النمط الحالي: $currentAvatarPreset',
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: _simulateAvatarGeneration,
                      child: Text(
                        hasFreeAvatarGenerated ? 'تحديث (🪙100)' : 'توليد (مجاني)',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                      ),
                    ),
                  ],
                ),
              ),

              // قسم التأثيرات والرتبة والعرش
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              SizedBox(height: 10),

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
              _buildMenuItem(Icons.card_giftcard, 'ادعو الأصدقاء', () {}),
              _buildMenuItem(Icons.military_tech, 'ميدالية', () {}),
              _buildMenuItem(Icons.store, 'المتجر (Avatar Store)', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AvatarStoreScreen()),
                );
              }),
              _buildMenuItem(Icons.checkroom, 'عناصر خاصتي', () {}),
              _buildMenuItem(Icons.chat_bubble_outline, 'ملاحظات', () {}),
              _buildMenuItem(Icons.settings, 'الإعدادات', () {}),
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

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
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
        ),
      ),
    );
  }
}
