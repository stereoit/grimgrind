# GrimGrind

Temná karetní hra, která mění domácí povinnosti na questy a odměny.

Herní tok: `vzít kartu → splnit → požádat Ruku o zúčtování → získat odměnu`.

## Lokální spuštění

```sh
flutter pub get
flutter run
```

Demo používá lokální `MansionStore`, takže funguje bez cloudových přístupů. Výtvarná pravidla a prompty pro konzistentní generování grafik jsou v [DESIGN.md](DESIGN.md).

## Distribuce členům domácnosti

Workflow [`.github/workflows/distribute.yml`](.github/workflows/distribute.yml) se spouští automaticky při každém commitu do větve `main`, při vytvoření tagu `v*` nebo ručně v GitHub Actions.

Po každém commitu do `main`:
1. Ověří kód (`flutter analyze`, `flutter test`).
2. Sestaví Android APK (pokud není nastavený `ANDROID_KEYSTORE_BASE64`, podepíše jej automaticky debug klíčem).
3. Nahraje `grimgrind.apk` jako artefakt běhu v GitHub Actions a zároveň publikuje nový **GitHub Release**, takže nejnovější APK lze v Android telefonu vždy stáhnout přímo z adresy:
   - **`https://github.com/stereoit/grimgrind/releases/latest/download/grimgrind.apk`**
4. Volitelně odešle build do Firebase App Distribution a sestaví iOS IPA, jakmile jsou v repozitáři nastavené příslušné GitHub Secrets.

### 1. Firebase

1. Vytvoř projekt ve [Firebase Console](https://console.firebase.google.com/).
2. Přidej Android aplikaci s package ID `cz.chorecash.chore_cash`.
3. Přidej iOS aplikaci s bundle ID `cz.chorecash.choreCash`.
4. Otevři **App Distribution → Testers & Groups**, vytvoř skupinu `household` a přidej e-maily členů. Veřejný zvací odkaz pro testery je `https://appdistribution.firebase.dev/i/152f586ed88ca49c`.
5. V Google Cloud Console vytvoř service account s rolemi **Firebase App Distribution Admin** a **Cloud Datastore User** (pro automatický zápis verze do Firestore `app_config/distribution`) a stáhni JSON klíč.
6. Z Firebase nastavení obou aplikací si poznamenej App ID ve tvaru `1:123456789:android:...` a `1:123456789:ios:...` a stáhni konfigurační soubory `google-services.json` (Android) a `GoogleService-Info.plist` (iOS).

### 2. Android podpis

Vytvoř upload klíč. Soubor ani hesla necommituj:

```sh
keytool -genkeypair -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
base64 < upload-keystore.jks | tr -d '\n' | pbcopy
```

Obsah schránky vlož do GitHub secretu `ANDROID_KEYSTORE_BASE64`.

### 3. iOS podpis

iOS distribuce mimo App Store vyžaduje placený **Apple Developer Program** a předem registrovaná zařízení testerů.

1. V Apple Developer portálu zaregistruj App ID `cz.chorecash.choreCash`.
2. Získej UDID všech iPhonů členů a přidej je do **Devices**.
3. Vytvoř **Apple Distribution** certifikát a exportuj jej z Keychain Access jako `.p12` s heslem.
4. Vytvoř **Ad Hoc provisioning profile** pro App ID a všechna registrovaná zařízení. Stáhni `.mobileprovision` a poznamenej přesný název profilu.
5. Zakóduj oba soubory:

```sh
base64 < distribution.p12 | tr -d '\n' | pbcopy
base64 < GrimGrind_AdHoc.mobileprovision | tr -d '\n' | pbcopy
```

Pro veřejnější iOS distribuci bez sběru UDID je vhodnější TestFlight; vyžaduje samostatné App Store Connect API nastavení a Apple review pro externí testery.

> Poznámka: Flutter při exportu pojmenuje výsledný soubor `grimgrind.ipa`; workflow s tímto názvem počáta.

### 4. GitHub Secrets

V repozitáři otevři **Settings → Secrets and variables → Actions → New repository secret** a nastav:

| Secret | Hodnota |
| --- | --- |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | Celý obsah JSON klíče service accountu |
| `FIREBASE_ANDROID_APP_ID` | Firebase Android App ID |
| `FIREBASE_IOS_APP_ID` | Firebase iOS App ID |
| `GOOGLE_SERVICES_JSON_BASE64` | Base64 `google-services.json` (pro in-app kontrolu verzí a Firebase na Androidu) |
| `GOOGLE_SERVICE_INFO_PLIST_BASE64` | Base64 `GoogleService-Info.plist` (pro in-app kontrolu verzí a Firebase na iOS) |
| `ANDROID_KEYSTORE_BASE64` | Base64 Android keystore |
| `ANDROID_KEYSTORE_PASSWORD` | Heslo keystore |
| `ANDROID_KEY_PASSWORD` | Heslo klíče |
| `ANDROID_KEY_ALIAS` | `upload` nebo zvolený alias |
| `IOS_CERTIFICATE_BASE64` | Base64 `.p12` certifikát |
| `IOS_CERTIFICATE_PASSWORD` | Heslo `.p12` |
| `IOS_PROVISIONING_PROFILE_BASE64` | Base64 Ad Hoc profilu |
| `IOS_PROFILE_NAME` | Přesný název provisioning profilu |
| `APPLE_TEAM_ID` | Desetiznakové Apple Team ID |
| `KEYCHAIN_PASSWORD` | Libovolné silné dočasné heslo pro CI keychain |

### 5. První vydání

1. Pushni repozitář na GitHub.
2. Otevři **Actions → Distribute GrimGrind → Run workflow**.
3. Po úspěchu Firebase rozešle skupině `household` pozvánku. Android uživatelé instalují APK přes Firebase App Tester; iOS instalace funguje pouze na zařízeních obsažených v Ad Hoc profilu.
4. Další verzi vydáš tagem, například `git tag v1.0.1 && git push origin v1.0.1`.

### 6. Přidání dalšího iOS testera (nové UDID)

Pokud chceš aplikaci nasdílet dalšímu kamarádovi s iPhonem:

1. **Apple Developer Portal → Devices**: Přidej jeho UDID jako nové zařízení.
2. **Profiles**: Otevři svůj **Ad Hoc provisioning profile**, zaškrtni nově přidané zařízení, profil znovu vygeneruj (**Generate**) a stáhni aktualizovaný `.mobileprovision` soubor.
3. **GitHub Secrets**: Zakóduj aktualizovaný profil a přepiš secret `IOS_PROVISIONING_PROFILE_BASE64` (pokud se změnil název profilu, aktualizuj i `IOS_PROFILE_NAME`):
   ```sh
   base64 < GrimGrind_AdHoc.mobileprovision | tr -d '\n' | pbcopy
   ```
4. **Firebase Console → App Distribution → Testers & Groups**: Přidej e-mail kamaráda do skupiny `household` (nebo mu pošli veřejný zvací odkaz `https://appdistribution.firebase.dev/i/152f586ed88ca49c`).
5. **Spusť nový build**: V **GitHub Actions → Distribute GrimGrind → Run workflow** (nebo pushem do `main`) se sestaví nové `.ipa` podepsané aktualizovaným profilem a Firebase ho rozešle všem ve skupině `household`.

## Firebase backend

Repozitář obsahuje Firebase Auth, Firestore a Messaging závislosti a Firestore pravidla. Před nahrazením lokálního store spusť:

```sh
dart pub global activate flutterfire_cli
flutterfire configure
firebase deploy --only firestore
```

Projekt je navázaný přes `.firebaserc` na Firebase project ID `grim-grind`. Pro aktivaci push notifikací a serverových zápisů do Kroniky je nutné se na počítači vlastníka jednou přihlásit a nasadit funkce:

```sh
npx firebase-tools login
npx firebase-tools deploy --project grim-grind --only firestore,functions,hosting
```

Cloud Functions `notifyPlayedCard`, `recordApprovedExchange` a `onGangDeleted` reagují na zahrání karty do `gangs/{gangId}/played_cards`, schválení směny v `gangs/{gangId}/exchanges` a smazání Gangu `gangs/{gangId}` (rekurzivní úklid subkolekcí a `invites/{code}`), zapisují záznamy do `gangs/{gangId}/feed` (včetně skloňování podle `memberSex`) a odesílají FCM zprávy na topic `gang_{gangId}`. Mobilní klient musí po přihlášení uložit FCM token a přihlásit jej k tomuto topicu; pro produkční zapojení je rovněž nutné vygenerovat `firebase_options.dart` příkazem `flutterfire configure --project grim-grind`.

Kolekce jsou `gangs/{gangId}/members`, `gangs/{gangId}/played_cards`, `gangs/{gangId}/exchanges`, `gangs/{gangId}/feed`, veřejný zvací index `invites/{inviteCode}` a `users/{userId}/gangs/{gangId}`.

### Zvací odkazy (Firebase Hosting & App Links)
- Webová pozvánka běží na `https://grim-grind.web.app/join?code=<CODE>` ([`hosting/public/join.html`](hosting/public/join.html)), odkud lze aplikaci rovnou otevřít (`grimgrind://join?code=<CODE>`) nebo nainstalovat.
- Pro ověřené Android App Links a iOS Universal Links doplň produkční SHA-256 otisk a Apple Team ID do [`.well-known/assetlinks.json`](hosting/public/.well-known/assetlinks.json) a [`.well-known/apple-app-site-association`](hosting/public/.well-known/apple-app-site-association).

### Stitch obrazovky & Firebase Test Cases
- Návrhové specifikace a prompty pro Stitch MCP jsou v [`docs/stitch_gangs_screens.md`](docs/stitch_gangs_screens.md).
- Scénáře pro **Firebase App Distribution → Test Cases** (správa Gangů, pozvánky, skloňování podle pohlaví a nebezpečné smazání Gangu) jsou v [`docs/firebase_test_cases.md`](docs/firebase_test_cases.md).

