import 'package:flutter/material.dart';
import 'package:myapp/pages/views/subviews/friend_list_view.dart';
import 'package:myapp/providers/friends_provider.dart';

import '../../widgets/expandable.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage>
    with AutomaticKeepAliveClientMixin {
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
                  focusNode: _provider.focusNode,
                  controller: _provider.searchController,
                  onTapOutside: (_) => {
                        WidgetsBinding.instance
                            .addPostFrameCallback((timeStamp) {
                          _provider.focusNode.unfocus();
                        })
                      },
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    fillColor: Colors.white,
                    filled: true,
                    hintText: 'Search friends',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _provider.clear,
                    ),
                  ),
                  onChanged: _provider.search),
              actions: [
                IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.groups,
                    )),
                PopupMenuButton(
                  icon: const Icon(Icons.format_list_bulleted_rounded),
                  onSelected: _provider.changeFilter,
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<Filters>>[
                    const PopupMenuItem<Filters>(
                      value: Filters.name,
                      child: Text('By name'),
                    ),
                    const PopupMenuItem<Filters>(
                      value: Filters.bestFriends,
                      child: Text('By best friends'),
                    ),
                    const PopupMenuItem<Filters>(
                      value: Filters.lastSeen,
                      child: Text('By last seen'),
                    ),
                  ],
                )
              ],
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
                        onPressed: () {
                          _provider.showDualLinkingDialog(context);
                        },
                        icon: const Icon(Icons.thunderstorm),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
