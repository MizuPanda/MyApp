import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:myapp/models/events.dart';
import 'package:myapp/models/myuser.dart';

class FriendRequest {
  static final CollectionReference _collection =
      FirebaseFirestore.instance.collection('users');

  static Future<void> sendFriendRequest(String receiverId) async {
    // Add the sender's ID to the receiver's requestId
    User user = MyUser.getUser()!;
    String senderId = user.uid;
    await _collection.doc(receiverId).update({'requestId': senderId});
  }

  static Future<void> removeFriendRequest() async {
    await _collection.doc(MyUser.getUser()!.uid).update({'requestId': ''});
  }

  static Future<void> accomplishLinking(DateTime dateTime) async {
    String userId = MyUser.getUser()!.uid;

    //Get requestId
    DocumentSnapshot senderData = await _collection.doc(userId).get();
    String requestId = senderData.data().toString().contains('requestId')
        ? senderData.get('requestId')
        : '';
    List<dynamic> friendsID = senderData.data().toString().contains('friends')
        ? senderData.get('friends')
        : List.empty();

    // Set requestId to none
    await removeFriendRequest();
    await _collection.doc(requestId).update({'requestId': ''});

    //Player player = await MyUser.getInstance();
    bool isFriend = friendsID.every((id) => id == requestId);
    debugPrint(friendsID.toString());

    if (isFriend) {
      await Events.singleLinking(requestId, dateTime);
    } else {
      await _setNewFriends(userId, requestId, dateTime);
    }

    List<String> ids = [userId, requestId];
    ids.sort();
  }

  static Future<void> _setNewFriends(
      String userId, String requestId, DateTime dateTime) async {
    // Add the request ID to the friends list
    await _collection.doc(requestId).update({
      'friends': FieldValue.arrayUnion([userId]),
      'power': FieldValue.increment(Events.singleLinkPow)
    });
    await _collection.doc(userId).update({
      'friends': FieldValue.arrayUnion([requestId]),
      'power': FieldValue.increment(Events.singleLinkPow)
    });

    //Create a new friendship
    _createFriendship(userId, requestId, dateTime);
  }

  static void _createFriendship(
      String senderId, String receiverId, DateTime dateTime) async {
    DocumentSnapshot receiver = await _collection.doc(receiverId).get();

    List<String> ids = [senderId, receiver.id];
    ids.sort();
    final friendshipInfo = <String, dynamic>{
      "friends": [ids.first, ids.last],
      "level": 0,
      "progress": 0,
      'lastSeen': dateTime.toString(),
      'pictureTaker': '',
      'memories': [],
      'newLevel0': false,
      'newLevel1': false,
    };
    final readyInfo = <String, dynamic>{
      'ready0': false,
      'ready1': false,
    };

    String docId = ids.first + ids.last;
    await FirebaseFirestore.instance
        .collection('friendships')
        .doc(docId)
        .set(friendshipInfo)
        .whenComplete(
            () => debugPrint("Successfully added the data to friendship."))
        .onError((e, _) => debugPrint("Error writing document: $e"));
    await FirebaseFirestore.instance
        .collection('friendships')
        .doc(docId)
        .collection('values')
        .doc('ready')
        .set(readyInfo)
        .whenComplete(
            () => debugPrint("Successfully added the ready to friendship."))
        .onError((e, _) => debugPrint("Error writing ready document: $e"));
  }
}
