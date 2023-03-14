import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:glitters/glitters.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:myapp/pages/screens/linking_screen.dart';
import 'package:myapp/pages/views/friends_view.dart';

import '../models/friend.dart';

class FriendProvider extends ChangeNotifier {
  static const _pageSize = 10;
  String? _searchTerm;
  final searchController = TextEditingController();
  final List<Friend> _friends = [];
  List<Friend> _filteredFriends = [];
  late List<dynamic> _friendsID;

  final PagingController<int, Friend> _pagingController =
      PagingController(firstPageKey: 0);
  bool _shouldGoNext = false;

  static final FriendProvider _friendProvider = FriendProvider._internal();
  FriendProvider._internal();

  factory FriendProvider() {
    return _friendProvider;
  }

  //region GETTERS
  PagingController<int, Friend> get pagingController => _pagingController;
  List<Friend> get friends => _friends;
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
    _friendsID = await Friend.getFriendsID();
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
    if (_friends.isEmpty ||
        _friends.length != _friendsID.length ||
        _shouldGoNext) {
      for (int i = pageKey * _pageSize;
          i < pageKey * _pageSize + _pageSize && i < _friendsID.length;
          i++) {
        Friend friend = Friend(id: _friendsID[i]);
        await friend.awaitFriend();
        _friends.add(friend);
      }
      _shouldGoNext = false;
    }

    _filteredFriends = _friends;

    if (_searchTerm != null) {
      _filteredFriends = _filteredFriends
          .where((friend) =>
              friend.name.toLowerCase().contains(_searchTerm!.toLowerCase()))
          .toList();
    }

    notifyListeners();
    return _filteredFriends;
  }

  void search(String searchTerm) {
    _searchTerm = searchTerm;
    _pagingController.refresh();
    notifyListeners();
  }

  void clear() {
    searchController.clear();
    _searchTerm = null;
    _pagingController.refresh();
    _filteredFriends = _friends;
    notifyListeners();
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
        _shouldGoNext = true;
      }
      notifyListeners();
    } catch (error) {
      _pagingController.error = error;
      debugPrint(error.toString());
    }
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
}

class FriendListView extends StatefulWidget {
  const FriendListView({super.key});
  @override
  State<FriendListView> createState() => _FriendListViewState();
}

class _FriendListViewState extends State<FriendListView> {
  final FriendProvider _provider = FriendProvider();

  @override
  void initState() {
    _provider.initState();
    super.initState();
  }

  bool isDarkMode = false;
  @override
  Widget build(BuildContext context) =>
      // Don't worry about displaying progress or error indicators on screen; the
      // package takes care of that. If you want to customize them, use the
      // [PagedChildBuilderDelegate] properties.
      FutureBuilder(
        future: _provider.awaitFriends(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return PagedListView<int, Friend>(
              pagingController: _provider.pagingController,
              builderDelegate: PagedChildBuilderDelegate<Friend>(
                firstPageProgressIndicatorBuilder: (BuildContext context) {
                  return Shimmer(isDarkMode: isDarkMode);
                },
                noItemsFoundIndicatorBuilder: (BuildContext context) {
                  return const Padding(
                    padding: EdgeInsets.all(8),
                    child: Center(
                        child: Text(
                      'No friend found.',
                      style: TextStyle(fontSize: 20),
                    )),
                  );
                },
                itemBuilder: (context, item, index) => Stack(
                  children: [
                    Column(
                      children: [
                        FriendListItem(
                          friend: item,
                        ),
                        Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: FAProgressBar(
                              backgroundColor: Colors.white,
                              progressGradient: const LinearGradient(colors: [
                                Colors.blueAccent,
                                Colors.lightBlueAccent,
                              ]),
                              currentValue: item.friendship.progress,
                              maxValue: item.friendship.max(),
                            )),
                      ],
                    ),
                    AnimatedBuilder(
                        animation: _provider,
                        builder: (BuildContext context, Widget? child) {
                          bool first = true;
                          if (_provider.needAnimation(item)) {
                            if(first) {
                              WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
                                await _provider.animateNewLevel(item);
                              });
                              first = false;
                            }
                            return const IgnorePointer(
                              child: GlitterStack(
                                height: 80,
                                width: double.maxFinite,
                                duration: Duration(milliseconds: 500),
                                interval: Duration.zero,
                                children: [
                                  Glitters(),
                                  Glitters(),
                                  Glitters(),
                                  Glitters()
                                ],
                              ),
                            );
                          } else {
                            return const IgnorePointer(child: SizedBox());
                          }
                        })
                  ],
                ),
              ),
            );
          } else {
            return Shimmer(isDarkMode: isDarkMode);
          }
        },
      );

  @override
  void dispose() {
    _provider.disposePage();
    super.dispose();
  }
}

class Shimmer extends StatelessWidget {
  const Shimmer({
    super.key,
    required this.isDarkMode,
  });

  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      height: double.maxFinite,
      child: ListView.separated(
        itemBuilder: (_, i) {
          final delay = (i * 300);
          return Container(
            decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xff242424) : Colors.white,
                borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                FadeShimmer.round(
                  size: 80,
                  fadeTheme: isDarkMode ? FadeTheme.dark : FadeTheme.light,
                  millisecondsDelay: delay,
                ),
                const SizedBox(
                  width: 8,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeShimmer(
                      height: 11,
                      width: 150,
                      radius: 4,
                      millisecondsDelay: delay,
                      fadeTheme: isDarkMode ? FadeTheme.dark : FadeTheme.light,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    FadeShimmer(
                      height: 11,
                      millisecondsDelay: delay,
                      width: 170,
                      radius: 4,
                      fadeTheme: isDarkMode ? FadeTheme.dark : FadeTheme.light,
                    ),
                  ],
                )
              ],
            ),
          );
        },
        itemCount: 20,
        separatorBuilder: (_, __) => const SizedBox(
          height: 16,
        ),
      ),
    );
  }
}
