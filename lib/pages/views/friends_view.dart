import 'package:flutter/material.dart';
import 'package:myapp/providers/friends_provider.dart';


import '../../models/friend.dart';
import '../../widgets/expandable.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> with AutomaticKeepAliveClientMixin {
  final FriendProvider _provider = FriendProvider();


  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnimatedBuilder(
      animation: _provider,
      builder: (BuildContext context, Widget? child) {
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
              const FriendListView(),
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
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class FriendListItem extends StatelessWidget {
  final Friend friend;


  const FriendListItem({super.key, required this.friend});


  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: friend.photo,
      ),
      title: Text(maxLines: 1, friend.name),
      subtitle: Text(friend.username),
      trailing: SizedBox(
        width: 175,
        child: Column(
          children: [
            Align(
                alignment: Alignment.centerRight,
                child:
                Text('Lvl ${friend.friendship.level}')),
            const Spacer(),
            const Align(
                alignment: Alignment.centerRight,
                child: Text('Last seen')),
            Align(
                alignment: Alignment.centerRight,
                child: Text(friend.friendship.timeAgo())
            )
          ],
        ),
      ),
    );
  }
}

