import 'package:flutter/material.dart';
import 'package:myapp/providers/friends_provider.dart';

import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final FriendProvider provider = FriendProvider();

  @override
  void initState() {
    provider.getFriendList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
            controller: provider.searchController,
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              hintText: 'Search friends',
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: provider.clear,
              ),
            ),
            onChanged: provider.search),
      ),
      body: Stack(
        children: [
          AnimatedBuilder(
              animation: provider,
              builder: (BuildContext context, Widget? child) {
                return ListView.builder(
                  itemCount: provider.length(),
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage: provider.photo(index),
                          ),
                          title: Text(provider.name(index)),
                          subtitle: Text(provider.username(index)),
                          trailing: SizedBox(
                            width: 200,
                            child: Column(
                              children: [
                                Align(
                                    alignment: Alignment.centerRight,
                                    child:
                                        Text('Lvl ${provider.level(index)}')),
                                const Spacer(),
                                const Align(
                                    alignment: Alignment.centerRight,
                                    child: Text('Last seen')),
                                Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(provider.lastSeen(index)))
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
                              currentValue: provider.progress(index),
                              maxValue: 10,
                            )),
                      ],
                    );
                  },
                );
              }),
          Container(
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.all(10),
            child: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
          )
        ],
      ),
    );
  }
}
