const {
  onDocumentCreated,
  onDocumentUpdated,
  onDocumentDeleted,
} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore, FieldValue} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");

initializeApp();

function verbsForSex(sex) {
  if (sex === "female") {
    return {played: "zahrála", stored: "uložila", exchanged: "směnila"};
  }
  if (sex === "neutral") {
    return {played: "zahráli", stored: "uložili", exchanged: "směnili"};
  }
  return {played: "zahrál", stored: "uložil", exchanged: "směnil"};
}

exports.notifyPlayedCard = onDocumentCreated(
  "gangs/{gangId}/played_cards/{cardId}",
  async (event) => {
    const data = event.data.data();
    const gangId = event.params.gangId;
    const db = getFirestore();
    const verbs = verbsForSex(data.memberSex);

    await db.collection(`gangs/${gangId}/chronicle`).doc(`card_${event.params.cardId}`).set({
      type: "cardPlayed",
      actorNickname: data.memberNickname,
      title: data.choreTitle,
      message: `${verbs.played} kartu „${data.choreTitle}“ a ${verbs.stored} ${data.coinsAwarded} Coinů do Banku.`,
      choreId: data.choreId,
      symbol: data.choreSymbol || null,
      coins: data.coinsAwarded,
      monthKey: data.monthKey,
      levelAtEvent: data.levelAtPlay || null,
      heatAtEvent: data.heatAtPlay || null,
      createdAt: data.playedAt || FieldValue.serverTimestamp(),
    }, {merge: true});

    await getMessaging().send({
      topic: `gang_${gangId}`,
      notification: {
        title: `${data.memberNickname} ${verbs.played} kartu`,
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
    const verbs = verbsForSex(after.memberSex);

    await getFirestore()
      .collection(`gangs/${gangId}/chronicle`)
      .doc(`exchange_${event.params.exchangeId}`)
      .set({
        type: "exchangeApproved",
        actorNickname: after.memberNickname,
        title: "Směna schválena Rukou",
        message: `${after.memberNickname} ${verbs.exchanged} ${after.cardIds.length} karet za ${after.totalCoins} Coinů (${czk} Kč).`,
        symbol: "☞",
        coins: after.totalCoins,
        czkAmount: czk,
        cardCount: after.cardIds.length,
        monthKey: after.monthKey,
        createdAt: after.approvedAt || FieldValue.serverTimestamp(),
      }, {merge: true});
  },
);

exports.onGangDeleted = onDocumentDeleted(
  "gangs/{gangId}",
  async (event) => {
    const deleted = event.data ? event.data.data() : null;
    const gangId = event.params.gangId;
    const db = getFirestore();

    if (deleted && deleted.inviteCode) {
      await db.collection("invites").doc(String(deleted.inviteCode).toUpperCase()).delete();
    }

    const membersSnap = await db.collection(`gangs/${gangId}/members`).get();
    for (const memberDoc of membersSnap.docs) {
      await db.collection(`users/${memberDoc.id}/gangs`).doc(gangId).delete();
    }

    const subcollections = ["members", "played_cards", "exchanges", "chronicle"];
    for (const sub of subcollections) {
      const snap = await db.collection(`gangs/${gangId}/${sub}`).get();
      if (snap.empty) continue;
      const batch = db.batch();
      for (const doc of snap.docs) {
        batch.delete(doc.ref);
      }
      await batch.commit();
    }
  },
);
