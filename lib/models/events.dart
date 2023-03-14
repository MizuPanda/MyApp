
import 'package:myapp/models/social_rank.dart';
import 'package:myapp/providers/friends_provider.dart';

import 'friendships.dart';

class Events {
  static const double singleLinkEXP = 10;
  static const double singleLinkPow = 1;

  static Future<void> singleLinking(String friendId, DateTime dateTime) async {
    Friendship friendship = FriendProvider().friends.where((element) => (element.id == friendId)).first.friendship;

    await friendship.addProgress(singleLinkEXP, dateTime: dateTime);
    await SocialRank.addPower(singleLinkPow);
    await SocialRank.addPower(singleLinkPow, friendId: friendId);
  }
}