const {onDocumentUpdated} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore, FieldValue} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");

initializeApp();

exports.notifyCompletedCard = onDocumentUpdated("cards/{cardId}", async (event) => {
  const before = event.data.before.data();
  const after = event.data.after.data();
  if (before.status === "completed" || after.status !== "completed") return;

  const title = `${after.ownerNickname} zahrál kartu`;
  const body = `${after.choreTitle} je splněno a padá do balíčku.`;
  const db = getFirestore();

  await db.collection("chronicle").add({
    actor: after.ownerNickname,
    message: `zahrál kartu „${after.choreTitle}“ a dokončil úkol!`,
    cardId: after.choreId,
    cardTitle: after.choreTitle,
    createdAt: FieldValue.serverTimestamp(),
    type: "cardCompleted",
  });

  await getMessaging().send({
    topic: "household",
    notification: {title, body},
    data: {cardId: after.choreId, type: "cardCompleted"},
  });
});

exports.recordAccountingRequest = onDocumentUpdated("cards/{cardId}", async (event) => {
  const before = event.data.before.data();
  const after = event.data.after.data();
  if (before.status !== "completed" || after.status !== "approved") return;

  await getFirestore().collection("chronicle").add({
    actor: after.ownerNickname,
    message: `poslal kartu „${after.choreTitle}“ Ruce k zúčtování.`,
    cardId: after.choreId,
    cardTitle: after.choreTitle,
    createdAt: FieldValue.serverTimestamp(),
    type: "accountingRequested",
  });
});
