import 'package:myapp/models/social_rank.dart';
import 'package:myapp/providers/friends_provider.dart';

import 'friend.dart';
import 'friendships.dart';

class Events {
  static const double singleLinkEXP = 10;
  static const double singleLinkPow = 1;

  static const double dualLinkEXP = 5;
  static const double dualLinkPow = 3;

  static Future<void> singleLinking(String friendId, DateTime dateTime) async {
    Friendship friendship = FriendProvider()
        .friends
        .firstWhere((element) => (element.id == friendId))
        .friendship;

    await friendship.addProgress(singleLinkEXP, dateTime: dateTime);
    await SocialRank.addPower(singleLinkPow);
    await SocialRank.addPower(singleLinkPow, friendId: friendId);
  }

  static Future<void> dualLinking(
      List<String> friendsId, DateTime dateTime) async {
    int friendCounter = 0;
    List<Friend> alreadyFriends = [];
    List<String> notFriendsID = [];
    for (String friendId in friendsId) {
      bool alreadyFriend = !FriendProvider()
          .friends
          .every((existentFriend) => existentFriend.id != friendId);
      if (alreadyFriend) {
        Friend friend = FriendProvider()
            .friends
            .firstWhere((element) => (element.id == friendId));

        alreadyFriends.add(friend);
        friendCounter++;
      } else {
        notFriendsID.add(friendId);
      }
    }

    await SocialRank.addPower(dualLinkPow);
    for (Friend friend in alreadyFriends) {
      await friend.friendship.addProgress(
          dualLinkEXP * _multiplier(friendCounter),
          dateTime: dateTime);
      await SocialRank.addPower(dualLinkPow, friendId: friend.id);
    }
    for (String id in notFriendsID) {
      await SocialRank.addPower(dualLinkPow / 2, friendId: id);
    }
  }

  static double _multiplier(int counter) {
    return 1 + counter / 10;
  }
}
