import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:myapp/pages/screens/linking_screen.dart';

import '../models/friend.dart';
import '../models/myuser.dart';

class FriendProvider extends ChangeNotifier {
  static const _pageSize = 10;
  String? _searchTerm;
  final searchController = TextEditingController();
  final List<Friend> _friends = [];
  List<Friend> _filteredFriends = [];
  late List<dynamic> _friendsID;
  bool _isDismissible = false;
  Filters _currentFilter = Filters.name;

  final PagingController<int, Friend> _pagingController =
      PagingController(firstPageKey: 0);

  static final FriendProvider _friendProvider = FriendProvider._internal();
  FriendProvider._internal();

  factory FriendProvider() {
    return _friendProvider;
  }

  //region GETTERS
  PagingController<int, Friend> get pagingController => _pagingController;
  List<Friend> get friends => _friends;
  Filters get currentFilter => _currentFilter;
  //endregion

  Future<int> awaitFriends() async {
    _friendsID = await Friend.getFriendsID();
    notifyListeners();
    return 1;
  }

  int _userIndex(Friend friend) {
    return friend.friendship.userIndex;
  }

  bool needAnimation(Friend friend) {
    return friend.friendship.newLevels[_userIndex(friend)];
  }

  Future<void> animateNewLevel(Friend friend) async {
    await Future.delayed(const Duration(seconds: 4), () async {
      await friend.friendship.hasAnimatedLevel();
      notifyListeners();
    });
  }

  Future<void> refresh() async {
    MyUser.refreshPlayer();
    _friends.clear();
    _pagingController.refresh();
  }

  //region initState() and dispose()
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  void disposePage() {
    _pagingController.dispose();
    notifyListeners();
  }
  //endregion

  /*SHOULD SEE WHAT HAPPENS WHEN NEW PAGE (MORE THAN 10 FRIENDS)*/
  ///Get a list of the nth friends
  Future<List<Friend>> getFriendsList(int pageKey) async {
    if (_friends.isEmpty) {
      for (int i = pageKey * _pageSize;
          i < pageKey * _pageSize + _pageSize && i < _friendsID.length;
          i++) {
        Friend friend = Friend(id: _friendsID[i]);
        await friend.awaitFriend();
        _friends.add(friend);
      }
    }

    switch (_currentFilter) {
      case Filters.name:
        _friends
            .sort((friend1, friend2) => friend1.name.compareTo(friend2.name));
        break;
      case Filters.bestFriends:
        _friends.sort((friend1, friend2) =>
            friend1.friendshipPower().compareTo(friend2.friendshipPower()));
        debugPrint(_friends.first.friendshipPower().toString());
        debugPrint(_friends.last.friendshipPower().toString());
        break;
      case Filters.lastSeen:
        _friends.sort((friend1, friend2) =>
            friend1.friendship.lastSeen.compareTo(friend2.friendship.lastSeen));
        break;
    }

    Friend bestFriend = Friend.getBestFriend(_friends);

    _filteredFriends = [bestFriend];
    List<Friend> notBestFriends = [];
    notBestFriends.addAll(_friends);
    notBestFriends.remove(bestFriend);

    _filteredFriends.addAll(notBestFriends);

    if (_searchTerm != null) {
      _filteredFriends = _filteredFriends
          .where((friend) =>
              friend.name.toLowerCase().contains(_searchTerm!.toLowerCase()))
          .toList();
    }

    notifyListeners();
    return _filteredFriends;
  }

  void changeFilter(Filters? filter) {
    if (filter == null) {
      _currentFilter == Filters.name;
    } else {
      _currentFilter = filter;
    }
    notifyListeners();
    _pagingController.refresh();
  }

  void search(String searchTerm) {
    _searchTerm = searchTerm;
    notifyListeners();

    _pagingController.refresh();
  }

  bool listFiltered() {
    if (_searchTerm == null || _searchTerm!.isEmpty) {
      return false;
    }

    return _friends.length != _filteredFriends.length;
  }

  void clear() {
    searchController.clear();
    _searchTerm = null;
    _filteredFriends.clear();
    _filteredFriends.addAll(_friends);

    notifyListeners();

    _pagingController.refresh();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final List<Friend> newFriends = await getFriendsList(pageKey);
      final isLastPage = newFriends.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newFriends);
      } else {
        final nextPageKey = pageKey + newFriends.length;
        _pagingController.appendPage(newFriends, nextPageKey);
      }
      notifyListeners();
    } catch (error) {
      _pagingController.error = error;
      debugPrint(error.toString());
    }
  }

  void setDismissible(bool boolean) {
    _isDismissible = boolean;
    notifyListeners();
  }

  void showLinkingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: _isDismissible,
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
}

enum Filters { name, bestFriends, lastSeen }
