import 'package:flutter/material.dart';
import 'package:myapp/pages/screens/linking_screen.dart';

import '../models/friend.dart';

class FriendProvider extends ChangeNotifier {
  late List<Friend> _friendList;
  late List<Friend> _filteredFriends = [];
  final searchController = TextEditingController();

  final List<String> week = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];
  final List<String> month = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  void showLinkingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: const LinkingScreen(),
        );
      },
    );
  }



  int length() {
    return _filteredFriends.length;
  }

  String lastSeen(int index) {
    DateTime dateTime = _filteredFriends[index].friendship.lastSeen.toLocal();
    return '${week[dateTime.weekday - 1]}, ${month[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }

  ImageProvider photo(int index) {
    return _filteredFriends[index].photo;
  }

  String name(int index) {
    return _filteredFriends[index].name;
  }

  String username(int index) {
    return _filteredFriends[index].username;
  }

  double progress(int index) {
    return _filteredFriends[index].friendship.progress;
  }

  int level(int index) {
    return _filteredFriends[index].friendship.level;
  }

  void clear() {
    searchController.clear();
    _filteredFriends = _friendList;
    notifyListeners();
  }

  void search(String value) {
    _filteredFriends = _friendList
        .where(
            (friend) => friend.name.toLowerCase().contains(value.toLowerCase()))
        .toList();
    notifyListeners();
  }

  void getFriendList() async {
    List<dynamic> friendsID = await Friend.getFriendsID();
    List<Friend> friends = [];
    for (String id in friendsID) {
      Friend friend = Friend(id: id);
      await friend.setName();
      friends.add(friend);
    }

    _friendList = friends;
    _filteredFriends = _friendList;

    notifyListeners();
  }
}
