import 'package:flutter/material.dart';

class AvatarStoreScreen extends StatefulWidget {
  @override
  _AvatarStoreScreenState createState() => _AvatarStoreScreenState();
}

class _AvatarStoreScreenState extends State<AvatarStoreScreen> {
  int userGoldCoins = 10000;
  int userSilverCoins = 25000;

  // Standalone UI state variables
  String activeHeaderTab =
      "إطار (Frame)"; // "إطار (Frame)", "مركبة (Vehicle)", "سمة (Theme)"
  String activeSubFilter = "عملة ذهبية"; // "عملة ذهبية", "عملة فضية"

  // Animation preview overlay state
  bool isSimulatingPreview = false;
  String previewTitle = "";
  String previewAnimationType = "";
  String previewEffect = "";
  String previewIcon = "";
  bool hasFrame = false;

  // Custom tailoring studio state
  bool isTailoringActive = false;
  double tailoringProgress = 0.0;
  String tailoringStatusText = "";
  String selectedPattern = "RoyalGold";

  // Full 34 Entrance Engine Configuration Assets (matching backend precisely)
  final List<Map<String, dynamic>> entranceItems = [
    // --- Frames (إطارات) ---
    {
      "id": "1000541913",
      "name": "إطار دراغون الكريستال البنفسجي",
      "category": "إطار (Frame)",
      "currency": "عملة ذهبية",
      "priceTag": "8,000 / دائم",
      "prices": {"7d": 800, "30d": 2400, "permanent": 8000},
      "emoji": "🐉",
      "stars": 4,
      "animType": "Purple Crystal Dragon Circle",
      "effect": "حركة ملتفة للتنين البنفسجي الأسطوري مع زهرة اللوتس الصاعدة",
      "hasFrame": true,
    },
    {
      "id": "1000539392",
      "name": "إطار طائر الفينيق الجليدي",
      "category": "إطار (Frame)",
      "currency": "عملة فضية",
      "priceTag": "15,000 / دائم",
      "prices": {"7d": 1500, "30d": 4500, "permanent": 15000},
      "emoji": "❄️",
      "stars": 3,
      "animType": "Blue Phoenix & Ice Crystals",
      "effect": "تطاير جزيئات الصقيع اللامع حول الميك وهالة زرقاء متوهجة",
      "hasFrame": true,
    },
    {
      "id": "1000539256",
      "name": "إطار أجنحة المحارب الذهبي",
      "category": "إطار (Frame)",
      "currency": "عملة ذهبية",
      "priceTag": "12,000 / دائم",
      "prices": {"7d": 1200, "30d": 3600, "permanent": 12000},
      "emoji": "👼",
      "stars": 4,
      "animType": "Angelic Wing Spread",
      "effect": "توهج مذهب حركي مع تناثر ريش الملاك الأبيض المتساقط",
      "hasFrame": true,
    },
    {
      "id": "1000539393",
      "name": "إطار بوابة جحيم أسد النار",
      "category": "إطار (Frame)",
      "currency": "عملة ذهبية",
      "priceTag": "15,000 / دائم",
      "prices": {"7d": 1500, "30d": 4500, "permanent": 15000},
      "emoji": "🦁",
      "stars": 5,
      "animType": "Underground Hell Gate & Fire Lion",
      "effect":
          "تصدع الكرسي، اهتزاز الشاشة، وتفجر ألسنة اللهب الحية وزئير الأسد",
      "hasFrame": true,
    },
    {
      "id": "1000529496",
      "name": "إطار سلم النجوم الكريستالي",
      "category": "إطار (Frame)",
      "currency": "عملة فضية",
      "priceTag": "20,000 / دائم",
      "prices": {"7d": 2000, "30d": 6000, "permanent": 20000},
      "emoji": "🪜",
      "stars": 3,
      "animType": "Crystal Staircase Climb",
      "effect": "إضاءة سماوية مع درج نجمي يتصاعد ليضيء هالة المتحدث",
      "hasFrame": true,
    },
    {
      "id": "1000538978",
      "name": "إطار الهولوغرام الفاخر",
      "category": "إطار (Frame)",
      "currency": "عملة ذهبية",
      "priceTag": "9,000 / دائم",
      "prices": {"7d": 900, "30d": 2700, "permanent": 9000},
      "emoji": "✨",
      "stars": 4,
      "animType": "Holographic Glamour Glow",
      "effect": "نبض ضوئي فخم وناعم بأسلوب شيدر هولوغرافي متلألئ",
      "hasFrame": true,
    },
    {
      "id": "1000529486",
      "name": "إطار حيتان المحيط السومرية",
      "category": "إطار (Frame)",
      "currency": "عملة فضية",
      "priceTag": "12,000 / دائم",
      "prices": {"7d": 1200, "30d": 3600, "permanent": 12000},
      "emoji": "🐋",
      "stars": 3,
      "animType": "Ocean Mandala & Cosmic Whales",
      "effect": "انعكاس تموجات الماء مع قنديل متوهجة تسبح بروية حول المايك",
      "hasFrame": true,
    },
    {
      "id": "1000527196",
      "name": "إطار معبد الفراعنة اللوتس",
      "category": "إطار (Frame)",
      "currency": "عملة ذهبية",
      "priceTag": "11,000 / دائم",
      "prices": {"7d": 1100, "30d": 3300, "permanent": 11000},
      "emoji": "👑",
      "stars": 4,
      "animType": "Temple Petal Rain & Golden Crown",
      "effect": "نمو زهرة اللوتس في الماء مع تساقط بتلات الورد الأحمر",
      "hasFrame": true,
    },
    {
      "id": "1000526875",
      "name": "إطار كسوف الشمس الرملي",
      "category": "إطار (Frame)",
      "currency": "عملة ذهبية",
      "priceTag": "13,000 / دائم",
      "prices": {"7d": 1300, "30d": 3900, "permanent": 13000},
      "emoji": "🌑",
      "stars": 5,
      "animType": "Solar Eclipse Ring Rotation",
      "effect": "نبضات هالة الكسوف الداكنة مع حركة الرمال الذهبية المتطايرة",
      "hasFrame": true,
    },
    {
      "id": "1000526868",
      "name": "إطار الثقب البنفسجي المظلم",
      "category": "إطار (Frame)",
      "currency": "عملة فضية",
      "priceTag": "25,000 / دائم",
      "prices": {"7d": 2500, "30d": 7500, "permanent": 25000},
      "emoji": "🌀",
      "stars": 3,
      "animType": "Purple Black-Hole Orbs",
      "effect": "جاذبية كونية تدور بالبرق الأسود لتلفت كل أبصار الغرفة",
      "hasFrame": true,
    },
    {
      "id": "1000526107",
      "name": "إطار معبد أنوبيس والنيران",
      "category": "إطار (Frame)",
      "currency": "عملة ذهبية",
      "priceTag": "14,000 / دائم",
      "prices": {"7d": 1400, "30d": 4200, "permanent": 14000},
      "emoji": "⚖️",
      "stars": 5,
      "animType": "Anubis Scepter Flame Ritual",
      "effect": "أدخنة فرعونية مذهبة، ولهيب ناري يعتلي زوايا كراسي الصوت",
      "hasFrame": true,
    },
    {
      "id": "1000526102",
      "name": "إطار نفق البرق البنفسجي",
      "category": "إطار (Frame)",
      "currency": "عملة فضية",
      "priceTag": "18,000 / دائم",
      "prices": {"7d": 1800, "30d": 5400, "permanent": 18000},
      "emoji": "⚡",
      "stars": 3,
      "animType": "Violet Lightning Tunnel",
      "effect": "صواعق كهرو-سحرية باللون البنفسجي المظلم تدور حول الكرسي",
      "hasFrame": true,
    },

    // --- Vehicles (مركبات) ---
    {
      "id": "1000541912",
      "name": "مركبة قمر الكرز الطائر",
      "category": "مركبة (Vehicle)",
      "currency": "عملة ذهبية",
      "priceTag": "12,000 / دائم",
      "prices": {"7d": 1200, "30d": 3600, "permanent": 12000},
      "emoji": "🌙",
      "stars": 4,
      "animType": "Floating Moon & Cherry Blossoms",
      "effect": "هبوط حالم فوق قمر عائم ممتزج بالبتلات الوردية والفراشات",
      "hasFrame": false,
    },
    {
      "id": "1000539391",
      "name": "مركبة الفينيق الأبيض والوردي",
      "category": "مركبة (Vehicle)",
      "currency": "عملة ذهبية",
      "priceTag": "15,000 / دائم",
      "prices": {"7d": 1500, "30d": 4500, "permanent": 15000},
      "emoji": "🦅",
      "stars": 5,
      "animType": "White-Pink Phoenix Descent",
      "effect": "فرد جناحي طائر العنقاء الساحر مع تساقط ريش ذهبي دافئ ومتوهج",
      "hasFrame": false,
    },
    {
      "id": "1000539255",
      "name": "مركبة قرص الشمس ومواكب الحمام",
      "category": "مركبة (Vehicle)",
      "currency": "عملة فضية",
      "priceTag": "25,000 / دائم",
      "prices": {"7d": 2500, "30d": 7500, "permanent": 25000},
      "emoji": "☀️",
      "stars": 3,
      "animType": "Golden Sun Disk Rise",
      "effect": "تمدد التوهج الشمسي الساطع مع إطلاق أسراب الحمام الأبيض بجمال",
      "hasFrame": false,
    },
    {
      "id": "1000539253",
      "name": "مركبة بوابة المجرة الكونية",
      "category": "مركبة (Vehicle)",
      "currency": "عملة ذهبية",
      "priceTag": "16,000 / دائم",
      "prices": {"7d": 1600, "30d": 4800, "permanent": 16000},
      "emoji": "🌀",
      "stars": 5,
      "animType": "Galaxy Portal & Blue Lightning",
      "effect": "فتحة زمكانية دوارة يتولد منها صعق كهربي سماوي أزرق باهر",
      "hasFrame": false,
    },
    {
      "id": "1000533396",
      "name": "مركبة أورورا الصقيع القطبي",
      "category": "مركبة (Vehicle)",
      "currency": "عملة فضية",
      "priceTag": "18,000 / دائم",
      "prices": {"7d": 1800, "30d": 5400, "permanent": 18000},
      "emoji": "🌌",
      "stars": 3,
      "animType": "Aurora Borealis & Snowfall",
      "effect": "تموجات أضواء الشمال الخضراء مع تدفق ضباب بارد متلألئ",
      "hasFrame": false,
    },
    {
      "id": "1000529485",
      "name": "مركبة ممشى الكون العائم",
      "category": "مركبة (Vehicle)",
      "currency": "عملة ذهبية",
      "priceTag": "14,000 / دائم",
      "prices": {"7d": 1400, "30d": 4200, "permanent": 14000},
      "emoji": "🛣️",
      "stars": 4,
      "animType": "Floating Universe Walkway",
      "effect": "دوران المجرات تحت الأقدام مع تفعيل المسارات النجمية اللامعة",
      "hasFrame": false,
    },
    {
      "id": "1000529487",
      "name": "مركبة مهر الثلج وحصان النور",
      "category": "مركبة (Vehicle)",
      "currency": "عملة فضية",
      "priceTag": "30,000 / دائم",
      "prices": {"7d": 3000, "30d": 9000, "permanent": 30000},
      "emoji": "🦄",
      "stars": 4,
      "animType": "Snow Mountain Kneel & Unicorn Drop",
      "effect": "عاصفة بيضاء ممتزجة بهبوط المهر المتلألئ من السماء الذهبية",
      "hasFrame": false,
    },
    {
      "id": "1000526877",
      "name": "مركبة فستان الورد الأسود وفراشات الليل",
      "category": "مركبة (Vehicle)",
      "currency": "عملة ذهبية",
      "priceTag": "10,000 / دائم",
      "prices": {"7d": 1000, "30d": 3000, "permanent": 10000},
      "emoji": "👗",
      "stars": 4,
      "animType": "Black Dress Rose Petal Burst",
      "effect": "إعصار من البتلات الحمراء المتصاعدة للأعلى وفراشات زرقاء دافئة",
      "hasFrame": false,
    },
    {
      "id": "1000526858",
      "name": "مركبة هجوم أسد صقيع الشتاء",
      "category": "مركبة (Vehicle)",
      "currency": "عملة ذهبية",
      "priceTag": "18,000 / دائم",
      "prices": {"7d": 1800, "30d": 5400, "permanent": 18000},
      "emoji": "🦁",
      "stars": 5,
      "animType": "White Frost Lion Blizzard Charge",
      "effect": "سرعة عاصفة ثلجية خارقة يندفع منها أسد الصقيع ليزلزل الشاشة",
      "hasFrame": false,
    },
    {
      "id": "1000526596",
      "name": "مركبة راعي الشبح وسلاسل النيران",
      "category": "مركبة (Vehicle)",
      "currency": "عملة ذهبية",
      "priceTag": "20,000 / دائم",
      "prices": {"7d": 2000, "30d": 6000, "permanent": 20000},
      "emoji": "⛓️",
      "stars": 5,
      "animType": "Burning Ghost Shepherd & Fire Chains",
      "effect":
          "حطام مشتعل يندفع من أسفل الأرض، وسلاسل لهب حارقة تلف الكراسي لتسقط الهدايا",
      "hasFrame": false,
    },
    {
      "id": "1000526489",
      "name": "مركبة صاعقة البرق الملاحمية",
      "category": "مركبة (Vehicle)",
      "currency": "عملة فضية",
      "priceTag": "28,000 / دائم",
      "prices": {"7d": 2800, "30d": 8400, "permanent": 28000},
      "emoji": "🌩️",
      "stars": 4,
      "animType": "Zoro Thunder God Rise",
      "effect": "صاعقة برق زرقاء تحطم حجارة الكرسي مع عاصفة من الرياح العاتية",
      "hasFrame": false,
    },

    // --- Themes (سمات الغرفة) ---
    {
      "id": "1000526486",
      "name": "سمة حاصد الأرواح وبوابات الجحيم",
      "category": "سمة (Theme)",
      "currency": "عملة ذهبية",
      "priceTag": "30,000 / دائم",
      "prices": {"7d": 3000, "30d": 9000, "permanent": 30000},
      "emoji": "💀",
      "stars": 5,
      "animType": "Underground Apocalypse Rise",
      "effect":
          "تتشقق أرضية الغرفة بالكامل، ويهبط حاصد الأرواح العملاق بضربة منجله لتهتز الشاشة وتطير هدايا المايكات",
      "hasFrame": false,
    },
    {
      "id": "1000526595",
      "name": "سمة بركان إلـه الحمم والطيور النارية",
      "category": "سمة (Theme)",
      "currency": "عملة ذهبية",
      "priceTag": "25,000 / دائم",
      "prices": {"7d": 2500, "30d": 7500, "permanent": 25000},
      "emoji": "🌋",
      "stars": 5,
      "animType": "Volcanic Eruption & Fire Birds",
      "effect":
          "تنفجر الصخور وتتدفق حمم بركانية سائلة تحت كراسي الصوت مع طيران طيور اللهب المتألقة",
      "hasFrame": false,
    },
    {
      "id": "1000526487",
      "name": "سمة معبد التنين الأخضر والأنقاض",
      "category": "سمة (Theme)",
      "currency": "عملة فضية",
      "priceTag": "40,000 / دائم",
      "prices": {"7d": 4000, "30d": 12000, "permanent": 40000},
      "emoji": "🐉",
      "stars": 4,
      "animType": "Ancient Temple Collapse & Green Dragon",
      "effect":
          "يهبط التنين من السماء بينما تتساقط أنقاض المعبد المشتعلة وتتصدع الكراسي مع أصوات رعد صاخبة",
      "hasFrame": false,
    },
    {
      "id": "1000526488",
      "name": "سمة أشباح الغابة المظلمة والأمطار",
      "category": "سمة (Theme)",
      "currency": "عملة فضية",
      "priceTag": "35,000 / دائم",
      "prices": {"7d": 3500, "30d": 10500, "permanent": 35000},
      "emoji": "🌧️",
      "stars": 4,
      "animType": "Graveyard Ghost Spawns",
      "effect":
          "تخرج أيدي الأشباح المرعبة من تحت الميكات وسط عاصفة مطرية وبرق ينير غرفتك بشكل مفاجئ ومرعب",
      "hasFrame": false,
    },
    {
      "id": "1000526490",
      "name": "سمة طاقة الأرواح واللسان المشتعل",
      "category": "سمة (Theme)",
      "currency": "عملة ذهبية",
      "priceTag": "22,000 / دائم",
      "prices": {"7d": 2200, "30d": 6600, "permanent": 22000},
      "emoji": "🔥",
      "stars": 5,
      "animType": "Triple Spirit Incarnation",
      "effect":
          "توهج أخضر يشق حجارة الغرفة مع تجسد الأوجه الثلاثة المرعبة وهبوب عاصفة سريعة",
      "hasFrame": false,
    },
    {
      "id": "1000526104",
      "name": "سمة عرش أنوبيس والكسوف الشمسي",
      "category": "سمة (Theme)",
      "currency": "عملة ذهبية",
      "priceTag": "28,000 / دائم",
      "prices": {"7d": 2800, "30d": 8400, "permanent": 28000},
      "emoji": "🏜️",
      "stars": 5,
      "animType": "Solar Eclipse & Pharaoh Awakening",
      "effect":
          "إظلام تام للشمس مع حدوث كسوف ملتهب خلف العرش ودوران حلقات النور الفرعونية حول الكراسي وسقوط الأبصارات",
      "hasFrame": false,
    },
    {
      "id": "1000526095",
      "name": "سمة استيقاظ العملاق الكوني والأرواح",
      "category": "سمة (Theme)",
      "currency": "عملة فضية",
      "priceTag": "50,000 / دائم",
      "prices": {"7d": 5000, "30d": 15000, "permanent": 50000},
      "emoji": "🗿",
      "stars": 4,
      "animType": "Stone Giant Heart Awakening",
      "effect":
          "يتشقق صدر تمثال العملاق الحجري ليشع منه نبض البرق الأزرق، مطيراً مئات الأرواح الشبحية وتأثير ارتجاج الغرفة",
      "hasFrame": false,
    },
    {
      "id": "1000526108",
      "name": "سمة عاصفة الفنار والمحيط السماوي",
      "category": "سمة (Theme)",
      "currency": "عملة فضية",
      "priceTag": "32,000 / دائم",
      "prices": {"7d": 3200, "30d": 9600, "permanent": 32000},
      "emoji": "🌊",
      "stars": 4,
      "animType": "Whirling Water Vortex",
      "effect":
          "دوامة مائية دوارة عملاقة بوسط الكراسي وشعاع ضوء ساطع يخرج من الفنار ليخترق السحاب",
      "hasFrame": false,
    },
  ];

  void _triggerTailorWorkshop() {
    setState(() {
      isTailoringActive = true;
      tailoringProgress = 0.0;
      tailoringStatusText = "سحب القماش المختار ومطابقة القياسات...";
    });

    Future.delayed(Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          tailoringProgress = 0.35;
          tailoringStatusText = "تشغيل ماكينة الحياكة والتطريز بالذهب...";
        });
      }
    });

    Future.delayed(Duration(milliseconds: 1600), () {
      if (mounted) {
        setState(() {
          tailoringProgress = 0.70;
          tailoringStatusText = "تطبيق نقشة: $selectedPattern والخياطة...";
        });
      }
    });

    Future.delayed(Duration(milliseconds: 2400), () {
      if (mounted) {
        setState(() {
          tailoringProgress = 1.0;
          tailoringStatusText = "تطبيق الكي والتلميع النهائي للكسوة 3D...";
        });
      }
    });

    Future.delayed(Duration(milliseconds: 3200), () {
      if (mounted) {
        setState(() {
          isTailoringActive = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تهانينا! تمت حياكة كسوتك المخصصة بنجاح وإضافتها لخزانتك! 🪡🧵',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _simulatePreview(Map<String, dynamic> item) {
    setState(() {
      isSimulatingPreview = true;
      previewTitle = item['name'];
      previewAnimationType = item['animType'] ?? "Apocalyptic Impact";
      previewEffect = item['effect'] ?? "";
      previewIcon = item['emoji'] ?? "💥";
      hasFrame = item['hasFrame'] ?? false;
    });

    // Simulate cinematic audio-visual action triggers (screen shaking, falling assets)
    Future.delayed(Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          isSimulatingPreview = false;
        });
      }
    });
  }

  void _buyItem(Map<String, dynamic> item, String duration) {
    final Map<String, dynamic> prices = item['prices'];
    final int price = prices[duration] ?? prices['permanent'];
    final bool isGold = item['currency'] == "عملة ذهبية";

    if (isGold) {
      if (userGoldCoins < price) {
        _showNoBalanceSnackBar("الذهبية");
        return;
      }
      setState(() {
        userGoldCoins -= price;
      });
    } else {
      if (userSilverCoins < price) {
        _showNoBalanceSnackBar("الفضية");
        return;
      }
      setState(() {
        userSilverCoins -= price;
      });
    }

    String durText = duration == "7d"
        ? "أسبوع (7 أيام)"
        : (duration == "30d" ? "شهر (30 يوماً)" : "دائم للأبد");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم شراء وتفعيل "${item['name']}" لفترة: $durText بنجاح! 🎉',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showNoBalanceSnackBar(String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'عذراً، رصيدك من العملات $type غير كافٍ لإتمام هذه المعاملة!',
        ),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _sendItemAsGift(Map<String, dynamic> item, String duration) {
    final TextEditingController idController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1E1A2E),
          title: Text(
            'إهداء إلى صديق',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.right,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'أدخل المعرّف الفريد (ID) للمستخدم المستلم وسنقوم بإرسال الكسوة له فوراً.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontFamily: 'Cairo',
                ),
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 12),
              TextField(
                controller: idController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'مثال: 987154',
                  hintStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
                  filled: true,
                  fillColor: Colors.black24,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: TextStyle(color: Colors.grey, fontFamily: 'Cairo'),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
              ),
              onPressed: () {
                final friendID = idController.text.trim();
                Navigator.pop(context);
                if (friendID.isEmpty) return;

                // Validate transaction and deduct
                final Map<String, dynamic> prices = item['prices'];
                final int price = prices[duration] ?? prices['permanent'];
                final bool isGold = item['currency'] == "عملة ذهبية";

                if (isGold) {
                  if (userGoldCoins < price) {
                    _showNoBalanceSnackBar("الذهبية");
                    return;
                  }
                  setState(() => userGoldCoins -= price);
                } else {
                  if (userSilverCoins < price) {
                    _showNoBalanceSnackBar("الفضية");
                    return;
                  }
                  setState(() => userSilverCoins -= price);
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم إرسال الكسوة "${item['name']}" بنجاح إلى الصديق ذو الرقم ID: $friendID! 🎁',
                    ),
                    backgroundColor: Colors.purple,
                  ),
                );
              },
              child: Text(
                'إرسال الآن',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showActionModal(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1E1A2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(item['emoji'] ?? "📦", style: TextStyle(fontSize: 32)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'],
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        Text(
                          'التصنيف الفريد: ${item['category']} • العملة: ${item['currency']}',
                          style: TextStyle(
                            color: Colors.cyanAccent,
                            fontSize: 11,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                item['effect'] ?? "",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontFamily: 'Cairo',
                ),
              ),
              Divider(color: Colors.grey.withOpacity(0.3), height: 20),
              Text(
                'اختر مدة التفعيل لإتمام الشراء أو الإهداء:',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontFamily: 'Cairo',
                ),
              ),
              SizedBox(height: 10),
              // Price options matrix
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ["7d", "30d", "permanent"].map((dur) {
                  String label = dur == "7d"
                      ? "أسبوع (7 أيام)"
                      : (dur == "30d" ? "شهر" : "دائم للأبد");
                  final price = item['prices'][dur];
                  final sym = item['currency'] == "عملة ذهبية" ? "🪙" : "🪙🥈";
                  return Expanded(
                    child: Card(
                      color: Colors.black24,
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _showConfirmBuyOrGiftDialog(item, dur);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 4.0,
                          ),
                          child: Column(
                            children: [
                              Text(
                                label,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '$sym $price',
                                style: TextStyle(
                                  color: Colors.amberAccent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showConfirmBuyOrGiftDialog(Map<String, dynamic> item, String duration) {
    showDialog(
      context: context,
      builder: (context) {
        final price = item['prices'][duration];
        final currencySymbol = item['currency'] == "عملة ذهبية" ? "ذهب" : "فضة";
        return AlertDialog(
          backgroundColor: Color(0xFF1E1A2E),
          title: Text(
            'تأكيد الإجراء',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.right,
          ),
          content: Text(
            'هل ترغب بشراء "${item['name']}" لنفسك أم إرسالها كهدية إلى صديق بسعر $price $currencySymbol؟',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontFamily: 'Cairo',
            ),
            textAlign: TextAlign.right,
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              onPressed: () {
                Navigator.pop(context);
                _sendItemAsGift(item, duration);
              },
              child: Text(
                'إهداء لصديق',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 11),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                Navigator.pop(context);
                _buyItem(item, duration);
              },
              child: Text(
                'شراء لنفسي',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 11),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter matching active header tab AND active sub currency filter
    final filteredItems = entranceItems.where((item) {
      return item['category'] == activeHeaderTab &&
          item['currency'] == activeSubFilter;
    }).toList();

    return Scaffold(
      backgroundColor: Color(0xFF0F0B19),
      appBar: AppBar(
        title: Text(
          'متجر الدخول والملابس الرمزية',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: Color(0xFF1E1A2E),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Text(
                      '$userGoldCoins',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: Colors.amber,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.monetization_on, color: Colors.amber, size: 14),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '$userSilverCoins',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: Colors.grey[300],
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.stars, color: Colors.grey[400], size: 14),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // 1. Interactive Sewing Workshop Card
                Container(
                  margin: EdgeInsets.all(12),
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2A1B40), Color(0xFF130D26)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.cyanAccent.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.design_services,
                            color: Colors.cyanAccent,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'ورشة الحياكة والتطريز المخصص 3D',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        'قم بتفصيل كسوة أحلامك بيدك! اختر النمط والتطريز، وشاهد ماكينة الخياطة التفاعلية تحيكها لرمزيتك فوراً.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      SizedBox(height: 12),
                      if (isTailoringActive) ...[
                        LinearProgressIndicator(
                          value: tailoringProgress,
                          backgroundColor: Colors.grey[800],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.cyanAccent,
                          ),
                        ),
                        SizedBox(height: 8),
                        Center(
                          child: Text(
                            tailoringStatusText,
                            style: TextStyle(
                              color: Colors.cyanAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 42,
                                child: DropdownButtonFormField<String>(
                                  value: selectedPattern,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 0,
                                    ),
                                    labelText: 'تطريز النقش',
                                    labelStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 10,
                                    ),
                                    border: OutlineInputBorder(),
                                  ),
                                  dropdownColor: Color(0xFF1E1A2E),
                                  items: ["RoyalGold", "Arabesque", "Geometric"]
                                      .map((p) {
                                        return DropdownMenuItem<String>(
                                          value: p,
                                          child: Text(
                                            p,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                            ),
                                          ),
                                        );
                                      })
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null)
                                      setState(() => selectedPattern = val);
                                  },
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.cyanAccent,
                                foregroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: Icon(Icons.gesture, size: 14),
                              label: Text(
                                'بدء الحياكة',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                              onPressed: _triggerTailorWorkshop,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // 2. Header Tab Selector (Frame, Vehicle, Theme)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  color: Color(0xFF1A152E),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ["إطار (Frame)", "مركبة (Vehicle)", "سمة (Theme)"]
                        .map((tab) {
                          final bool isSelected = activeHeaderTab == tab;
                          return Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  activeHeaderTab = tab;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: isSelected
                                          ? Colors.cyanAccent
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  tab,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.cyanAccent
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ),
                            ),
                          );
                        })
                        .toList(),
                  ),
                ),

                // 3. Sub Filters (Gold / Silver coins selection)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: ["عملة ذهبية", "عملة فضية"].map((currency) {
                      final bool isSelected = activeSubFilter == currency;
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        child: ChoiceChip(
                          label: Text(
                            currency,
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: Colors.cyanAccent,
                          backgroundColor: Color(0xFF1E1A2E),
                          onSelected: (bool selected) {
                            if (selected) {
                              setState(() {
                                activeSubFilter = currency;
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // 4. Responsive 3-Column Grid Container (as requested in JSON spec)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // Precise 3 Columns
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 10,
                      childAspectRatio:
                          0.53, // Adapted ratio to fit stars, prices, and dual action buttons
                    ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      final int rarity = item['stars'] ?? 1;

                      return Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF1E1A2E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.purpleAccent.withOpacity(0.15),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header badge / Preview simulation button
                            Stack(
                              children: [
                                // Action / preview visual container
                                Container(
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.black24,
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      item['emoji'] ?? "🎁",
                                      style: TextStyle(fontSize: 28),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    padding: EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: InkWell(
                                      onTap: () => _simulatePreview(item),
                                      child: Icon(
                                        Icons.play_arrow,
                                        color: Colors.cyanAccent,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                                vertical: 2.0,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    item['name'] ?? "",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  // Rarity Stars (1 to 5 stars)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(5, (starIdx) {
                                      return Icon(
                                        Icons.star,
                                        color: starIdx < rarity
                                            ? Colors.amber
                                            : Colors.grey[700],
                                        size: 8,
                                      );
                                    }),
                                  ),
                                  SizedBox(height: 4),
                                  // Price and Duration tag
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black38,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '🪙 ${item['priceTag']}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.amberAccent,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Dual Action Buttons: Buy and Send
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Column(
                                children: [
                                  // Buy button (شراء)
                                  SizedBox(
                                    height: 22,
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.cyanAccent,
                                        foregroundColor: Colors.black,
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                      onPressed: () => _showActionModal(item),
                                      child: Text(
                                        'شراء',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Cairo',
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  // Send button (إرسال)
                                  SizedBox(
                                    height: 22,
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: Colors.pinkAccent,
                                        ),
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                      onPressed: () =>
                                          _showConfirmBuyOrGiftDialog(
                                            item,
                                            "permanent",
                                          ),
                                      child: Text(
                                        'إرسال',
                                        style: TextStyle(
                                          color: Colors.pinkAccent,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Cairo',
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),

          // Cinematic Apocalyptic & Mythological Entrance Simulator Overlay
          if (isSimulatingPreview)
            Positioned.fill(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 500),
                color: Colors.black.withOpacity(0.85),
                child: Center(
                  child: Container(
                    margin: EdgeInsets.all(24),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xFF1E1035),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.cyanAccent, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.5),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Dynamic spinning/floating visualizer matching apocalyptic effects
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 6.28),
                          duration: Duration(seconds: 4),
                          builder: (context, double value, child) {
                            return Transform.rotate(
                              angle: value,
                              child: Text(
                                previewIcon,
                                style: TextStyle(fontSize: 64),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 16),
                        Text(
                          'محاكاة الدخول الملحمي: $previewTitle',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'نوع الحركة: $previewAnimationType',
                          style: TextStyle(
                            color: Colors.amberAccent,
                            fontSize: 11,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        SizedBox(height: 12),
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            previewEffect,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 11,
                              fontFamily: 'Cairo',
                              height: 1.4,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        // Screen shaking visual hint / dynamic micro-shaking effect simulation
                        Text(
                          '💥 [تأثير تفاعلي: اهتزاز الشاشة وسقوط هدايا المايك!] 💥',
                          style: TextStyle(
                            color: Colors.pinkAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        SizedBox(height: 15),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              isSimulatingPreview = false;
                            });
                          },
                          child: Text(
                            'إغلاق المعاينة السينمائية',
                            style: TextStyle(
                              color: Colors.cyanAccent,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
