import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:myapp/models/myuser.dart';

class FriendRequest {
  static final FirebaseAuth _fb = FirebaseAuth.instance;
  static final CollectionReference _collection =
      FirebaseFirestore.instance.collection('users');

  static Future<void> sendFriendRequest(String receiverUsername) async {
    // Add the sender's ID to the receiver's requestId
    User user = _fb.currentUser!;
    String senderId = user.uid;
    DocumentSnapshot receiver = await _getUserByUsername(receiverUsername);
    await _collection.doc(receiver.id).update({
      'requestId': senderId
    });
  }

  static Future<void> removeFriendRequest() async {
      await _collection.doc(MyUser.getUser()!.uid).update({
        'requestId': ''
      });
  }

  static Future<bool> verifyRequestId(String friendUsername) async {
    User user = _fb.currentUser!;
    String senderId = user.uid;

    //Get sender's requestId
    DocumentSnapshot senderData = await _collection.doc(senderId).get();
    String senderRequest = senderData.get('requestId');

    //Get receiver's requestId
    DocumentSnapshot receiverData = await _getUserByUsername(friendUsername);
    String receiverRequest = receiverData.get('requestId');

    //Verify if both are equal
    return (senderRequest == receiverData.id) && (receiverRequest == senderId);
  }

  static Future<void> acceptFriendRequest(String friendUsername) async {
    User user = _fb.currentUser!;
    String userId = user.uid;

    //Get requestId
    DocumentSnapshot senderData = await _collection.doc(userId).get();
    String requestId = senderData.data().toString().contains('requestId') ? senderData.get('requestId') : '';

    if(requestId.isNotEmpty) {
      // Set requestId to none
      removeFriendRequest();
      DocumentSnapshot friendDoc = await _getUserByUsername(friendUsername);
      await _collection.doc(friendDoc.id).update({
        'requestId': ''
      });

      // Add the request ID to the friends list
      await _collection.doc(requestId).update({
        'friends': FieldValue.arrayUnion([userId])
      });
      await _collection.doc(userId).update({
        'friends': FieldValue.arrayUnion([requestId])
      });

      //Create a new friendship
      createFriendship(requestId);
    }
  }

  static void createFriendship(String receiverId) async {
    User user = _fb.currentUser!;
    String senderId = user.uid;
    DocumentSnapshot receiver = await _collection.doc(receiverId).get();

    List<String> ids = [senderId, receiver.id];

    DocumentSnapshot docs = await FirebaseFirestore.instance.collection('friendships').doc(ids.first + ids.last).get();
    if(!docs.exists) {
      ids.sort();
      final friendshipInfo = <String, dynamic>{
        "friends": [ids.first, ids.last],
        "level": 0,
        "progress": 0,
        'lastSeen': DateTime.now().toString()
      };

      await FirebaseFirestore.instance
          .collection('friendships')
          .doc(ids.first + ids.last)
          .set(friendshipInfo)
          .whenComplete(
              () => debugPrint("Successfully added the data to friendship."))
          .onError((e, _) => debugPrint("Error writing document: $e"));
    }
  }

  static Future<DocumentSnapshot> _getUserByUsername(String username) async {
    DocumentSnapshot userSnapshot = await _collection
        .where("username", isEqualTo: username)
        .get()
        .then((querySnapshot) {
      return querySnapshot.docs.first;
    });
    return userSnapshot;
  }
}
