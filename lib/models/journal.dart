import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Journal {
  late DateTime date;
  late String id;
  late ImageProvider picture;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Journal(this.id) {
    date = DateTime.now();
    picture = const NetworkImage('https://picsum.photos/200');
  }

  void addNewMemory(String friendshipID) {
    List<Journal> journals = [this];
    _db
        .collection('friendships')
        .doc(friendshipID) // <-- Document ID
        .set({'journals': FieldValue.arrayUnion(journals)}) // <-- Add data
        .then((_) => debugPrint('Added'))
        .catchError((error) => debugPrint('Add failed: $error'));
  }
}