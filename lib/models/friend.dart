import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import 'friendships.dart';
import 'myuser.dart';

class Friend {
  final String id;
  late String name;
  late String username;
  late ImageProvider photo;
  late Friendship friendship;

  static final _fb = FirebaseAuth.instance;

  Friend({required this.id}) {
    photo = const NetworkImage('https://picsum.photos/200');
    var ids = [_fb.currentUser!.uid, id];
    ids.sort();
    friendship = Friendship(ids: ids);
  }

  Future<String> awaitFriend() async {
    DocumentSnapshot docs = await MyUser.getUserData(id);

    name = docs.get('name');
    username = docs.get('username');

    await friendship.awaitFriendship();
    return name;
  }

  static Future<List<dynamic>> getFriendsID() async {
    Player player = await MyUser.getInstance();
    return player.friendsID;
  }

}
