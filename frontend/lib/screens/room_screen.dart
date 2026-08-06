import 'package:flutter/material.dart';

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

class _RoomScreenState extends State<RoomScreen> {
  int userCoins = 10000; // Mock current user coin balance
  String? activeGiftBroadcast; // Stores current active live gift banner text
  String? activeGiftIcon;

  // Mock list of chairs in the room
  final List<Map<String, dynamic>> chairs = [
    {"index": 0, "user": "Taison Sasa", "isMuted": false},
    {"index": 1, "user": "راधे राधे", "isMuted": false},
    {"index": 2, "user": "Odon", "isMuted": true},
    {"index": 3, "user": "Surya", "isMuted": false},
    {"index": 4, "user": null, "isMuted": false},
    {"index": 5, "user": null, "isMuted": false},
    {"index": 6, "user": null, "isMuted": false},
    {"index": 7, "user": null, "isMuted": false},
  ];

  // Modular customizable Gifts catalog
  final List<Map<String, dynamic>> giftCatalog = [
    {"id": "gift_rose", "name": "وردة (Rose)", "price": 10, "icon": "🌹"},
    {"id": "gift_heart", "name": "قلب (Heart)", "price": 50, "icon": "💖"},
    {"id": "gift_supercar", "name": "سيارة (Car)", "price": 1000, "icon": "🏎️"},
    {"id": "gift_castle", "name": "قصر (Castle)", "price": 5000, "icon": "🏰"},
  ];

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

    // Close gift panel
    Navigator.pop(context);

    // Show dynamic success alert
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إرسال ${gift['name']} بنجاح!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Clear live overlay gift broadcast after 4 seconds
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
              // Panel Header
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

              // Gift Grid View
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F0B19),
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content Layout
            Column(
              children: [
                // Top Room Header Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.roomName,
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'المضيف: ${widget.hostUsername}',
                              style: TextStyle(color: Colors.grey, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFF1E1A2E),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.monetization_on, color: Colors.amber, size: 16),
                            SizedBox(width: 4),
                            Text('$userCoins', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Audio Chairs Area on stage
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        // Big Stage Host circle
                        Center(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () => _showGiftPanel(widget.hostUsername),
                                child: Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(colors: [Colors.amber, Colors.orange]),
                                      ),
                                      child: CircleAvatar(
                                        radius: 40,
                                        backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(color: Colors.pinkAccent, shape: BoxShape.circle),
                                      child: Icon(Icons.mic, color: Colors.white, size: 16),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '${widget.hostUsername} (Host)',
                                style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),

                        // Chairs Grid
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 20,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: chairs.length,
                            itemBuilder: (context, index) {
                              final chair = chairs[index];
                              final hasUser = chair['user'] != null;

                              return GestureDetector(
                                onTap: () {
                                  if (hasUser) {
                                    _showGiftPanel(chair['user']);
                                  } else {
                                    setState(() {
                                      chairs[index]['user'] = "أنا";
                                    });
                                  }
                                },
                                child: Column(
                                  children: [
                                    Stack(
                                      alignment: Alignment.bottomRight,
                                      children: [
                                        CircleAvatar(
                                          radius: 26,
                                          backgroundColor: hasUser ? Colors.pinkAccent.withOpacity(0.4) : Color(0xFF1E1A2E),
                                          child: hasUser
                                              ? CircleAvatar(
                                                  radius: 24,
                                                  backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                                                )
                                              : Icon(Icons.add, color: Colors.grey, size: 20),
                                        ),
                                        if (hasUser)
                                          Container(
                                            padding: EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                              color: chair['isMuted'] ? Colors.red : Colors.green,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              chair['isMuted'] ? Icons.mic_off : Icons.mic,
                                              color: Colors.white,
                                              size: 10,
                                            ),
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      hasUser ? chair['user'] : '${chair['index'] + 1}',
                                      style: TextStyle(
                                        color: hasUser ? Colors.white : Colors.grey,
                                        fontSize: 11,
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
    );
  }
}
