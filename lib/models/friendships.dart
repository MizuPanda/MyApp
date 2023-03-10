import 'package:cloud_firestore/cloud_firestore.dart';

class Friendship {
  late double progress; //max = 100
  late DateTime lastSeen;
  late int level;
  List<String> ids;


  double max() {
    if(level < 10) {
      return level*10;
    }
    return 100;
  }

  String _docId() {
    return ids.first + ids.last;
  }
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('friendships');

  Friendship({required this.ids}) {
    ids.sort();
  }

  Future<void> awaitFriendship() async {
    DocumentSnapshot friendship =
        await _collection.doc(_docId()).get();
    progress = friendship.data().toString().contains('progress') ? friendship.get('progress').toDouble() : -1;
    level = friendship.data().toString().contains('level') ? friendship.get('level') : -1;
    lastSeen = friendship.data().toString().contains('lastSeen') ? DateTime.parse(friendship.get('lastSeen')) : DateTime.parse('');
  }

  Future<void> _verifyLevel() async{
    if(progress >= max()) {
      await _removeProgress(max());
      await _nextLevel();
    }
  }

  Future<void> _nextLevel() async {
    level++;
    await _collection.doc(_docId()).update({
      'level':level
    }
    );
  }

  Future<void> _removeProgress(double d) async {
    progress -= d;
    await _collection.doc(_docId()).update({
      'progress':progress
    }
    );
  }

  Future<void> addProgress(double d) async {
    progress += d;
    await _collection.doc(_docId()).update({
      'progress': progress
    }
    );
    await _verifyLevel();
  }
}
