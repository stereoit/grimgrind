const {onDocumentCreated, onDocumentUpdated} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore, FieldValue} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");

initializeApp();

exports.notifyPlayedCard = onDocumentCreated(
  "gangs/{gangId}/played_cards/{cardId}",
  async (event) => {
    const data = event.data.data();
    const gangId = event.params.gangId;
    const db = getFirestore();

    await db.collection(`gangs/${gangId}/feed`).add({
      type: "cardPlayed",
      actorNickname: data.memberNickname,
      title: data.choreTitle,
      message: `zahrál kartu „${data.choreTitle}“ a uložil ${data.coinsAwarded} Coinů do Banku.`,
      choreId: data.choreId,
      coins: data.coinsAwarded,
      monthKey: data.monthKey,
      createdAt: FieldValue.serverTimestamp(),
    });

    await getMessaging().send({
      topic: `gang_${gangId}`,
      notification: {
        title: `${data.memberNickname} zahrál kartu`,
        body: `${data.choreTitle} (+${data.coinsAwarded} Coinů do Banku).`,
      },
      data: {gangId, choreId: data.choreId, type: "cardPlayed"},
    });
  },
);

exports.recordApprovedExchange = onDocumentUpdated(
  "gangs/{gangId}/exchanges/{exchangeId}",
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();
    if (before.status === "approved" || after.status !== "approved") return;

    const gangId = event.params.gangId;
    const czk = Math.round(after.totalCoins / (after.coinsPerCzk || 10));

    await getFirestore().collection(`gangs/${gangId}/feed`).add({
      type: "exchangeApproved",
      actorNickname: after.memberNickname,
      title: "Směna schválena Rukou",
      message: `${after.memberNickname} směnili ${after.cardIds.length} karet za ${after.totalCoins} Coinů (${czk} Kč).`,
      coins: after.totalCoins,
      czkAmount: czk,
      cardCount: after.cardIds.length,
      monthKey: after.monthKey,
      createdAt: FieldValue.serverTimestamp(),
    });
  },
);
