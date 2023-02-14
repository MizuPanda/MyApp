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

  static final User _user = MyUser().getUser()!;
  static final _db = FirebaseFirestore.instance;

  Friend({required this.id}) {
    photo = const NetworkImage('https://picsum.photos/200');
    var ids = [_user.uid, id];
    ids.sort();
    friendship = Friendship(ids: ids);
  }

  Future<String> setName() async {
    DocumentSnapshot docs = await _getUserData(id);

    name = docs.get('name');
    username = docs.get('username');

    await friendship.setFriendship();
    return name;
  }

  static Future<List<dynamic>> getFriendsID() async {
    DocumentSnapshot docs = await _getUserData(_user.uid);
    return docs.get('friends');
  }

  static Future<DocumentSnapshot> _getUserData(String id) async {
    DocumentSnapshot docs = await _db.collection('users').doc(id).get();

    return docs;
  }
}
