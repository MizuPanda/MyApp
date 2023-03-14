import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/myuser.dart';

class SocialRank {
  static Future<void> addPower(double d, {String? friendId}) async {
    String id;
    if(friendId != null) {
      id = friendId;
    } else {
      id = MyUser.getUser()!.uid;
    }

    FirebaseFirestore db = FirebaseFirestore.instance;


    await db
        .collection('users')
        .doc(id)
        .update({
         'power': FieldValue.increment(d)
        });
  }
}