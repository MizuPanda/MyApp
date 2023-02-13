import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class FriendRequest {
  final FirebaseAuth fb = FirebaseAuth.instance;
  final CollectionReference collection = FirebaseFirestore.instance.collection('users');
  
  Future<void> sendFriendRequest(String receiverUsername) async {
    // Add the sender's ID to the receiver's requests
    User user = fb.currentUser!;
    String senderId = user.uid;
    DocumentSnapshot receiver = await getUserByUsername(receiverUsername);
    await collection.doc(receiver.id).update({
      'requests': FieldValue.arrayUnion([senderId])
    });
  }

  Future<void> acceptFriendRequest(String receiverUsername) async {
    // Remove the sender's ID from the receiver's requests
    User user = fb.currentUser!;
    String senderId = user.uid;
    DocumentSnapshot receiver = await getUserByUsername(receiverUsername);
    await collection.doc(receiver.id).update({
      'requests': FieldValue.arrayRemove([senderId])
    });

    // Add the sender's ID to the receiver's friends
    await collection.doc(receiver.id).update({
      'friends': FieldValue.arrayUnion([senderId])
    });

    // Add the receiver's ID to the sender's friends
    await collection.doc(senderId).update({
      'friends': FieldValue.arrayUnion([receiver.id])
    });

    List<String> ids = [senderId, receiver.id];
    ids.sort();
    final friendshipInfo = <String, dynamic>{
      "friends": [ids.first, ids.last],
      "level": 0,
      "progress": 0,
      'lastSeen': DateTime.now().toString()
    };

    ids.sort();
    await FirebaseFirestore.instance
        .collection('friendships')
        .doc(ids.first + ids.last)
        .set(friendshipInfo)
        .whenComplete(() => debugPrint("Successfully added the data to friendship."))
        .onError((e, _) => debugPrint("Error writing document: $e"));
  }

  Future<DocumentSnapshot> getUserByUsername(String username) async {
    DocumentSnapshot userSnapshot = await collection
        .where("username", isEqualTo: username)
        .get()
        .then((querySnapshot) {
      return querySnapshot.docs.first;
    }
    );
    return userSnapshot;
  }
}