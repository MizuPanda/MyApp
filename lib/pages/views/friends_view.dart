import 'package:flutter/material.dart';
import 'package:myapp/providers/friends_provider.dart';

import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';

import '../../widgets/expandable.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> with AutomaticKeepAliveClientMixin {
  final FriendProvider _provider = FriendProvider();

  @override
  void initState() {
    _provider.getFriendList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: TextField(
            controller: _provider.searchController,
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              hintText: 'Search friends',
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _provider.clear,
              ),
            ),
            onChanged: _provider.search),
      ),
      body: Stack(
        children: [
          AnimatedBuilder(
              animation: _provider,
              builder: (BuildContext context, Widget? child) {
                return ListView.builder(
                  itemCount: _provider.length(),
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage: _provider.photo(index),
                          ),
                          title: Text(maxLines: 1, _provider.name(index)),
                          subtitle: Text(_provider.username(index)),
                          trailing: SizedBox(
                            width: 175,
                            child: Column(
                              children: [
                                Align(
                                    alignment: Alignment.centerRight,
                                    child:
                                        Text('Lvl ${_provider.level(index)}')),
                                const Spacer(),
                                const Align(
                                    alignment: Alignment.centerRight,
                                    child: Text('Last seen')),
                                Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(_provider.lastSeen(index)))
                              ],
                            ),
                          ),
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
                              currentValue: _provider.progress(index),
                              maxValue: _provider.max(index),
                            )),
                      ],
                    );
                  },
                );
              }),
          Container(
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.all(10),
            child: ExpandableFab(
              distance: 80,
              children: [
                ActionButton(
                  onPressed: () {
                    _provider.showLinkingDialog(context);
                  },
                  icon: const Icon(Icons.flash_on),
                ),
                ActionButton(
                  onPressed: () {},
                  icon: const Icon(Icons.thunderstorm),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
