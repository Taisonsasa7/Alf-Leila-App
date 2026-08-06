import 'package:flutter/material.dart';
import 'screens/party_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(AlfLeilaApp());
}

class AlfLeilaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alf Leila App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFF0F0B19),
        scaffoldBackgroundColor: Color(0xFF0F0B19),
      ),
      home: MainNavigationContainer(),
    );
  }
}

class MainNavigationContainer extends StatefulWidget {
  @override
  _MainNavigationContainerState createState() => _MainNavigationContainerState();
}

class _MainNavigationContainerState extends State<MainNavigationContainer> {
  int _currentIndex = 4; // Default to Party tab initially

  // Screens corresponding to each tab
  final List<Widget> _screens = [
    // أنا (Me / Profile)
    ProfileScreen(),
    // الرسالة (Message)
    PlaceholderScreen(title: 'الرسالة'),
    // لحظة (Moment)
    PlaceholderScreen(title: 'لحظة'),
    // لعبة (Game)
    PlaceholderScreen(title: 'لعبة'),
    // الحفلة (Party / Rooms)
    PartyScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xFF1E1A2E),
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'أنا',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail_outline),
            activeIcon: Icon(Icons.mail),
            label: 'الرسالة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_outlined),
            activeIcon: Icon(Icons.camera_alt),
            label: 'لحظة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports_outlined),
            activeIcon: Icon(Icons.sports_esports),
            label: 'لعبة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.party_mode_outlined),
            activeIcon: Icon(Icons.party_mode),
            label: 'الحفلة',
          ),
        ],
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F0B19),
      body: Center(
        child: Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
