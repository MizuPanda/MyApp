import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/providers/nearby_provider.dart';

class Friendship {
  late double progress; //max = 100
  late DateTime lastSeen;
  late int level;
  List<String> ids;
  bool newLevel = false;

  double max() {
    if (level < 10) {
      return level * 10;
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
    DocumentSnapshot friendship = await _collection.doc(_docId()).get();
    progress = friendship.data().toString().contains('progress')
        ? friendship.get('progress').toDouble()
        : -1;
    level = friendship.data().toString().contains('level')
        ? friendship.get('level')
        : -1;
    lastSeen = friendship.data().toString().contains('lastSeen')
        ? DateTime.parse(friendship.get('lastSeen'))
        : DateTime.parse('');
  }

  void _verifyLevel() {
    if (progress >= max()) {
      _removeProgress(max());
      _nextLevel();
    }
  }

  void _nextLevel() {
    level++;
    //await _collection.doc(_docId()).update({'level': level});
    newLevel = true;
  }

  void _removeProgress(double d) {
    progress -= d;
    //await _collection.doc(_docId()).update({'progress': progress});
  }

  Future<void> addProgress(double d, {DateTime? dateTime}) async {
    progress += d;
    _verifyLevel();
    if(dateTime != null) {
      await _collection.doc(_docId()).update(
          {
            'progress': progress,
            'lastSeen': DateTime.now().toUtc().toString(),
            'level':level,
            'pictureTaker': NearbyProvider.taken
          }
      );
    } else {
      await _collection.doc(_docId()).update({
        'progress': progress,
        'level':level
      });
    }
  }
}

enum ProgressCase {
  single
}
