import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/myuser.dart';

class SocialRank {
  static Future<void> addPower(double d) async {
    String id = MyUser.getUser()!.uid;
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot docs = await db
        .collection('users')
        .doc(id)
        .get();
    double power = docs.data().toString().contains('power') ? docs.get('power') : 0;

    await db
        .collection('users')
        .doc(id)
        .update({
         'power': power + d});
  }
}