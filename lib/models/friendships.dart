import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/providers/nearby_provider.dart';
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

  String timeAgo() {
    DateTime dateTime = lastSeen.toLocal();
    return timeago.format(dateTime);
  }
  double max() {
    if (level < 10) {
      return level * 10;
    }
    return 100;
  }
  String _docId() {
    return ids.first + ids.last;
  }

  static final CollectionReference _collection =
      FirebaseFirestore.instance.collection('friendships');

  Friendship({required this.ids}) {
    String userId = MyUser.getUser()!.uid;
    userIndex = ids.indexOf(userId);
    ids.sort();
  }

  static Future<void> removePictureTaker(String docId) async {
    await _collection.doc(docId).update({
      'pictureTaker': ''
    });
  }

  Future<void> awaitFriendship() async {
    DocumentSnapshot friendship = await _collection.doc(_docId()).get();
    String data = friendship.data().toString();
    progress = data.contains('progress')
        ? friendship.get('progress').toDouble()
        : -1;
    level = data.contains('level')
        ? friendship.get('level')
        : -1;
    lastSeen = data.contains('lastSeen')
        ? DateTime.parse(friendship.get('lastSeen'))
        : DateTime.parse('');
    newLevels = data.contains('newLevels')? friendship.get('newLevels'): List.empty();
    memories =  data.contains('memories')? friendship.get('memories'): List.empty();
  }

  Future<void> hasAnimatedLevel() async {
    newLevels[userIndex] = false;
    await _collection.doc(_docId()).update({
      'newLevels': newLevels
    });
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

    if(dateTime != null) {
      await _collection.doc(_docId()).update(
          { //IN CASE OF SINGLE LINK
            'progress': progress,
            'lastSeen': dateTime.toString(),
            'level':level,
            'pictureTaker': NearbyProvider.taken,
            'memories': FieldValue.arrayUnion([dateTime]),
            'newLevels': newLevels
          }
      );
    } else {
      await _collection.doc(_docId()).update({
        'progress': progress,
        'level':level,
        'newLevels': newLevels
      });
    }
  }
}


