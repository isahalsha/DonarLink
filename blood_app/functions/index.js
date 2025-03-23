const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.deleteExpiredPatientRequests = functions.pubsub
    .schedule("every 24 hours")
    .onRun(async (context) => {
        const now = admin.firestore.Timestamp.now();
        const twentyFourHoursAgo = new admin.firestore.Timestamp(
            now.seconds - 24 * 60 * 60,
            now.nanoseconds,
        );

        try {
            const querySnapshot = await admin.firestore()
                .collection("patient")
                .where("expiryTime", "<", twentyFourHoursAgo)
                .get();

            const deletePromises = [];
            querySnapshot.forEach((doc) => {
                deletePromises.push(
                    admin.firestore().collection("patient").doc(doc.id).delete(),
                );
            });

            await Promise.all(deletePromises);

            console.log(
                `Successfully deleted ${querySnapshot.size} expired patient requests.`,
            );
            return null;
        } catch (error) {
            console.error("Error deleting expired patient requests:", error);
            return null;
        }
    });

// Add empty line here