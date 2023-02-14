import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Friendship {
  late double progress;
  late DateTime lastSeen;
  late int level;
  List<String> ids;

  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('friendships');

  Friendship({required this.ids}) {
    ids.sort();
  }

  Future<void> setFriendship() async {
    DocumentSnapshot friendship =
        await _collection.doc(ids.first + ids.last).get();
    progress = friendship.get('progress').toDouble();
    lastSeen = DateTime.parse(friendship.get('lastSeen'));
    level = friendship.get('level');
  }
}
