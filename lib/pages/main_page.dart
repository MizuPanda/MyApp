import 'package:flutter/material.dart';
import 'package:myapp/pages/views/friends_view.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 2;
  final _pageViewController = PageController(initialPage: 2);

  static const List<Widget> _widgetOptions = <Widget>[
    Center(
      child: Text(
        'Index 0: Palace',
      ),
    ),
    Center(
      child: Text(
        'Index 1: Nearby chat',
      ),
    ),
    FriendsPage(),
    Center(
      child: Text(
        'Index 3: Ranking',
      ),
    ),
    Center(
      child: Text(
        'Index 4: Profile',
      ),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onSwipe(int index) {
    _pageViewController.animateToPage(index, duration: const Duration(milliseconds: 200), curve: Curves.bounceOut);

  }

  @override
  void dispose() {
    _pageViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
          controller: _pageViewController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: _widgetOptions),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.lightBlueAccent,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.castle_rounded),
            label: 'Palace',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.messenger_rounded),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_rounded),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard_rounded),
            label: 'Rank',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: (index) {
          _onSwipe(index);
          _onItemTapped(index);
        },
      ),
    );
  }
}
