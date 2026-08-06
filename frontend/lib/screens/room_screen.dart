import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'avatar_store_screen.dart';

// --- Multi-Platform Platform Profile ---
enum TargetPlatformType {
  Mobile,       // Android / iOS
  SmartTV,      // TV OS, limited rendering power
  ARGlasses,    // AR / VR High-fidelity stereoscopic HUD
  Smartwatch    // Minimalist ultra-light layout
}

class RoomScreen extends StatefulWidget {
  final String roomId;
  final String roomName;
  final String hostUsername;

  const RoomScreen({
    required this.roomId,
    required this.roomName,
    required this.hostUsername,
  });

  @override
  _RoomScreenState createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> with TickerProviderStateMixin {
  int userCoins = 10000;
  String? activeGiftBroadcast;
  String? activeGiftIcon;

  // Active capacity limits: 8, 16, or 25 seats
  int activeChairsLimit = 25;

  // Multi-platform Adaptive configuration
  TargetPlatformType currentPlatform = TargetPlatformType.Mobile;
  bool isARModeActive = false; // Augmented Reality projection mode toggle

  // Private Music Listening Mode variables
  bool isPrivateListeningMode = false;
  String currentPrivateSong = "أغنية ألف ليلة وليلة - أم كلثوم";

  // Dynamic Landmark Cinematic effects variables
  String? activeCinematicLandmark;
  String? activeCinematicLandmarkName;

  // Interactive dining consumption loops per chair
  // Tracks: {"user_id": {"item_icon": "🍛", "scale": 1.0, "time_left": 30}}
  Map<String, Map<String, dynamic>> chairDiningStates = {};

  // Skeletal 3D model properties & tick controllers
  late AnimationController _idleBreathingController;
  late AnimationController _windCurtainController; // Wind blower curtain animator
  late List<Map<String, dynamic>> chairs;

  // Comprehensive Pluggable Gift Catalog categorized into immersive sections & tabs
  final Map<String, List<Map<String, dynamic>>> comprehensiveGiftMarketplace = {
    "معالم ألف ليلة": [
      {"id": "egypt_pyramids", "name": "أهرامات الجيزة العظيمة", "price": 5000, "icon": "🔺", "origin": "مصر"},
      {"id": "morocco_hassan", "name": "صومعة حسان بالرباط", "price": 4200, "icon": "🗼", "origin": "المغرب"},
      {"id": "iraq_babylon", "name": "بابل الأثرية والأسوار", "price": 4900, "icon": "🦁", "origin": "العراق"},
      {"id": "saudi_alula", "name": "مدائن صالح بالعلّا", "price": 5000, "icon": "🏜️", "origin": "السعودية"},
      {"id": "yemen_sana_old", "name": "صنعاء القديمة الطينية", "price": 4800, "icon": "🏢", "origin": "اليمن"},
    ],
    "المأكولات": [
      {"id": "dish_koshary", "name": "الكشري المصري الفواح", "price": 120, "icon": "🍜", "origin": "مصر", "effect": "Steam"},
      {"id": "dish_kabsa", "name": "الكبسة السعودية الحارة", "price": 250, "icon": "🍛", "origin": "السعودية", "effect": "Steam"},
      {"id": "dish_couscous", "name": "الكسكس والطاجين المغربي", "price": 300, "icon": "🍲", "origin": "المغرب", "effect": "Bubbling"},
      {"id": "dish_mansaf", "name": "المنسف الأردني بالسمن", "price": 350, "icon": "🍖", "origin": "الأردن", "effect": "Steam"},
      {"id": "dish_brik", "name": "البريك التونسي المقرمش", "price": 80, "icon": "🌮", "origin": "تونس", "effect": "Sizzle"},
    ],
    "المشروبات": [
      {"id": "drink_atay", "name": "أتاي المغربي بالنعناع", "price": 50, "icon": "🍵", "origin": "المغرب", "effect": "LiquidPhysics"},
      {"id": "drink_coffee", "name": "القهوة السعودية بالهيل", "price": 60, "icon": "☕", "origin": "السعودية", "effect": "LiquidPhysics"},
      {"id": "drink_tea", "name": "كوب شاي كشري روقان", "price": 30, "icon": "🥛", "origin": "مصر", "effect": "LiquidPhysics"},
    ],
    "العملات الذهبية": [
      {"id": "gift_perfume", "name": "عطر الياسمين الفاخر", "price": 150, "icon": "🍾"},
      {"id": "gift_key", "name": "مفتاح الحظ الذهبي", "price": 30, "icon": "🔑"},
      {"id": "gift_cash_gun", "name": "مسدس النقدية الطائر", "price": 500, "icon": "🔫"},
      {"id": "gift_musical_box", "name": "صندوق الموسيقى الكلاسيكي", "price": 800, "icon": "📻"},
    ],
    "النبلاء": [
      {"id": "gift_royal_crown", "name": "التاج الملكي المرصع", "price": 15000, "icon": "👑"},
      {"id": "gift_dragon", "name": "التنين الأسطوري الطائر", "price": 50000, "icon": "🐉"},
      {"id": "gift_luxury_yacht", "name": "اليخت الفاره لليالي", "price": 30000, "icon": "🚢"},
    ],
  };

  @override
  void initState() {
    super.initState();

    // Idle breathing & blink micro-expression driver loop
    _idleBreathingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    // Wind blowing curtain simulator loop
    _windCurtainController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 5000),
    )..repeat(reverse: true);

    // Initialize 25 total chairs with 3D rotation, micro-expression, gender behaviors, and props
    chairs = List.generate(25, (i) {
      final bool isMale = i % 2 == 0;
      final String gender = isMale ? "Male" : "Female";

      final List<String> maleBehaviors = ["SmokingShisha", "SittingCrossedLegs", "ReadingSmartphone"];
      final List<String> femaleBehaviors = ["FixingHair", "SprayingPerfume", "TypingLaptop"];
      final String activeBehavior = isMale
          ? maleBehaviors[i % maleBehaviors.length]
          : femaleBehaviors[i % femaleBehaviors.length];

      return {
        "index": i,
        "user": i == 0 ? "Taison Sasa" : (i == 1 ? "راधे राधे" : (i == 2 ? "Odon" : (i == 3 ? "Surya" : null))),
        "isMuted": i == 2 ? true : false,
        "mediaState": i == 0 ? "Both" : "Voice",
        "gender": gender,
        "behavior": activeBehavior,
        "activeProp": i == 1 ? "Headphones" : (i == 3 ? "Smartphone" : "None"),

        // 3D parameters
        "chairRotationAngle": 0.0,
        "isSpeaking": false,
        "blinkState": 0.0,
        "gestureState": "Idle",
        "lipSyncAmplitude": 0.0,
        "textureQuality": "High",
      };
    });

    _startSimulatedSpeechFrequencyLoop();
    _startSimulatedMicroBlinkExpressionsLoop();
  }

  @override
  void dispose() {
    _idleBreathingController.dispose();
    _windCurtainController.dispose();
    super.dispose();
  }

  void _startSimulatedSpeechFrequencyLoop() {
    Future.doWhile(() async {
      await Future.delayed(Duration(milliseconds: 250));
      if (!mounted) return false;

      setState(() {
        for (var chair in chairs) {
          if (chair['user'] != null && !chair['isMuted']) {
            chair['isSpeaking'] = Random().nextBool();
            chair['lipSyncAmplitude'] = chair['isSpeaking'] ? Random().nextDouble() : 0.0;
          } else {
            chair['isSpeaking'] = false;
            chair['lipSyncAmplitude'] = 0.0;
          }
        }
      });
      return true;
    });
  }

  void _startSimulatedMicroBlinkExpressionsLoop() {
    Future.doWhile(() async {
      await Future.delayed(Duration(milliseconds: 2000 + Random().nextInt(2000)));
      if (!mounted) return false;

      for (var chair in chairs) {
        if (chair['user'] != null) {
          chair['blinkState'] = 1.0;
        }
      }
      setState(() {});
      await Future.delayed(Duration(milliseconds: 150));
      if (!mounted) return false;

      for (var chair in chairs) {
        chair['blinkState'] = 0.0;
      }
      setState(() {});
      return true;
    });
  }

  // Real-time 30-Second Dining/Consumption Animation loop
  void _triggerInteractiveConsumptionPhysics(String username, Map<String, dynamic> gift) {
    final String icon = gift['icon'];

    // Set initial full dining mesh structure
    setState(() {
      chairDiningStates[username] = {
        "icon": icon,
        "scale": 1.0,
        "timeLeft": 30,
      };
    });

    // Dynamic countdown timer loop
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted || chairDiningStates[username] == null) {
        timer.cancel();
        return;
      }

      setState(() {
        final state = chairDiningStates[username]!;
        int left = state['timeLeft'] - 1;

        if (left <= 0) {
          timer.cancel();
          chairDiningStates.remove(username); // Cleanly disappear on finish

          // Trigger celebratory finish feedback
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم الانتهاء من تناول $icon بالكامل من قبل $username! 🎉🍰'),
              backgroundColor: Colors.pink,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          state['timeLeft'] = left;
          // Mesh size/scale dynamically decreases step-by-step over the 30-second duration
          state['scale'] = left / 30.0;
        }
      });
    });
  }

  void _sendGift(Map<String, dynamic> gift, String receiverName) {
    final price = gift['price'] as int;
    if (userCoins < price) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'عذراً، رصيدك غير كافٍ لشحن الهدية! يرجى إعادة الشحن.',
            style: TextStyle(fontFamily: 'Cairo', color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      userCoins -= price;
      activeGiftBroadcast = 'أرسل ${gift['icon']} إلى $receiverName';
      activeGiftIcon = gift['icon'];
    });

    Navigator.pop(context);

    // If a Cuisine or Beverage, trigger 30-second interactive dining consumption logic
    if (gift['id'].toString().startsWith('dish_') || gift['id'].toString().startsWith('drink_')) {
      _triggerInteractiveConsumptionPhysics(receiverName, gift);
    }

    // If an Arab historical landmark, trigger massive room-wide 3D particle animations and cinematic lighting
    if (gift['id'].toString().startsWith('egypt_') || gift['id'].toString().startsWith('morocco_') || gift['id'].toString().startsWith('iraq_') || gift['id'].toString().startsWith('saudi_') || gift['id'].toString().startsWith('yemen_')) {
      setState(() {
        activeCinematicLandmark = gift['icon'];
        activeCinematicLandmarkName = gift['name'];
      });

      Future.delayed(Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            activeCinematicLandmark = null;
            activeCinematicLandmarkName = null;
          });
        }
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إرسال ${gift['name']} بنجاح!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    Future.delayed(Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          activeGiftBroadcast = null;
          activeGiftIcon = null;
        });
      }
    });
  }

  void _showComprehensiveGiftMarketplace(String receiverName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1E1A2E),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DefaultTabController(
          length: comprehensiveGiftMarketplace.keys.length + 1, // Tabs + Custom Upload tab
          child: Container(
            padding: EdgeInsets.all(16),
            height: MediaQuery.of(context).size.height * 0.65,
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                        SizedBox(width: 6),
                        Text(
                          'رصيدك: $userCoins ذهبة',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    Text(
                      'إرسال إلى: $receiverName',
                      style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                // Categorised Marketplace Tabs
                TabBar(
                  isScrollable: true,
                  indicatorColor: Colors.pinkAccent,
                  labelColor: Colors.pinkAccent,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 12),
                  tabs: [
                    ...comprehensiveGiftMarketplace.keys.map((tabName) => Tab(text: tabName)).toList(),
                    Tab(text: "مخصص (Custom)"),
                  ],
                ),
                SizedBox(height: 15),

                // Grid View lists
                Expanded(
                  child: TabBarView(
                    children: [
                      ...comprehensiveGiftMarketplace.values.map((items) {
                        return GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.82,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: items.length,
                          itemBuilder: (context, idx) {
                            final item = items[idx];
                            return InkWell(
                              onTap: () => _sendGift(item, receiverName),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFF0F0B19),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.pinkAccent.withOpacity(0.1)),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(item['icon'], style: TextStyle(fontSize: 32)),
                                    SizedBox(height: 5),
                                    Text(
                                      item['name'],
                                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      '${item['price']} 🪙',
                                      style: TextStyle(color: Colors.amber, fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),

                      // Custom (مخصص) upload tab interface
                      Container(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.upload_file_rounded, color: Colors.cyanAccent, size: 50),
                              SizedBox(height: 12),
                              Text(
                                'حمل هديتك أو تصميمك المخصص ثنائي/ثلاثي الأبعاد للغرفة',
                                style: TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 15),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black),
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('تم فتح واجهة رفع الملفات والمجسمات المخصصة بنجاح!')),
                                  );
                                },
                                child: Text('اختر ملف الهدية (.glb, .png)', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showChairActionControls(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1E1A2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final double currentRotation = chairs[index]['chairRotationAngle'];
            final String activeProp = chairs[index]['activeProp'] ?? "None";
            final String activeBehavior = chairs[index]['behavior'] ?? "SittingCrossedLegs";

            return Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'التحكم بالكرسي التفاعلي ثلاثي الأبعاد والملامح',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Cairo'),
                    ),
                    Divider(color: Colors.grey.withOpacity(0.3), height: 20),

                    Text(
                      'تدوير الكرسي 3D (360 درجة): ${currentRotation.toInt()}°',
                      style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Cairo'),
                    ),
                    Slider(
                      value: currentRotation,
                      min: 0.0,
                      max: 360.0,
                      divisions: 360,
                      activeColor: Colors.pinkAccent,
                      inactiveColor: Colors.grey.withOpacity(0.3),
                      onChanged: (double val) {
                        setModalState(() {
                          chairs[index]['chairRotationAngle'] = val;
                        });
                        setState(() {
                          chairs[index]['chairRotationAngle'] = val;
                        });
                      },
                    ),

                    Text(
                      'السلوك النشط (Micro-Behavior): $activeBehavior',
                      style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Cairo'),
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple.withOpacity(0.3)),
                          onPressed: () {
                            setState(() {
                              chairs[index]['behavior'] = chairs[index]['gender'] == "Male" ? "SmokingShisha" : "FixingHair";
                            });
                            Navigator.pop(context);
                          },
                          child: Text(chairs[index]['gender'] == "Male" ? 'تدخين الشيشة' : 'تسريح الشعر', style: TextStyle(fontSize: 11)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.withOpacity(0.3)),
                          onPressed: () {
                            setState(() {
                              chairs[index]['behavior'] = chairs[index]['gender'] == "Male" ? "SittingCrossedLegs" : "SprayingPerfume";
                            });
                            Navigator.pop(context);
                          },
                          child: Text(chairs[index]['gender'] == "Male" ? 'جلوس متقاطع' : 'رش العطر', style: TextStyle(fontSize: 11)),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),

                    Text(
                      'الأجهزة والأدوات التفاعلية (Active Prop): $activeProp',
                      style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Cairo'),
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: activeProp == "Headphones" ? Colors.green : Colors.grey[800]),
                          icon: Icon(Icons.headphones, size: 14),
                          label: Text('سماعات رأس', style: TextStyle(fontSize: 11)),
                          onPressed: () {
                            setState(() {
                              if (activeProp == "Headphones") {
                                chairs[index]['activeProp'] = "None";
                                isPrivateListeningMode = false;
                              } else {
                                chairs[index]['activeProp'] = "Headphones";
                                isPrivateListeningMode = true;
                              }
                            });
                            Navigator.pop(context);
                            if (isPrivateListeningMode) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('تم الدخول في وضع الاستماع الخاص! يتم تشغيل الصوت لك الآن سرياً 🎧'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: activeProp == "Smartphone" ? Colors.green : Colors.grey[800]),
                          icon: Icon(Icons.smartphone, size: 14),
                          label: Text('هاتف ذكي', style: TextStyle(fontSize: 11)),
                          onPressed: () {
                            setState(() {
                              chairs[index]['activeProp'] = activeProp == "Smartphone" ? "None" : "Smartphone";
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),

                    Divider(color: Colors.grey.withOpacity(0.3), height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                          icon: Icon(Icons.back_hand, size: 16),
                          label: Text('تلويح (Wave)'),
                          onPressed: () {
                            setState(() => chairs[index]['gestureState'] = "Waving");
                            Navigator.pop(context);
                            Future.delayed(Duration(seconds: 3), () {
                              if (mounted) setState(() => chairs[index]['gestureState'] = "Idle");
                            });
                          },
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                          icon: Icon(Icons.handshake, size: 16),
                          label: Text('سلام (Shake)'),
                          onPressed: () {
                            setState(() => chairs[index]['gestureState'] = "ShakingHands");
                            Navigator.pop(context);
                            Future.delayed(Duration(seconds: 3), () {
                              if (mounted) setState(() => chairs[index]['gestureState'] = "Idle");
                            });
                          },
                        ),
                      ],
                    ),
                    Divider(color: Colors.grey.withOpacity(0.3), height: 25),

                    ListTile(
                      leading: Icon(Icons.mic, color: Colors.blueAccent),
                      title: Text('صوت فقط (Voice)', style: TextStyle(color: Colors.white)),
                      onTap: () {
                        setState(() => chairs[index]['mediaState'] = "Voice");
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.videocam, color: Colors.purpleAccent),
                      title: Text('كاميرا فقط (Camera)', style: TextStyle(color: Colors.white)),
                      onTap: () {
                        setState(() => chairs[index]['mediaState'] = "Camera");
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.video_call, color: Colors.pinkAccent),
                      title: Text('صوت وفيديو معاً (Both)', style: TextStyle(color: Colors.white)),
                      onTap: () {
                        setState(() => chairs[index]['mediaState'] = "Both");
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentPlatform == TargetPlatformType.Smartwatch) {
      return Scaffold(
        backgroundColor: Color(0xFF0F0B19),
        body: Center(
          child: Text(
            'Smartwatch Optimized Mode\nRoom: ${widget.roomName}\nHost: ${widget.hostUsername}',
            style: TextStyle(color: Colors.white, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final activeChairs = chairs.take(activeChairsLimit).toList();

    return Scaffold(
      backgroundColor: isARModeActive ? Colors.transparent : Color(0xFF0F0B19),
      body: Container(
        decoration: isARModeActive
            ? BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black54, Colors.purple.withOpacity(0.2)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              )
            : null,
        child: SafeArea(
          child: Stack(
            children: [
              // Dynamic Animated 3D room background environments (flickering candle light, wind curtians, shadows)
              if (!isARModeActive && currentPlatform != TargetPlatformType.SmartTV)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_idleBreathingController, _windCurtainController]),
                    builder: (context, child) {
                      return CustomPaint(
                        painter: DynamicRoomBackgroundPainter(
                          candleFlicker: _idleBreathingController.value,
                          windCurtainSwing: _windCurtainController.value,
                        ),
                      );
                    },
                  ),
                ),

              // AR immersive projection background HUD representation
              if (isARModeActive)
                Positioned.fill(
                  child: CustomPaint(
                    painter: ARHUDGridPainter(),
                  ),
                ),

              // Main Room Structure
              Column(
                children: [
                  // Top Header & Multi-Platform Adaptive Config HUD
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.close_rounded, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    widget.roomName,
                                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (isARModeActive)
                                    Container(
                                      margin: EdgeInsets.only(left: 6),
                                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: Colors.cyan, borderRadius: BorderRadius.circular(8)),
                                      child: Text('AR MODE', style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
                                    ),
                                ],
                              ),
                              Text('المضيف: ${widget.hostUsername}', style: TextStyle(color: Colors.grey, fontSize: 11)),
                            ],
                          ),
                        ),

                        // Avatar Store direct shortcut button on top bar
                        IconButton(
                          icon: Icon(Icons.storefront_rounded, color: Colors.pinkAccent),
                          tooltip: 'متجر خزانة الملابس والزينة',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AvatarStoreScreen()),
                            );
                          },
                        ),

                        // AR Glasses toggle
                        IconButton(
                          icon: Icon(isARModeActive ? Icons.blur_on : Icons.view_in_ar, color: Colors.cyan),
                          tooltip: 'وضع الواقع المعزز AR Mode',
                          onPressed: () {
                            setState(() {
                              isARModeActive = !isARModeActive;
                            });
                          },
                        ),

                        // Dropdown selection to test adaptive performance structures
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          margin: EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: Color(0xFF1E1A2E),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<TargetPlatformType>(
                              value: currentPlatform,
                              dropdownColor: Color(0xFF1E1A2E),
                              icon: Icon(Icons.devices, color: Colors.cyan, size: 14),
                              items: TargetPlatformType.values.map((plat) {
                                return DropdownMenuItem<TargetPlatformType>(
                                  value: plat,
                                  child: Text(plat.toString().split('.').last, style: TextStyle(fontSize: 10)),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    currentPlatform = newValue;
                                    for (var chair in chairs) {
                                      chair['textureQuality'] = (newValue == TargetPlatformType.SmartTV) ? "Low" : "High";
                                    }
                                  });
                                }
                              },
                            ),
                          ),
                        ),

                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(0xFF1E1A2E),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.monetization_on, color: Colors.amber, size: 14),
                              SizedBox(width: 4),
                              Text('$userCoins', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Private Listening Mode HUD Overlay Banner
                  if (isPrivateListeningMode)
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        border: Border.all(color: Colors.green, width: 1.0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.headphones_rounded, color: Colors.greenAccent, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'البث الصوتي سري وخاص (Private Mode): $currentPrivateSong',
                              style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontFamily: 'Cairo'),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            constraints: BoxConstraints(),
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.cancel, color: Colors.redAccent, size: 16),
                            onPressed: () {
                              setState(() {
                                isPrivateListeningMode = false;
                                for (var chair in chairs) {
                                  if (chair['user'] == "أنا") {
                                    chair['activeProp'] = "None";
                                  }
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                  // Stage & 25 Active Rotating Chairs Grid Area
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: 50),
                      child: Column(
                        children: [
                          // Central Rotating Stage Host Platform
                          SizedBox(height: 10),
                          Center(
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () => _showComprehensiveGiftMarketplace(widget.hostUsername),
                                  child: Container(
                                    height: 110,
                                    width: 110,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Dynamic 3D Rotating Stage platform Base
                                        AnimatedBuilder(
                                          animation: _idleBreathingController,
                                          builder: (context, child) {
                                            return Transform(
                                              transform: Matrix4.identity()
                                                ..setEntry(3, 2, 0.001)
                                                ..rotateX(1.1)
                                                ..rotateZ(_idleBreathingController.value * 2 * pi),
                                              alignment: Alignment.center,
                                              child: Container(
                                                width: 100,
                                                height: 100,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: Colors.amber, width: 2.5),
                                                  boxShadow: [
                                                    BoxShadow(color: Colors.amber.withOpacity(0.5), blurRadius: 15, spreadRadius: 3),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        // Hyper-realistic Host Avatar Widget
                                        Positioned(
                                          top: 0,
                                          child: AnimatedBuilder(
                                            animation: _idleBreathingController,
                                            builder: (context, child) {
                                              return CustomPaint(
                                                size: Size(70, 70),
                                                painter: Realistic3DAvatarPainter(
                                                  breathingValue: _idleBreathingController.value,
                                                  lipSyncAmplitude: 0.8,
                                                  blinkState: 0.0,
                                                  isSpeaking: true,
                                                  gesture: "Wave",
                                                  rotationAngle: 0.0,
                                                  textureResolution: "High",
                                                  gender: "Male",
                                                  behavior: "SittingCrossedLegs",
                                                  prop: "None",
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${widget.hostUsername} (Host)',
                                  style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),

                          // Dynamic 25 Interactive Rotating 3D Chairs stage
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: currentPlatform == TargetPlatformType.SmartTV ? 6 : 4,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 15,
                                childAspectRatio: 0.75,
                              ),
                              itemCount: activeChairs.length,
                              itemBuilder: (context, index) {
                                final chair = activeChairs[index];
                                final hasUser = chair['user'] != null;
                                final mediaState = chair['mediaState'] ?? "Voice";
                                final double rotation = chair['chairRotationAngle'] ?? 0.0;
                                final String username = chair['user'] ?? "";

                                // Retrieve active dining state if any
                                final diningState = chairDiningStates[username];

                                return GestureDetector(
                                  onTap: () {
                                    if (hasUser) {
                                      if (chair['user'] == "أنا") {
                                        _showChairActionControls(index);
                                      } else {
                                        _showComprehensiveGiftMarketplace(chair['user']);
                                      }
                                    } else {
                                      setState(() {
                                        chairs[index]['user'] = "أنا";
                                        chairs[index]['mediaState'] = "Voice";
                                      });
                                    }
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Rotating 3D Skeletal Chair base + 3D Human Avatar
                                      Container(
                                        height: 80,
                                        width: 80,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            // Smooth 3D Rotating Chair Platform Base
                                            Transform(
                                              transform: Matrix4.identity()
                                                ..setEntry(3, 2, 0.001)
                                                ..rotateX(1.0)
                                                ..rotateZ(rotation * pi / 180.0),
                                              alignment: Alignment.center,
                                              child: Container(
                                                width: 55,
                                                height: 55,
                                                decoration: BoxDecoration(
                                                  color: hasUser ? Colors.pinkAccent.withOpacity(0.2) : Colors.grey.withOpacity(0.05),
                                                  borderRadius: BorderRadius.circular(15),
                                                  border: Border.all(
                                                    color: hasUser ? Colors.pinkAccent : Colors.grey.withOpacity(0.3),
                                                    width: 1.5,
                                                  ),
                                                  boxShadow: hasUser
                                                      ? [BoxShadow(color: Colors.pinkAccent.withOpacity(0.3), blurRadius: 8)]
                                                      : [],
                                                ),
                                              ),
                                            ),

                                            // Humanoid 3D Avatar (Skeletal bones, skin texturing, lip-sync rendering)
                                            if (hasUser)
                                              Positioned(
                                                top: 2,
                                                child: AnimatedBuilder(
                                                  animation: _idleBreathingController,
                                                  builder: (context, child) {
                                                    return CustomPaint(
                                                      size: Size(55, 55),
                                                      painter: Realistic3DAvatarPainter(
                                                        breathingValue: _idleBreathingController.value,
                                                        lipSyncAmplitude: chair['lipSyncAmplitude'] ?? 0.0,
                                                        blinkState: chair['blinkState'] ?? 0.0,
                                                        isSpeaking: chair['isSpeaking'] ?? false,
                                                        gesture: chair['gestureState'] ?? "Idle",
                                                        rotationAngle: rotation,
                                                        textureResolution: chair['textureQuality'] ?? "High",
                                                        gender: chair['gender'] ?? "Male",
                                                        behavior: chair['behavior'] ?? "SittingCrossedLegs",
                                                        prop: chair['activeProp'] ?? "None",
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),

                                            // Interactive Consumption Physics overlay: declining mesh food/drink model with steam/gurgle
                                            if (hasUser && diningState != null)
                                              Positioned(
                                                bottom: 12,
                                                child: Transform.scale(
                                                  scale: diningState['scale'] as double,
                                                  child: Container(
                                                    child: Stack(
                                                      alignment: Alignment.topCenter,
                                                      children: [
                                                        Text(
                                                          diningState['icon'] as String,
                                                          style: TextStyle(fontSize: 22),
                                                        ),
                                                        // Liquid physics / pouring dynamics steam waves particles
                                                        Positioned(
                                                          top: -8,
                                                          child: Text(
                                                            '♨️',
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              color: Colors.white70.withOpacity(0.3 + sin(_idleBreathingController.value * pi) * 0.4),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        hasUser ? chair['user'] : '${chair['index'] + 1}',
                                        style: TextStyle(
                                          color: hasUser ? Colors.white : Colors.grey,
                                          fontSize: 10,
                                          fontWeight: hasUser ? FontWeight.bold : FontWeight.normal,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Interactive 3D Room-wide Arab Landmarks Cinematic overlay visualizer
              if (activeCinematicLandmark != null)
                Positioned.fill(
                  child: Container(
                    color: Colors.black80.withOpacity(0.75),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Giant floating landmark 3D projection
                        AnimatedBuilder(
                          animation: _idleBreathingController,
                          builder: (context, child) {
                            return Transform(
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..rotateY(_idleBreathingController.value * 2 * pi),
                              alignment: Alignment.center,
                              child: Text(
                                activeCinematicLandmark!,
                                style: TextStyle(fontSize: 90),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 25),
                        Text(
                          'عرض ليلة أسطوري ومباشر!',
                          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Cairo'),
                        ),
                        SizedBox(height: 5),
                        Text(
                          activeCinematicLandmarkName!,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Cairo', letterSpacing: 1),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        // Golden celebration particles simulation
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.amberAccent),
                          strokeWidth: 2.0,
                        ),
                      ],
                    ),
                  ),
                ),

              // Top Floating Real-time Gift Broadcasting Banner
              if (activeGiftBroadcast != null)
                Positioned(
                  top: 70,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.pinkAccent.withOpacity(0.9), Colors.purple.withOpacity(0.9)]),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(color: Colors.pinkAccent.withOpacity(0.5), blurRadius: 10, spreadRadius: 2),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(
                          activeGiftIcon ?? '🎁',
                          style: TextStyle(fontSize: 24),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            activeGiftBroadcast!,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Cairo'),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                          child: Text(
                            'LIVE',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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

// --- Dynamic Animated 3D room background environments (flickering candle light, wind curtians, shadows) ---
class DynamicRoomBackgroundPainter extends CustomPainter {
  final double candleFlicker;
  final double windCurtainSwing;

  DynamicRoomBackgroundPainter({required this.candleFlicker, required this.windCurtainSwing});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw glowing candle/fire visual lighting effects
    final double opacity = 0.05 + (candleFlicker * 0.04);
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.amber.withOpacity(opacity), Colors.transparent],
        center: Alignment(0.6, -0.5),
        radius: 1.2,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), glowPaint);

    // 2. Draw blowing wind curtain (left & right sides of room)
    final curtainPaint = Paint()
      ..color = Color(0xFF1A1423).withOpacity(0.9)
      ..style = PaintingStyle.fill;

    // Swing offset based on sin wind wave
    final double swingOffset = sin(windCurtainSwing * pi) * 15;

    // Left curtain path
    final leftPath = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(size.width * 0.15 + swingOffset, size.height * 0.5, size.width * 0.08, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(leftPath, curtainPaint);

    // Right curtain path
    final rightPath = Path()
      ..moveTo(size.width, 0)
      ..quadraticBezierTo(size.width * 0.85 - swingOffset, size.height * 0.5, size.width * 0.92, size.height)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(rightPath, curtainPaint);
  }

  @override
  bool shouldRepaint(covariant DynamicRoomBackgroundPainter oldDelegate) {
    return oldDelegate.candleFlicker != candleFlicker || oldDelegate.windCurtainSwing != windCurtainSwing;
  }
}

// --- Dynamic AR stereoscopic environment layout hud painter ---
class ARHUDGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyan.withOpacity(0.12)
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    final targetPaint = Paint()
      ..color = Colors.cyan.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 60, targetPaint);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 5, Paint()..color = Colors.cyan.withOpacity(0.5));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- Hyper-realistic skeletal 3D Avatar painter on Flutter CustomPaint ---
class Realistic3DAvatarPainter extends CustomPainter {
  final double breathingValue;
  final double lipSyncAmplitude;
  final double blinkState;
  final bool isSpeaking;
  final String gesture;
  final double rotationAngle;
  final String textureResolution;
  final String gender;
  final String behavior;
  final String prop;

  Realistic3DAvatarPainter({
    required this.breathingValue,
    required this.lipSyncAmplitude,
    required this.blinkState,
    required this.isSpeaking,
    required this.gesture,
    required this.rotationAngle,
    required this.textureResolution,
    required this.gender,
    required this.behavior,
    required this.prop,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = min(size.width, size.height) / 2;
    final center = Offset(size.width / 2, size.height / 2);

    // Apply rotation angle projection transformation to coordinate space
    canvas.save();
    canvas.translate(center.dx, center.center_y(center.dy));
    final double rad = rotationAngle * pi / 180.0;
    canvas.scale(cos(rad).abs().clamp(0.4, 1.0), 1.0);
    canvas.translate(-center.dx, -center.center_y(center.dy));

    // Dynamic 3D lighting shader
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.35)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(center + Offset(3, 3), radius, shadowPaint);

    // Dynamic skin tone matching gender characteristics
    final facePaint = Paint();
    final Color skinBase = (gender == "Female") ? Color(0xFFFFE5D9) : Color(0xFFC68642);
    final Color skinShadow = (gender == "Female") ? Color(0xFFF4A261) : Color(0xFF8D5524);

    if (textureResolution == "High") {
      facePaint.shader = RadialGradient(
        colors: [skinBase, skinShadow],
        center: Alignment(-0.2, -0.3),
        radius: 0.85,
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    } else {
      facePaint.color = skinBase;
    }
    canvas.drawCircle(center, radius, facePaint);

    // Dynamic breathing chest/neck translation
    final double breathTranslation = breathingValue * 1.5;

    // Female Hair vs Male Beard/Shisha accessories
    final hairPaint = Paint()..style = PaintingStyle.fill;
    if (gender == "Female") {
      hairPaint.color = Color(0xFF4A1525); // Purple-black elegant long hair
      canvas.drawArc(
        Rect.fromCircle(center: center - Offset(0, 5), radius: radius * 1.05),
        pi,
        pi,
        true,
        hairPaint,
      );
      // Flowing hair strands on sides
      canvas.drawRect(Rect.fromLTWH(center.dx - radius, center.dy, radius * 0.25, radius * 0.9), hairPaint);
      canvas.drawRect(Rect.fromLTWH(center.dx + radius * 0.75, center.dy, radius * 0.25, radius * 0.9), hairPaint);
    } else {
      hairPaint.color = Color(0xFF1A0F0F); // Short black hair
      canvas.drawArc(
        Rect.fromCircle(center: center - Offset(0, 5), radius: radius * 1.02),
        pi,
        pi,
        true,
        hairPaint,
      );
    }

    // Micro-Expressions: Eyelids and dynamic blinking
    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final pupilPaint = Paint()
      ..color = (gender == "Female") ? Colors.purple : Color(0xFF3E2723)
      ..style = PaintingStyle.fill;

    final leftEyeCenter = center + Offset(-radius * 0.35, -radius * 0.1 + breathTranslation);
    final rightEyeCenter = center + Offset(radius * 0.35, -radius * 0.1 + breathTranslation);

    if (blinkState < 0.5) {
      canvas.drawOval(Rect.fromCenter(center: leftEyeCenter, width: radius * 0.3, height: radius * 0.15), eyePaint);
      canvas.drawOval(Rect.fromCenter(center: rightEyeCenter, width: radius * 0.3, height: radius * 0.15), eyePaint);

      canvas.drawCircle(leftEyeCenter, radius * 0.08, pupilPaint);
      canvas.drawCircle(rightEyeCenter, radius * 0.08, pupilPaint);

      canvas.drawCircle(leftEyeCenter + Offset(-1, -1), 2, Paint()..color = Colors.white70);
      canvas.drawCircle(rightEyeCenter + Offset(-1, -1), 2, Paint()..color = Colors.white70);
    } else {
      final blinkPaint = Paint()
        ..color = Color(0xFF5D4037)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawLine(leftEyeCenter - Offset(10, 0), leftEyeCenter + Offset(10, 0), blinkPaint);
      canvas.drawLine(rightEyeCenter - Offset(10, 0), rightEyeCenter + Offset(10, 0), blinkPaint);
    }

    // Real-time Lip-Sync: dynamic mouth opening animation based on speaking amplitudes
    final mouthCenter = center + Offset(0, radius * 0.4 + breathTranslation);
    final mouthPaint = Paint()
      ..color = (gender == "Female") ? Color(0xFFE91E63) : Color(0xFF880E4F)
      ..style = PaintingStyle.fill;

    if (isSpeaking) {
      final double mouthHeight = (radius * 0.15) + (lipSyncAmplitude * radius * 0.25);
      canvas.drawOval(Rect.fromCenter(center: mouthCenter, width: radius * 0.35, height: mouthHeight), mouthPaint);
      canvas.drawRect(Rect.fromLTWH(mouthCenter.dx - radius * 0.12, mouthCenter.dy - mouthHeight / 4, radius * 0.24, 2), Paint()..color = Colors.white);
    } else {
      canvas.drawOval(Rect.fromCenter(center: mouthCenter, width: radius * 0.25, height: radius * 0.05), mouthPaint);
    }

    // Gender-specific behavior animations
    if (behavior == "SmokingShisha" && gender == "Male") {
      final smokePaint = Paint()
        ..color = Colors.white.withOpacity(0.15 + sin(breathingValue * pi) * 0.08)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(center + Offset(radius * 0.4, -radius * 0.7), radius * 0.3, smokePaint);
    } else if (behavior == "FixingHair" && gender == "Female") {
      final armPaint = Paint()
        ..color = skinBase
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center + Offset(-radius * 0.7, -radius * 0.4), radius * 0.15, armPaint);
    } else if (behavior == "SprayingPerfume" && gender == "Female") {
      final particlesPaint = Paint()..color = Colors.cyanAccent.withOpacity(0.5 * breathingValue);
      canvas.drawCircle(center + Offset(radius * 0.5, radius * 0.3), 3, particlesPaint);
      canvas.drawCircle(center + Offset(radius * 0.6, radius * 0.4), 2, particlesPaint);
    }

    // Interactive Device Props (Smartphone, Laptop, Headphones)
    final propPaint = Paint()..style = PaintingStyle.fill;
    if (prop == "Headphones") {
      propPaint.color = Colors.greenAccent;
      propPaint.strokeWidth = 4.0;
      propPaint.style = PaintingStyle.stroke;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.95),
        pi,
        pi,
        false,
        propPaint,
      );
      propPaint.style = PaintingStyle.fill;
      canvas.drawOval(Rect.fromCenter(center: center + Offset(-radius * 0.9, 0), width: radius * 0.2, height: radius * 0.4), propPaint);
      canvas.drawOval(Rect.fromCenter(center: center + Offset(radius * 0.9, 0), width: radius * 0.2, height: radius * 0.4), propPaint);
    } else if (prop == "Smartphone") {
      propPaint.color = Colors.grey[800]!;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(center.dx + radius * 0.5, center.dy + radius * 0.2, radius * 0.35, radius * 0.6), Radius.circular(4)), propPaint);
      propPaint.color = Colors.cyanAccent.withOpacity(0.4);
      canvas.drawRect(Rect.fromLTWH(center.dx + radius * 0.53, center.dy + radius * 0.25, radius * 0.29, radius * 0.5), propPaint);
    }

    // Dynamic hand gestures (Wave / Shake)
    final gesturePaint = Paint()
      ..color = skinBase
      ..style = PaintingStyle.fill;

    if (gesture == "Waving") {
      final wavingHand = center + Offset(radius * 0.8, -radius * 0.5 + sin(breathingValue * pi * 4) * 8);
      canvas.drawCircle(wavingHand, radius * 0.18, gesturePaint);
      for (int i = 0; i < 4; i++) {
        canvas.drawCircle(wavingHand + Offset(-5.0 + i * 4, -12), 2.5, gesturePaint);
      }
    } else if (gesture == "ShakingHands") {
      final shakingHand = center + Offset(radius * 0.7 + breathingValue * 4, radius * 0.1);
      canvas.drawCircle(shakingHand, radius * 0.18, gesturePaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant Realistic3DAvatarPainter oldDelegate) {
    return oldDelegate.breathingValue != breathingValue ||
        oldDelegate.lipSyncAmplitude != lipSyncAmplitude ||
        oldDelegate.blinkState != blinkState ||
        oldDelegate.isSpeaking != isSpeaking ||
        oldDelegate.gesture != gesture ||
        oldDelegate.rotationAngle != rotationAngle ||
        oldDelegate.textureResolution != textureResolution ||
        oldDelegate.gender != gender ||
        oldDelegate.behavior != behavior ||
        oldDelegate.prop != prop;
  }
}

extension CenterY on Offset {
  double center_y(double def) => dy;
}
