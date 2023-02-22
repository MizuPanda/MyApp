import 'package:flutter/cupertino.dart';

import '../pages/views/friends_view.dart';

class MainProvider extends ChangeNotifier {
  int selectedIndex = 2;
  final pageViewController = PageController(initialPage: 2);

  final List<Widget> widgetOptions = <Widget>[
    const Center(
      child: Text(
        'Index 0: Palace',
      ),
    ),
    const Center(
      child: Text(
        'Index 1: Nearby chat',
      ),
    ),
    const FriendsPage(),
    const Center(
      child: Text(
        'Index 3: Ranking',
      ),
    ),
    const Center(
      child: Text(
        'Index 4: Profile',
      ),
    ),
  ];

  void disposeController() {
    pageViewController.dispose();
    notifyListeners();
  }

  void onItemTapped(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void onSwipe(int index) {
    pageViewController.animateToPage(index,
        duration: const Duration(milliseconds: 200), curve: Curves.bounceOut);
    notifyListeners();
  }
}
