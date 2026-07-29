# ChoreCash

Flutter MVP for a household chore card game. It implements the complete card flow:

`request → issue by Služebník → complete → approve by Ruka → monthly cheque`

The app starts with an in-memory household so it can be reviewed without credentials. Use the role menu in the top-right corner to exercise each approval step.

## Run

```sh
flutter pub get
flutter run
```

## Firebase setup

The project includes Firebase Auth, Firestore and Messaging dependencies plus production-oriented Firestore rules. Connect a Firebase project before replacing `MansionStore` with a Firestore-backed store:

```sh
dart pub global activate flutterfire_cli
flutterfire configure
firebase deploy --only firestore
```

Expected collections are `users`, `chores`, `cards`, `chronicle`, and `payouts`. Chronicle entries and push notifications should be written by trusted backend code when a card changes state. The monthly Cloud Run job reads approved cards, applies the player's level multiplier, creates a payout, and stores the generated Revolut URL in `payouts`.
