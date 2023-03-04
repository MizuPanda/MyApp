import 'package:cloud_firestore/cloud_firestore.dart';

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

  Future<void> awaitFriendship() async {
    DocumentSnapshot friendship =
        await _collection.doc(ids.first + ids.last).get();
    progress = friendship.data().toString().contains('progress') ? friendship.get('progress').toDouble() : -1;
    level = friendship.data().toString().contains('level') ? friendship.get('level') : -1;
    lastSeen = friendship.data().toString().contains('lastSeen') ? DateTime.parse(friendship.get('lastSeen')) : DateTime.parse('');
    //journals = _collection.doc(ids.first + ids.last).collection('journals').get();
    //List<String> journalID = friendship.get('journals');
  }
}
