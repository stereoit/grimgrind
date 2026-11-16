# Specifikace aplikace: GrimGrind (v2.0)

Mobilní aplikace pro správu domácích prací s herní ekonomikou **Coinů**, atmosférou temného viktoriánského sídla (*Resident Evil* / *Addams Family*) a karetní gamifikací inspirovanou knihou kouzel (*Heroes of Might and Magic: Olden Era*) a arkádovým stupňováním (*Unreal Tournament*).

Aplikace motivuje členy domácnosti („Gang“) k plnění povinností skrze vykládání karet z otevřeného Decku do společného instagramového Feedu, sbírání karet v Banku, směnu Coinů u Ruky a soutěžení v měsíčních Leaderboardech.

---

## 🏰 1. Onboarding, Gang (Sídlo) a Role

Dobrodružství začíná při prvním spuštění aplikace:

1. **Intro kartičky (Tutorial):**
   - Krátká série uvítacích karet vysvětlující princip hry:
     1. *Otevři Knihu (Deck) a zahraj kartu splněného úkolu.*
     2. *Sbírej Coiny do svého Banku a drž si vysoký Level i žhnoucí Heat.*
     3. *Požádej Ruku o směnu Banku na reálné peníze a ovládni měsíční Leaderboard.*
2. **Založení, správa a připojení do Gangu (Rodiny / Sídla):**
   - **Zakladatel = Ruka (Správce sídla):** Každý přihlášený uživatel může založit vlastní Gang/Sídlo, zvolit mu název, svou přezdívku a **pohlaví** (*Muž / Žena / Neutrální* pro správné skloňování v kronice) a získá krátký **zvací kód** (např. `GRIM-42`) i sdílený **IM odkaz** (`https://grim-grind.web.app/join?code=GRIM-42`).
   - **Sdílení pozvánky a instalace aplikace:** Otevření zvacího odkazu v mobilu přesměruje uživatele přímo do aplikace na obrazovku přijetí pozvánky (App Links / Universal Links), nebo při chybějící aplikaci zobrazí webovou stránku s instalací (APK / Firebase App Distribution) a zvacím kódem.
   - **Přijetí pozvánky:** Při přijetí pozvánky si nový člen zvolí vlastní **nickname** a **pohlaví** (*Muž / Žena / Neutrální*).
   - **Více Gangů & Správa („Moje Gangy“):** Většina hráčů je v jednom rodinném Gangu, ale uživatel může být členem více Gangů najednou, přepínat mezi nimi v sekci **Moje Gangy**, obnovovat zvací kód (jako vlastník) a jako vlastník Gang smazat (vyžaduje nebezpečné potvrzení zadáním přesného názvu Gangu). Opuštění Gangu členem momentálně není podporováno.
   - **Pravomoci Ruky:** Zakladatel má roli **Ruky** – nastavuje směnný kurz (`Coin → Kč`) a schvaluje žádosti o směnu Banku ostatním členům. Zároveň může sám běžně hrát karty a účastnit se Leaderboardů.

---

## 🃏 2. Hlavní Herní Smyčka (Core Loop v2.0)

```text
1. Otevření Decku (Knihy) ➡️ 2. Zahrání karty do Feedu a Banku ➡️ 3. Žádost o směnu Banku ➡️ 4. Ruka schválí směnu ➡️ 5. Zápis do Feedu & Leaderboardu
```

1. **Otevření Decku (Knihy kouzel):**
   - Všichni hráči vidí stejný sdílený **Deck** všech 17 karet úkolů (princip knihy kouzel z *HoMM: Olden Era*).
   - Neexistuje stav „rozehraná karta“ ani žádné denní/týdenní limity či cooldowny.
   - Přímo na kartách v Decku vidí hráč hodnotu v **Coinech** již dynamicky navýšenou o svůj aktuální **Měsíční Level** a **Heat (Streak)**.
2. **Zahrání karty:**
   - Hráč vybere kartu úkolu, který splnil, a potvrdí **„Zahrát kartu“**.
   - Karta se okamžitě objeví v **Hlavním Feedu (Kronice)**, všem členům Gangu odejde push notifikace a karta s příslušným počtem Coinů se uloží do hráčova **Banku** (nevyúčtované zahrané karty).
3. **Žádost o směnu Banku:**
   - Kdykoliv má hráč v Banku alespoň jednu zahranou kartu, může v sekci **Bank** vidět celkovou hodnotu svých zahraných karet (v Coinech i orientačním přepočtu na Kč) a kliknout na **„Požádat Ruku o směnu“**.
   - **Automatická žádost na konci měsíce:** Na konci měsíce se ze všech zbývajících karet v Banku automaticky vygenerují žádosti o směnu, aby se uzavřelo dané období.
4. **Schválení směny Rukou (Rodičem):**
   - Zakladatel (Ruka) vidí čekající žádosti o směnu, zkontroluje zahrané karty (případně může neuznanou kartu vyřadit) a směnu v aplikaci **potvrdí** (reálnou finanční odměnu vyplatí offline / přes Revolut podle nastaveného kurzu).
5. **Zápis do Feedu a Leaderboardů:**
   - Schválená směna se zobrazí jako slavnostní událost v **Hlavním Feedu**.
   - **Ochrana proti podvádění:** Teprve karty a Coiny z **potvrzených směn** se započítávají do **Leaderboardů**!

---

## 📱 3. Obrazovky a Navigace Aplikace

### A) Hlavní Feed (Kronika / Stream)
- **Instagramový vertikální stream** všech zahraných karet a schválených směn v sídle.
- Hráč může plynule scrollovat dolů celou historií sídla (není omezeno na pevný počet $N$ karet).
- **Vizuální předěly období (měsíců):** Jednotlivé měsíce jsou ve feedu vizuálně odděleny horizontálním předělem / **speciální kartou Měsíčního vyhlášení**, která shrnuje vítěze a statistiky uzavřeného měsíce.

### B) Akce „Zahrát kartu“ (Pohled na Deck)
- Otevře **Deck (Knihu karet)** se všemi 17 kartami rozdělenými podle obtížnosti.
- Zobrazuje karty s přepočtenou odměnou v Coinech podle hráčova aktuálního Levelu a Heatu; klepnutím hráč kartu zahraje.

### C) Moje zahrané karty (Bank & Směna)
- Přehled hráčových aktuálně zahraných karet, které zatím nebyly směněny.
- Ukazuje součet Coinů v Banku, aktuální směnný kurz a přepočet na Kč.
- Tlačítko **„Požádat o směnu“** (a pro Zakladatele/Ruku také panel pro **schvalování čekajících směn** a **nastavení kurzu Coin → Kč**).

### D) Leaderboardy (🏆 Karty Hráčů)
- Leaderboard je zobrazen jako **sběratelské karty jednotlivých hráčů** Gangu.
- **Vizualizace Heatu:** Kolem karty každého hráče září **aura** odpovídající jeho aktuálnímu stupni Heatu (*Vychladlý popel* až *Pekelný žár*).
- **Obsah karty hráče:** Jméno (nickname), titul Měsíčního Levelu, stupeň Heatu/Streaku, počet schválených úkolů, počet schválených Coinů a odpracovaný čas.
- **Řazení karet hráčů (Sorting):**
  1. **Most Active** *(výchozí)* – podle počtu schválených karet/úkolů.
  2. **Most Hard Working** – podle objemu schválených Coinů / náročnosti.
  3. **By Streak Level** – podle aktuálního Heatu a délky Streaku.
- **Přepínač období (Síň slávy):** Možnost přepnout žebříček mezi *Aktuálním měsícem*, *Minulými měsíci* a *Celkovou historií*.

---

## 🔥 4. Ekonomika Coinů, Měsíční Levely a Chladnoucí Heat

### Měna a Směnný Kurz
- Hodnota Coinů je oddělená od reálných peněz a záměrně vyšší, aby působila herně (základní karty mají hodnotu **100 až 1 000 Coinů**).
- Směnný kurz nastavuje Zakladatel (Ruka), výchozí hodnota je **10 Coinů = 1 Kč** (tj. `100 Coinů = 10 Kč`).

### 1. Měsíční Level Hráče (Objem aktivity – neklesá, reset 1. den v měsíci)
Inspirováno hláškami z *Unreal Tournament*, zasazeno do gotického sídla. Jakmile hráč v daném měsíci zahraje příslušný počet karet, dosáhne daného Levelu a drží si ho až do konce měsíce:

| Stupeň | Gotický titul (*UT inspirace*) | Počet karet v měsíci | Bonus k hodnotě karet |
| :--- | :--- | :--- | :--- |
| **1.** | 🕯️ **Probuzený** *(Bronze / Základ)* | 0–4 karty | **+0 %** (`1.0×`) |
| **2.** | 🦇 **Nepokojný duch** *(Killing Spree)* | 5–11 karet | **+10 %** (`1.1×`) |
| **3.** | 🩸 **Krvežíznivý** *(Rampage)* | 12–21 karet | **+20 %** (`1.2×`) |
| **4.** | ⚡ **Nezastavitelný** *(Unstoppable)* | 22–34 karet | **+30 %** (`1.3×`) |
| **5.** | 👑 **Nesmrtelný** *(Godlike)* | 35+ karet | **+50 %** (`1.5×`) |

### 2. Streak / Heat (Pravidelnost – chladne při neaktivitě)
Vedlejší mechanismus podporující konzistenci (pravidelné hraní). Má 4 stavy (základ + 3 stupně žáru), určuje **auru kolem karty hráče** v Leaderboardu a přidává další bonus k hodnotě karet:

| Stupeň | Název Heatu | Podmínka dosažení a udržení | Bonus k hodnotě karet |
| :--- | :--- | :--- | :--- |
| **0.** | 🌑 **Vychladlý popel** | Výchozí stav nebo po vychladnutí | **+0 %** |
| **1.** | 🔥 **Žhnoucí uhlíky** | Alespoň 2 aktivní dny; **udržení:** hrát aspoň 1× za **3 dny** | **+10 %** |
| **2.** | ☄️ **Rozpálená výheň** | Alespoň 4 aktivní dny; **udržení:** hrát aspoň 1× za **3 dny** | **+20 %** |
| **3.** | 🌋 **Pekelný žár** *(On Fire!)* | Alespoň 7 aktivních dní; **udržení:** hrát **každý den** (jinak pád o stupeň níž) | **+30 %** |

### Výpočet hodnoty karty v Decku
Bonusy z Měsíčního Levelu a Heatu se sčítají:
$$\text{Výsledné Coiny} = \text{round}\big(\text{Základní Coiny} \times (1 + \text{Bonus}_{\text{Level}} + \text{Bonus}_{\text{Heat}})\big)$$
*(Např. karta se základem `200 Coinů` při Levelu Nezastavitelný `+30 %` a Heatu Rozpálená výheň `+20 %` má přímo v Decku hodnotu `300 Coinů`).*

---

## 📋 5. Katalog Karet v Decku (17 karet, bez limitů a cooldownů)

### 🟢 Lehké úkoly (Pohoda ♣) – Základ 100 až 200 Coinů
- **Vynést koš** – `100 Coinů` *(5 min)*
- **Vyklidit nákup** – `150 Coinů` *(10 min)*
- **Vyklidit myčku** – `150 Coinů` *(10 min)*
- **Uklidit si prádlo** – `200 Coinů` *(15 min)*
- **Vysát schodiště** – `200 Coinů` *(15 min)*

### 🟡 Střední úkoly (Horší ◆) – Základ 300 až 450 Coinů
- **Vyčesat Queenie** – `300 Coinů` *(20 min)*
- **Zalít zahradu** – `300 Coinů` *(20 min)*
- **Příprava krmení pro psy** – `350 Coinů` *(20 min – včetně nakrmení)*
- **Sportovní aktivita** – `350 Coinů` *(30 min)*
- **Umýt toaletu** – `400 Coinů` *(20 min)*
- **Večerní úklid** – `450 Coinů` *(35 min – kuchyň, předsíň a obývák)*

### 🔴 Těžké úkoly (Těžké ♥) – Základ 500 až 700 Coinů
- **Vytřít parním mopem** – `500 Coinů` *(35 min)*
- **Umýt koupelnu** – `600 Coinů` *(40 min – za jednu koupelnu)*
- **Učení / Škola** – `600 Coinů` *(45 min)*
- **Vyžehlit** – `700 Coinů` *(45 min)*
- **Uvařit jídlo** – `700 Coinů` *(60 min)*

### 🟣 Speciální karty (Speciální ★) – Základ 1 000 Coinů
- **Vygruntovat pokojíček** – `1 000 Coinů` *(90 min – hloubkový úklid)*

---

## 🛠️ 6. Technologický Stack & Bezpečnost

- **Frontend**: **Flutter** (iOS & Android).
- **Backend & Databáze**: **Firebase Auth**, **Cloud Firestore**, **Firebase Cloud Messaging (FCM)**.
- **Kolekce ve Firestore**:
  - `gangs` (sídla/rodiny, zvací kód, UID zakladatele/Ruky, směnný kurz `coinsPerCzk`).
  - `users` (členové gangu, nickname, statistikové agregace, FCM token).
  - `played_cards` (zahrané karty v Banku čekající na směnu nebo již směněné).
  - `exchanges` (žádosti o směnu Banku a schválené výplaty od Ruky).
  - `feed` (stream událostí sídla: zahrané karty, schválené směny a karty měsíčního vyhlášení).
