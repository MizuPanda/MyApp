import 'package:flutter/material.dart';

import '../../models/friend.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final _searchController = TextEditingController();
  final List<Friend> _friends = [
    Friend(id: "l6qY4Yso0QK6PQRJV3nT")
   // Friend(name: 'John Doe', username: 'johndoe', photo: const NetworkImage('https://picsum.photos/200'), progress: 7, lastSeen: DateTime(2000), level: 2),
    //Friend(name: 'Jane Doe', username: 'janedoe', photo: const NetworkImage('https://picsum.photos/200'), progress: 3, lastSeen: DateTime(2005), level: 3),
  ];

  List<Friend> _filteredFriends = [];

  @override
  void initState() {
    super.initState();
    _filteredFriends = _friends;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            hintText: 'Search friends',
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _filteredFriends = _friends;
                });
              },
            ),
          ),
          onChanged: (value) {
            setState(() {
              _filteredFriends = _friends
                  .where((friend) =>
                  friend.name.toLowerCase().contains(value.toLowerCase()))
                  .toList();
            });
          },
        ),
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: _filteredFriends.length,
            itemBuilder: (context, index) {
              return FutureBuilder<String>(
                future: _filteredFriends[index].getName(), // async work
                builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if(snapshot.hasData) {
                        return Column(
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundImage: _filteredFriends[index].photo,
                              ),
                              title: Text(_filteredFriends[index].name),
                              subtitle: Text(_filteredFriends[index].username),
                              trailing: SizedBox(
                                width: 100,
                                child: Column(
                                  children: [
                                    Align(alignment: Alignment.centerRight, child: Text('Lvl ${_filteredFriends[index].friendship.level}')),
                                    const Spacer(),
                                    Text('Last seen: ${_filteredFriends[index].friendship.lastSeen.year}')
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                child: FAProgressBar(
                                  backgroundColor: Colors.white,
                                  progressGradient: const LinearGradient(colors: [
                                    Colors.blueAccent,
                                    Colors.lightBlueAccent,
                                  ]),
                                  currentValue: _filteredFriends[index].friendship.progress,
                                  maxValue: 10,
                                )
                            ),
                          ],
                        );
                      } else {
                        return Container();
                      }

                },
              );

            },
          ),
          Container(
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.all(10),
            child: FloatingActionButton(
                onPressed: () {

            },
              child: const Icon(Icons.add),
            ),
          )
        ],
      ),
    );
  }
}
/*
SizedBox(
            height: 80,
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: _filteredFriends[index].photo,
                    ),
                    Column(
                      children: [
                        Text(_filteredFriends[index].name),
                        Text(_filteredFriends[index].username),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        children: [
                          Text("Lvl ${_filteredFriends[index].level}"),
                          Text('Last seen: ${_filteredFriends[index].lastSeen.year}')
                        ],
                      ),
                    )
                  ],
                ),
                LinearProgressIndicator(
                  value: _filteredFriends[index].progress,
                ),
              ],
            ),
          );
 */


