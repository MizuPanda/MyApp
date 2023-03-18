import 'package:cloud_firestore/cloud_firestore.dart';

import 'myuser.dart';

class UserData {
  static final CollectionReference<Map<String, dynamic>> _users =
      FirebaseFirestore.instance.collection('users');

  static Future<DocumentSnapshot> getData({String? id, int? counter}) async {
    if (id != null) {
      return await _getUserByID(id);
    } else if (counter != null) {
      return await _getUserByCounter(counter);
    } else {
      return await _users.doc(MyUser.id()).get();
    }
  }

  static Future<DocumentSnapshot> _getUserByID(String id) async {
    return await _users.doc(id).get();
  }

  static Future<DocumentSnapshot> _getUserByCounter(int counterValue) async {
    final querySnapshot =
        await _users.where('counter', isEqualTo: counterValue).get();

    final userDoc = querySnapshot.docs.first;
    return userDoc;
  }
}
