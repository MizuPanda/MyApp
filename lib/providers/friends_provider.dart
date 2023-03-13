import 'package:flutter/material.dart';
import 'package:myapp/pages/screens/linking_screen.dart';
import 'package:timeago/timeago.dart' as timeago;


import '../models/friend.dart';

class FriendProvider extends ChangeNotifier {
  late List<Friend> _friendList;
  late List<Friend> _filteredFriends = [];
  final searchController = TextEditingController();

  static final FriendProvider _friendProvider = FriendProvider._internal();
  FriendProvider._internal();

  factory FriendProvider() {
    return _friendProvider;
  }


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



  double max(int index) {
    return _filteredFriends[index].friendship.max();
  }

  int length() {
    return _filteredFriends.length;
  }

  String lastSeen(int index) {
    DateTime dateTime = _filteredFriends[index].friendship.lastSeen.toLocal();
    return timeago.format(dateTime);
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

  Future<void> getFriendList() async {
    List<dynamic> friendsID = await Friend.getFriendsID();
    List<Friend> friends = [];
      for (String id in friendsID) {
        Friend friend = Friend(id: id);
        await friend.awaitFriend();
        friends.add(friend);
      }

    _friendList = friends;
    _filteredFriends = _friendList;

    notifyListeners();
  }
}
