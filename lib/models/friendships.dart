import 'package:cloud_firestore/cloud_firestore.dart';

import 'journal.dart';

class Friendship {
  late double progress;
  late List<Journal> journals;
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
    level = friendship.get('level');
    lastSeen = getLastSeen();
    //journals = _collection.doc(ids.first + ids.last).collection('journals').get();
    //List<String> journalID = friendship.get('journals');
  }

  DateTime getLastSeen() {
    return DateTime.now();
    //return journals.last.date;
  }
}
