import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:glitters/glitters.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../models/friend.dart';
import '../../../providers/friends_provider.dart';
import '../../../widgets/shimmer.dart';

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
              }, noItemsFoundIndicatorBuilder: (BuildContext context) {
                return const Padding(
                  padding: EdgeInsets.all(8),
                  child: Center(
                      child: Text(
                    'No friend found.',
                    style: TextStyle(fontSize: 20),
                  )),
                );
              }, itemBuilder: (context, item, index) {
                bool bestFriend = false;
                if (index == 0 && !_provider.listFiltered()) {
                  bestFriend = true;
                }
                return Stack(
                  children: [
                    FriendListItem(friend: item, isBestFriend: bestFriend),
                    AnimatedBuilder(
                        animation: _provider,
                        builder: (BuildContext context, Widget? child) {
                          bool first = true;
                          if (_provider.needAnimation(item)) {
                            if (first) {
                              WidgetsBinding.instance
                                  .addPostFrameCallback((timeStamp) async {
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
                );
              }),
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

class FriendListItem extends StatelessWidget {
  final Friend friend;
  final bool isBestFriend;

  const FriendListItem(
      {super.key, required this.friend, required this.isBestFriend});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Container(
        height: 123,
        width: double.maxFinite,
        decoration: BoxDecoration(
            color: Colors.white60,
            border: Border.all(color: Colors.grey, width: 0.1),
            borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: friend.photo,
                    radius: 20,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Builder(
                          builder: (BuildContext context) {
                            if (isBestFriend) {
                              return Row(
                                children: [
                                  Text(
                                    maxLines: 1,
                                    friend.name,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 16.0),
                                  ),
                                  const Icon(
                                    Icons.star_rounded,
                                    shadows: [
                                      Shadow(
                                          color: Colors.black,
                                          offset: Offset(0, 0),
                                          blurRadius: 4)
                                    ],
                                    color: Colors.yellow,
                                  )
                                ],
                              );
                            } else {
                              return Text(
                                maxLines: 1,
                                friend.name,
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 16.0),
                              );
                            }
                          },
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          friend.username,
                          style: TextStyle(
                              color: Colors.grey[700], fontSize: 14.0),
                        )
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Lvl ${friend.friendship.level}'),
                      const Spacer(),
                      const Text('Last seen'),
                      Text(friend.friendship.timeAgo())
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Container(
              height: 25,
              decoration: BoxDecoration(
                  color: Colors.white60,
                  border: Border.all(color: Colors.black, width: 0.5),
                  borderRadius: BorderRadius.circular(9)),
              child: FAProgressBar(
                backgroundColor: Colors.white,
                progressGradient: const LinearGradient(colors: [
                  Colors.blueAccent,
                  Colors.lightBlueAccent,
                ]),
                currentValue: friend.friendship.progress,
                maxValue: friend.friendship.max(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
