import 'package:firebase_auth/firebase_auth.dart';

import '../models/myuser.dart';

class MainProvider {
  final MyUser myUser = MyUser();

  User? getUser() {
    return myUser.getUser();
  }
}
