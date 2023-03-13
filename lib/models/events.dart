
import 'friendships.dart';

class Events {
  static const double singleLinkEXP = 10;

  static Future<void> singleLinking(String userId, String friendId, DateTime dateTime) async {
    Friendship friendship = Friendship(ids: [userId, friendId]);

    await friendship.awaitFriendship();
    await friendship.addProgress(singleLinkEXP, dateTime: dateTime);
  }
}