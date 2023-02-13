import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Friendship {
  late double progress;
  late DateTime lastSeen;
  late int level;
  List<String> ids;

  final FirebaseAuth fb = FirebaseAuth.instance;
  final CollectionReference collection = FirebaseFirestore.instance.collection('friendships');

  Friendship({required this.ids}) {
    ids.sort();
    _setFriendship();
  }

  void _setFriendship() async {
    DocumentSnapshot friendship = await collection
        .doc(ids.first+ids.last)
        .get();
    progress = friendship.get('progress').toDouble();
    lastSeen = DateTime.parse(friendship.get('lastSeen'));
    level = friendship.get('level');
  }

}