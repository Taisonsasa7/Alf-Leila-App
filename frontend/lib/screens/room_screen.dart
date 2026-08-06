import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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

  // Skeletal 3D model properties & tick controllers
  late AnimationController _idleBreathingController;
  late AnimationController _windCurtainController; // Wind blower curtain animator
  late List<Map<String, dynamic>> chairs;

  // Modular customizable Gifts catalog
  final List<Map<String, dynamic>> giftCatalog = [
    {"id": "gift_rose", "name": "وردة (Rose)", "price": 10, "icon": "🌹"},
    {"id": "gift_heart", "name": "قلب (Heart)", "price": 50, "icon": "💖"},
    {"id": "gift_supercar", "name": "سيارة (Car)", "price": 1000, "icon": "🏎️"},
    {"id": "gift_castle", "name": "قصر (Castle)", "price": 5000, "icon": "🏰"},
  ];

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
      // Alternate genders: even is male, odd is female
      final bool isMale = i % 2 == 0;
      final String gender = isMale ? "Male" : "Female";

      // Assign custom gender-specific idle behaviors
      final List<String> maleBehaviors = ["SmokingShisha", "SittingCrossedLegs", "ReadingSmartphone"];
      final List<String> femaleBehaviors = ["FixingHair", "SprayingPerfume", "TypingLaptop"];
      final String activeBehavior = isMale
          ? maleBehaviors[i % maleBehaviors.length]
          : femaleBehaviors[i % femaleBehaviors.length];

      return {
        "index": i,
        "user": i == 0 ? "Taison Sasa" : (i == 1 ? "راधे राधे" : (i == 2 ? "Odon" : (i == 3 ? "Surya" : null))),
        "isMuted": i == 2 ? true : false,
        "mediaState": i == 0 ? "Both" : "Voice", // Voice, Camera, Both, None
        "gender": gender,
        "behavior": activeBehavior,
        "activeProp": i == 1 ? "Headphones" : (i == 3 ? "Smartphone" : "None"), // Headphones, Smartphone, Laptop, None

        // 3D parameters
        "chairRotationAngle": 0.0,    // 0 to 360 degrees rotation
        "isSpeaking": false,          // Drives real-time lip sync
        "blinkState": 0.0,            // Micro-expression blink interpolation
        "gestureState": "Idle",       // Idle, Waving, ShakingHands, Saluting
        "lipSyncAmplitude": 0.0,       // Dynamic mouth opening amplitude
        "textureQuality": "High",     // Dynamic adaptive texture resolution
      };
    });

    // Simulate real-time audio voice analysis loop for lip-sync lip movements
    _startSimulatedSpeechFrequencyLoop();
    _startSimulatedMicroBlinkExpressionsLoop();
  }

  @override
  void dispose() {
    _idleBreathingController.dispose();
    _windCurtainController.dispose();
    super.dispose();
  }

  // Real-time speech frequencies analyzer simulation
  void _startSimulatedSpeechFrequencyLoop() {
    Future.doWhile(() async {
      await Future.delayed(Duration(milliseconds: 250));
      if (!mounted) return false;

      setState(() {
        for (var chair in chairs) {
          if (chair['user'] != null && !chair['isMuted']) {
            // Randomly trigger vocal speech segments
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

  // Real-time micro-blink eye expressions simulator loop
  void _startSimulatedMicroBlinkExpressionsLoop() {
    Future.doWhile(() async {
      await Future.delayed(Duration(milliseconds: 2000 + Random().nextInt(2000)));
      if (!mounted) return false;

      // Trigger instant eyelid blink animation
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

  void _showGiftPanel(String receiverName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1E1A2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                    'إهداء إلى: $receiverName',
                    style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Divider(color: Colors.grey.withOpacity(0.3), height: 20),

              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: giftCatalog.length,
                itemBuilder: (context, index) {
                  final item = giftCatalog[index];
                  return InkWell(
                    onTap: () => _sendGift(item, receiverName),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF0F0B19),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.pinkAccent.withOpacity(0.2)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(item['icon'], style: TextStyle(fontSize: 32)),
                          SizedBox(height: 5),
                          Text(
                            item['name'],
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
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
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // Dynamic 360-degree rotating chair, media, AR & custom props/greetings panel
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

                    // 360-degree rotation slider control
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

                    // Active Micro Behavior selection
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

                    // Props and devices control (e.g. Headphones)
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
                                isPrivateListeningMode = true; // Enter Private Listening Mode
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

                    // Neighbor Greetings
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
    // Adapter Optimization: Smartwatches and small screens use lightweight, flat UI overlays
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

    // Adaptive seat configuration
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

                        // AR Glasses/High-End Device toggle button
                        IconButton(
                          icon: Icon(isARModeActive ? Icons.blur_on : Icons.view_in_ar, color: Colors.cyan),
                          tooltip: 'وضع الواقع المعزز AR Mode',
                          onPressed: () {
                            setState(() {
                              isARModeActive = !isARModeActive;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isARModeActive
                                    ? 'تم تفعيل وضع الواقع المعزز 3D AR Mode وإسقاط الغرفة على الواقع!'
                                    : 'تم العودة للوضع الافتراضي ثلاثي الأبعاد.'),
                                backgroundColor: Colors.cyan,
                              ),
                            );
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

                        // Capacity dynamic limits control
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          margin: EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: Color(0xFF1E1A2E),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: activeChairsLimit,
                              dropdownColor: Color(0xFF1E1A2E),
                              icon: Icon(Icons.grid_3x3, color: Colors.pinkAccent, size: 14),
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              items: [8, 16, 25].map((int val) {
                                return DropdownMenuItem<int>(
                                  value: val,
                                  child: Text('$val كراسي'),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    activeChairsLimit = newValue;
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
                                  onTap: () => _showGiftPanel(widget.hostUsername),
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

                                return GestureDetector(
                                  onTap: () {
                                    if (hasUser) {
                                      if (chair['user'] == "أنا") {
                                        _showChairActionControls(index);
                                      } else {
                                        _showGiftPanel(chair['user']);
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
      // Draw a transparent smoke cloud rising above the avatar
      final smokePaint = Paint()
        ..color = Colors.white.withOpacity(0.15 + sin(breathingValue * pi) * 0.08)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(center + Offset(radius * 0.4, -radius * 0.7), radius * 0.3, smokePaint);
    } else if (behavior == "FixingHair" && gender == "Female") {
      // Draw female hand bone reaching up towards her hair on stage
      final armPaint = Paint()
        ..color = skinBase
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center + Offset(-radius * 0.7, -radius * 0.4), radius * 0.15, armPaint);
    } else if (behavior == "SprayingPerfume" && gender == "Female") {
      // Draw small glowing spray particles
      final particlesPaint = Paint()..color = Colors.cyanAccent.withOpacity(0.5 * breathingValue);
      canvas.drawCircle(center + Offset(radius * 0.5, radius * 0.3), 3, particlesPaint);
      canvas.drawCircle(center + Offset(radius * 0.6, radius * 0.4), 2, particlesPaint);
    }

    // Interactive Device Props (Smartphone, Laptop, Headphones)
    final propPaint = Paint()..style = PaintingStyle.fill;
    if (prop == "Headphones") {
      // Render headphones arch on top of ears
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
      // Earpads
      propPaint.style = PaintingStyle.fill;
      canvas.drawOval(Rect.fromCenter(center: center + Offset(-radius * 0.9, 0), width: radius * 0.2, height: radius * 0.4), propPaint);
      canvas.drawOval(Rect.fromCenter(center: center + Offset(radius * 0.9, 0), width: radius * 0.2, height: radius * 0.4), propPaint);
    } else if (prop == "Smartphone") {
      // Render glowing smartphone held up
      propPaint.color = Colors.grey[800]!;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(center.dx + radius * 0.5, center.dy + radius * 0.2, radius * 0.35, radius * 0.6), Radius.circular(4)), propPaint);
      // Screen glow
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
