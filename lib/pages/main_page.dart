import 'package:flutter/material.dart';
import 'package:myapp/providers/main_provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  MainProvider provider = MainProvider();

  @override
  void dispose() {
    provider.disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: provider,
        builder: (BuildContext context, Widget? child) {
          return Scaffold(
            body: PageView(
                controller: provider.pageViewController,
                onPageChanged: provider.onItemTapped,
                children: provider.widgetOptions),
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
              currentIndex: provider.selectedIndex,
              selectedItemColor: Colors.amber[800],
              onTap: (index) {
                provider.onSwipe(index);
                provider.onItemTapped(index);
              },
            ),
          );
        });
  }
}
