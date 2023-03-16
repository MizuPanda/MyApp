import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'myuser.dart';

class Friendship {
  late double progress; //max = 100
  late DateTime lastSeen;
  late int level;
  late List<dynamic> newLevels;
  late List<dynamic> memories;

  late final int userIndex;
  List<String> ids;

  double max() {
    if (level == 0) {
      return 5;
    }
    if (level < 10) {
      return level * 10;
    }
    return 100;
  }

  String _docId() {
    return ids.first + ids.last;
  }

  String timeAgo() {
    return timeago.format(lastSeen);
  }

  static final CollectionReference _collection =
      FirebaseFirestore.instance.collection('friendships');

  Friendship({required this.ids}) {
    String userId = MyUser.getUser()!.uid;
    userIndex = ids.indexOf(userId);
    ids.sort();
  }

  Future<void> awaitFriendship() async {
    String docId = _docId();
    DocumentSnapshot friendship = await _collection.doc(docId).get();
    String data = friendship.data().toString();
    progress =
        data.contains('progress') ? friendship.get('progress').toDouble() : -1;
    level = data.contains('level') ? friendship.get('level') : -1;
    lastSeen = data.contains('lastSeen')
        ? DateTime.parse(friendship.get('lastSeen'))
        : DateTime.parse('');
    bool newLevel0 =
        data.contains('newLevel0') ? friendship.get('newLevel0') : false;
    bool newLevel1 =
        data.contains('newLevel1') ? friendship.get('newLevel1') : false;
    newLevels = [newLevel0, newLevel1];
    memories =
        data.contains('memories') ? friendship.get('memories') : List.empty();
  }

  Future<void> hasAnimatedLevel() async {
    newLevels[userIndex] = false;
    await _collection.doc(_docId()).update({'newLevel$userIndex': false});
  }

  void _verifyLevel() {
    if (progress >= max()) {
      _removeProgress(max());
      _nextLevel();
    }
  }

  void _nextLevel() {
    level++;
    newLevels.first = true;
    newLevels.last = true;
  }

  void _removeProgress(double d) {
    progress -= d;
  }

  Future<void> addProgress(double d, {DateTime? dateTime}) async {
    progress += d;
    _verifyLevel();
    String docId = _docId();
    if (dateTime != null) {
      lastSeen = dateTime;

      await _collection.doc(docId).update({
        //IN CASE OF SINGLE LINK
        'progress': progress,
        'lastSeen': lastSeen.toString(),
        'level': level,
        'newLevel0': newLevels.first,
        'newLevel1': newLevels.last,
        'memories': FieldValue.arrayUnion([dateTime.toString()]),
      });
    } else {
      await _collection.doc(_docId()).update({
        'progress': progress,
        'level': level,
        'newLevel0': newLevels.first,
        'newLevel1': newLevels.last
      });
    }
  }
}
