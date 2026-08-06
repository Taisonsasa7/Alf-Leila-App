import 'package:flutter/material.dart';

class AvatarStoreScreen extends StatefulWidget {
  @override
  _AvatarStoreScreenState createState() => _AvatarStoreScreenState();
}

class _AvatarStoreScreenState extends State<AvatarStoreScreen> with SingleTickerProviderStateMixin {
  int userCoins = 10000;
  String activeCategory = "Traditional"; // Traditional, Modest, Modern, Tech

  // Sewing machine workshop variables
  bool isTailoringActive = false;
  String tailoringStatusText = "";
  double tailoringProgress = 0.0;
  String selectedPattern = "RoyalGold";
  String selectedColor = "#D4AF37";

  // Wardrobe Items catalog matching backend data models
  final List<Map<String, dynamic>> wardrobeItems = [
    {
      "id": "saudi_thobe",
      "name": "الثوب السعودي الأصيل والشماغ",
      "category": "Traditional",
      "origin": "Saudi Arabia",
      "permPrice": 1500,
      "rentPrice": 300,
      "icon": "👳",
      "description": "ثوب أبيض فاخر مع شماغ أحمر بنقوش قشيبية أصيلة يعبر عن هيبة الخليج."
    },
    {
      "id": "moroccan_caftan",
      "name": "القفطان المغربي المطرز الفاخر",
      "category": "Traditional",
      "origin": "Morocco",
      "permPrice": 2000,
      "rentPrice": 400,
      "icon": "👘",
      "description": "قفطان مغربي مطرز بخيوط الصقلي المذهبة والحرير الفاخر."
    },
    {
      "id": "egyptian_galabiya",
      "name": "الجلابية المصرية الأصيلة",
      "category": "Traditional",
      "origin": "Egypt",
      "permPrice": 1000,
      "rentPrice": 200,
      "icon": "🧥",
      "description": "جلابية صعيدية مصرية مريحة تعبر عن الأصالة والتراث العريق."
    },
    {
      "id": "hijab_abaya",
      "name": "العباية والوشاح المطرز",
      "category": "Modest",
      "origin": "General",
      "permPrice": 1800,
      "rentPrice": 350,
      "icon": "🧕",
      "description": "عباية إسلامية سوداء فاخرة مطرزة بالدانتيل مع خمار متناسق."
    },
    {
      "id": "niqab_khimar",
      "name": "النقاب الملكي والملحفة",
      "category": "Modest",
      "origin": "General",
      "permPrice": 1600,
      "rentPrice": 300,
      "icon": "🎭",
      "description": "نقاب وخمار كامل من قماش الحرير الناعم ومريح للتنفس."
    },
    {
      "id": "formal_suit",
      "name": "البدلة الرسمية الملكية الكلاسيكية",
      "category": "Modern",
      "origin": "General",
      "permPrice": 2200,
      "rentPrice": 450,
      "icon": "👔",
      "description": "بدلة رسمية كلاسيكية فخمة لحضور السهرات والتحديات الكبرى."
    },
    {
      "id": "prop_headphones",
      "name": "سماعات الاستماع الخاص",
      "category": "Tech",
      "origin": "General",
      "permPrice": 3000,
      "rentPrice": 600,
      "icon": "🎧",
      "description": "تتيح تفعيل وضع الاستماع للموسيقى الخاصة بشكل مستقل وسري."
    },
  ];

  void _triggerTailorWorkshop() {
    setState(() {
      isTailoringActive = true;
      tailoringProgress = 0.0;
      tailoringStatusText = "سحب القماش المختار ومطابقة القياسات...";
    });

    // Step-by-step custom tailor machine embroidery animation simulator
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          tailoringProgress = 0.33;
          tailoringStatusText = "تشغيل ماكينة الحياكة والتطريز بالذهب...";
        });
      }
    });

    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          tailoringProgress = 0.66;
          tailoringStatusText = "تطبيق نقشة: $selectedPattern والخياطة...";
        });
      }
    });

    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          tailoringProgress = 1.0;
          tailoringStatusText = "تطبيق الكي والتلميع النهائي للكسوة 3D...";
        });
      }
    });

    Future.delayed(Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          isTailoringActive = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تهانينا! تمت حياكة كسوتك المخصصة بنجاح وإضافتها لخزانتك! 🪡🧵'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _buyItem(Map<String, dynamic> item, bool isPermanent) {
    final int price = isPermanent ? item['permPrice'] : item['rentPrice'];

    if (userCoins < price) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('عذراً، رصيدك غير كافٍ لإتمام هذه المعاملة!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      userCoins -= price;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم شراء ${item['name']} بنجاح! 🛍️'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showPurchaseModal(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1E1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(item['icon'], style: TextStyle(fontSize: 32)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'],
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        if (item['origin'] != "General")
                          Text(
                            'التراث: ${item['origin']}',
                            style: TextStyle(color: Colors.cyanAccent, fontSize: 11),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                item['description'],
                style: TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Cairo'),
              ),
              Divider(color: Colors.grey.withOpacity(0.3), height: 25),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _buyItem(item, false);
                      },
                      child: Column(
                        children: [
                          Text('إيجار (30 يوم)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Cairo')),
                          Text('🪙 ${item['rentPrice']}', style: TextStyle(fontSize: 11, color: Colors.amberAccent)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _buyItem(item, true);
                      },
                      child: Column(
                        children: [
                          Text('امتلاك دائم', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Cairo')),
                          Text('🪙 ${item['permPrice']}', style: TextStyle(fontSize: 11, color: Colors.amberAccent)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = wardrobeItems.where((item) => item['category'] == activeCategory).toList();

    return Scaffold(
      backgroundColor: Color(0xFF0F0B19),
      appBar: AppBar(
        title: Text('متجر الملابس الرمزية والماركت', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF1E1A2E),
        elevation: 0,
        actions: [
          Row(
            children: [
              Icon(Icons.monetization_on, color: Colors.amber, size: 20),
              SizedBox(width: 6),
              Text('$userCoins ذهبة', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(width: 15),
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Interactive Tailor Design Workshop
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF2A1B40), Color(0xFF130D26)]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.design_services, color: Colors.cyanAccent),
                      SizedBox(width: 10),
                      Text(
                        'ورشة الحياكة والتطريز المخصص 3D',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Cairo'),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'قم بتفصيل كسوة أحلامك بيدك! اختر النمط والتطريز، وشاهد ماكينة الخياطة التفاعلية تحيكها لرمزيتك فوراً.',
                    style: TextStyle(color: Colors.grey, fontSize: 11, fontFamily: 'Cairo'),
                  ),
                  SizedBox(height: 15),

                  if (isTailoringActive) ...[
                    LinearProgressIndicator(
                      value: tailoringProgress,
                      backgroundColor: Colors.grey[800],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: Text(
                        tailoringStatusText,
                        style: TextStyle(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                      ),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedPattern,
                            decoration: InputDecoration(
                              labelText: 'تطريز النقش',
                              labelStyle: TextStyle(color: Colors.grey, fontSize: 12),
                              border: OutlineInputBorder(),
                            ),
                            dropdownColor: Color(0xFF1E1A2E),
                            items: ["RoyalGold", "Arabesque", "Geometric"].map((p) {
                              return DropdownMenuItem<String>(value: p, child: Text(p, style: TextStyle(color: Colors.white)));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => selectedPattern = val);
                            },
                          ),
                        ),
                        SizedBox(width: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyanAccent,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: Icon(Icons.gesture),
                          label: Text('بدء الحياكة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                          onPressed: _triggerTailorWorkshop,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Category Selectors
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCategoryButton("Traditional", "تراثي عرب"),
                _buildCategoryButton("Modest", "محتشم"),
                _buildCategoryButton("Modern", "مودرن رسمي"),
                _buildCategoryButton("Tech", "أدوات تفاعلية"),
              ],
            ),
            SizedBox(height: 15),

            // Wardrobe Grid View
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.85,
                ),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return InkWell(
                    onTap: () => _showPurchaseModal(item),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFF1E1A2E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purpleAccent.withOpacity(0.2)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(item['icon'], style: TextStyle(fontSize: 40)),
                          SizedBox(height: 8),
                          Text(
                            item['name'],
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2),
                          Text(
                            'ملك ملكي: 🪙 ${item['permPrice']}',
                            style: TextStyle(color: Colors.amberAccent, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String category, String label) {
    final bool isActive = activeCategory == category;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.pinkAccent : Color(0xFF1E1A2E),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      onPressed: () {
        setState(() {
          activeCategory = category;
        });
      },
      child: Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
