import 'package:flutter/material.dart';
import 'room_screen.dart';

class PartyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F0B19),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الهيدر العلوي
              Row(
                children: [
                  Icon(Icons.grid_view_rounded, color: Colors.white, size: 24),
                  SizedBox(width: 15),
                  Icon(Icons.search_rounded, color: Colors.white, size: 24),
                  Spacer(),
                  Text('خاص بي', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  SizedBox(width: 20),
                  Text('يوصي به', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(width: 10),
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                  ),
                ],
              ),
              SizedBox(height: 15),

              // بانر الإعلان الكبير (ادع أصدقاءك)
              Container(
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Color(0xFF4A148C), Color(0xFF880E4F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  image: DecorationImage(
                    image: NetworkImage('https://via.placeholder.com/600x200'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black26, BlendMode.darken),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 12,
                      right: 15,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ادع أصدقاءك', style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('احصل على عملات مجانية', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 15),

              // أقسام التوب (الديفاز والعمالقة)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0xFF1E1A2E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.5)),
                      ),
                      child: Column(
                        children: [
                          Text('الديفاز', style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(radius: 18, backgroundColor: Colors.pink),
                              Transform.translate(offset: Offset(-8, 0), child: CircleAvatar(radius: 20, backgroundColor: Colors.amber)),
                              Transform.translate(offset: Offset(-16, 0), child: CircleAvatar(radius: 18, backgroundColor: Colors.blue)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0xFF1E1A2E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.withOpacity(0.5)),
                      ),
                      child: Column(
                        children: [
                          Text('العمالقة', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(radius: 18, backgroundColor: Colors.orange),
                              Transform.translate(offset: Offset(-8, 0), child: CircleAvatar(radius: 20, backgroundColor: Colors.amberAccent)),
                              Transform.translate(offset: Offset(-16, 0), child: CircleAvatar(radius: 18, backgroundColor: Colors.cyan)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),

              // قائمة الغرف الحية (Dynamic Rooms List)
              RoomCardItem(
                roomId: 'room_1',
                userName: '🌿🌹 راधे राधे 🌹🦚',
                roomName: 'Music Suasana',
                userCount: 14,
                level: 4,
                avatarUrl: 'https://via.placeholder.com/150',
                flagCode: 'IN',
              ),
              SizedBox(height: 10),
              RoomCardItem(
                roomId: 'room_2',
                userName: '🎶🎧Music Suasana🤍',
                roomName: 'family•🇮🇩•Ms]music suasana',
                userCount: 29,
                level: 7,
                isVipBorder: true,
                avatarUrl: 'https://via.placeholder.com/150',
                flagCode: 'ID',
              ),
              SizedBox(height: 10),
              RoomCardItem(
                roomId: 'room_3',
                userName: 'ॐḓODON☆SURYAḓROOMॐ',
                roomName: 'most welcome',
                userCount: 6,
                level: 3,
                avatarUrl: 'https://via.placeholder.com/150',
                flagCode: 'IN',
              ),
              SizedBox(height: 10),
              RoomCardItem(
                roomId: 'room_4',
                userName: '🎧Room420🎧',
                roomName: 'STOP Harassing me 🙏🙏🙏',
                userCount: 12,
                level: 4,
                avatarUrl: 'https://via.placeholder.com/150',
                flagCode: 'PH',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoomCardItem extends StatelessWidget {
  final String roomId;
  final String userName;
  final String roomName;
  final int userCount;
  final int level;
  final String avatarUrl;
  final String flagCode;
  final bool isVipBorder;

  const RoomCardItem({
    required this.roomId,
    required this.userName,
    required this.roomName,
    required this.userCount,
    required this.level,
    required this.avatarUrl,
    required this.flagCode,
    this.isVipBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomScreen(
              roomId: roomId,
              roomName: roomName,
              hostUsername: userName,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Color(0xFF1E1A2E),
          borderRadius: BorderRadius.circular(14),
          border: isVipBorder ? Border.all(color: Colors.cyanAccent, width: 1.5) : null,
        ),
        child: Row(
          children: [
            // عداد المستخدمين وأيقونة المايك
            Column(
              children: [
                Text('$userCount', style: TextStyle(color: Color(0xFFEC407A), fontWeight: FontWeight.bold, fontSize: 16)),
                Icon(Icons.mic, color: Color(0xFFEC407A), size: 18),
              ],
            ),
            SizedBox(width: 12),
            // تفاصيل الغرفة واسم المستخدم
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(userName, style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                  SizedBox(height: 3),
                  Row(
                    children: [
                      Text('🏳️', style: TextStyle(fontSize: 12)), // تمثيل علم الدولة
                      SizedBox(width: 4),
                      Expanded(child: Text(roomName, style: TextStyle(color: Colors.grey, fontSize: 11), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: Color(0xFF4A148C),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Lv.$level', style: TextStyle(color: Colors.white, fontSize: 9)),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            // صورة المستخدم الديناميكية (Avatar)
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(avatarUrl),
            ),
          ],
        ),
      ),
    );
  }
}
