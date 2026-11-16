# Firebase App Distribution Test Cases: Gangs / Teams Management

This document defines automated **Firebase App Distribution Test Cases** (AI-driven mobile QA scenarios in **Firebase Console → App Distribution → Test Cases**) covering the Gangs / Teams lifecycle in **GrimGrind**.

---

## Test Case 1: Create Gang, Share IM Invite Link & Switch Gangs
- **Goal**: Verify that any signed-in user can create a new Gang with Nickname and Sex, inspect the shareable IM invite link, and switch between multiple Gangs.
- **Prerequisites**:
  - App installed on Android/iOS test device and signed in (or past onboarding).
- **Steps**:
  1. From the main Feed screen, tap the top-right **Sídlo & Přepínač člena** icon.
  2. Tap **Moje Gangy**.
  3. Tap **Založit Gang**.
  4. Enter Gang name `Sídlo Havranů`, nickname `Baronka`, select **Žena**, keep rate `10`, and tap **Založit**.
  5. Verify the top AppBar updates to `SÍDLO HAVRANŮ` and shows `Baronka`.
  6. Open **Sídlo & Přepínač člena → Moje Gangy**, verify `Sídlo Havranů` is marked `AKTIVNÍ` with role `Ruka (Vlastník)`.
  7. Tap **Spravovat** on `Sídlo Havranů`.
  8. Verify the invite code (`GRIM-...`) and shareable link (`https://grim-grind.web.app/join?code=...`) are visible, and tap **Zkopírovat zvací odkaz do zpráv**.
  9. Verify the confirmation snackbar `Zvací odkaz zkopírován pro odeslání v chatu.` appears.
  10. Navigate back to **Moje Gangy**, tap the previous Gang in the list, and verify the app switches back to it.

---

## Test Case 2: Accept Invitation via Code/Link with Nickname & Sex (Gendered Feed)
- **Goal**: Verify that an invited user provides Nickname and Sex when accepting an invitation, and that no "Leave Gang" option is exposed.
- **Prerequisites**:
  - At least one Gang exists with a known invite code (e.g. `GRIM-42`).
- **Steps**:
  1. Open **Sídlo & Přepínač člena → Moje Gangy → Přijmout kód**.
  2. Enter the invite code (or full `https://grim-grind.web.app/join?code=...` URL).
  3. Verify the invited Gang name banner appears (`Pozvánka do: ...`).
  4. Enter nickname `Kněžna` and select **Žena**, then tap **Připojit se**.
  5. Play a card from **Deck** (e.g. `Vynést koš`).
  6. Open **Kronika (Feed)** and verify the post uses feminine Czech grammar (`zahrála` / `uložila`).
  7. Open **Moje Gangy → Spravovat** as a non-owner member and verify there is **no** "Leave Gang" button and **no** "Smazat Gang" danger zone.

---

## Test Case 3: Owner Dangerous Gang Deletion (Exact Name Confirmation)
- **Goal**: Verify that only the Gang owner can delete a Gang, and deletion requires typing the exact Gang name.
- **Prerequisites**:
  - Signed in as the owner (`Ruka (Vlastník)`) of `Sídlo Havranů`.
- **Steps**:
  1. Open **Sídlo & Přepínač člena → Moje Gangy → Spravovat** on `Sídlo Havranů`.
  2. Scroll to **NEBEZPEČNÁ ZÓNA** and tap **Smazat Gang**.
  3. Verify the confirmation dialog `Opravdu smazat Gang?` appears.
  4. Type an incorrect name `Špatný název` into the confirmation field and verify **Trvale smazat** remains disabled.
  5. Type the exact Gang name `Sídlo Havranů` and tap **Trvale smazat**.
  6. Verify `Sídlo Havranů` is removed from **Moje Gangy** (and if no other Gangs remain, the user returns to onboarding).
