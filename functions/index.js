const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.selectPictureTaker = functions.firestore
    .document("friendships/{friendshipId}/values/ready")
    .onUpdate((change, context) => {
      const newValue = change.after.data();

      console.log(String(newValue.ready0));
      console.log(String(newValue.ready1));

      /*
      Check if the ready array has changed.
      Check the values are equal to "ready"
      */
      if (newValue.ready0 === true &&
        newValue.ready1 === true) {
        // Get the two friend IDs
        const friendshipDoc = admin.firestore().collection("friendships")
            .doc(context.params.friendshipId);
        console.log(String(friendshipDoc));

        return friendshipDoc.get().then((snapshot) => {
          console.log(String(snapshot));
          const ids = snapshot.data().friends;

          // Select a random friend ID
          const index = Math.floor(Math.random() * ids.length);
          const randomFriend = ids[index];
          console.log(String(randomFriend));

          /*
          Update the pictureTaker field with the chosen ID.
          Set ready back to false
          */
          return change.after.ref.update({
            ready0: false,
            ready1: false,
          }).then((_) => {
            return admin.firestore().collection("friendships")
                .doc(context.params.friendshipId).update({
                  pictureTaker: randomFriend,
                });
          });
        }).catch((err) => {
          console.log("Error getting document", err);
        });
      }

      return null;
    });
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
