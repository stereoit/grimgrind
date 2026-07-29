# Specifikace aplikace: GrimGrind (v1.1)

Mobilní aplikace pro správu domácích prací s finančním ohodnocením, atmosférou temného sídla ("Resident Evil" / "Addams Family") a karetní gamifikací. Aplikace motivuje členy domácnosti k plnění povinností skrze karty úkolů, sbírání osobního balíčku karet, notifikace a časovou osu událostí v domě.

---

## 🎭 Postavy, Nicknamy a Role v Sídle

Místo běžných názvů rolí používá aplikace temně hravé postavy sídla:

1. **Uživatelské Přezdívky (Nicknamy)**
   - Každý uživatel si může zvolit svůj temný **nickname** (např. *Dark Lord*, *Shadow Master*, *Královna sídla*).
   - Zvolený nickname se zobrazuje **napříč celou aplikací** – v notifikacích, na kartách i v Kronice sídla (např. *„Dark Lord právě označil úkol 'Vyčesat Queenie' za vyřešený! 🐶“*).

2. **Ruka (Thing / Tajuplná ruka)** *(správce pokladny a výplat)*
   - Ruka má na starosti finální schvalování a vyplácení odměn.
   - Na konci měsíce se hráči obrací na Ruku, která jim **podepíše šek** a vyplatí peníze (přes Revolut).

---

## 🛠️ Technologický Stack & Google Cloud Infrastruktura

- **Frontend / Mobilní aplikace**: **Flutter** (Dart) pro iOS a Android.
- **Backend & Databáze**: **Firebase**
  - **Firebase Auth**: Přihlašování uživatelů a správa profilů/nicknamů.
  - **Cloud Firestore**: Real-time databáze pro stav sídla, karet a kroniky.
  - **Firebase Cloud Messaging (FCM)**: Push notifikace o dokončení úkolů v reálném čase s nicknamem hráče.
  - **Firebase App Distribution**: Distribuce mobilní aplikace přes **veřejný odkaz (Public Link)** pro cca 4 členy na iOS i Android.
- **Cloud Služby**: **Google Cloud Run**
  - Serverless mikroslužba pro generování měsíčních výkazů, výpočty úrovní a generování šeků/Revolut linků od Ruky.

---

## 🃏 Zjednodušená Herní Smyčka (Core Loop v1.0)

```
1. Vzetí karty ➡️ 2. Splnění úkolu ➡️ 3. Žádost o zúčtování ➡️ 4. Ruka přepočítá odměnu ➡️ 5. Výplata
```

1. **Výběr úkolu (Hráč)**: Hráč si vybere kartu úkolu a jedním potvrzením si ji rovnou vezme do aktivního balíčku.
2. **Plnění & Označení**: Hráč úkol vykoná a v aplikaci ho označí za hotový.
4. **Notifikace všem & Kronika sídla**:
   - Všem ostatním hráčům dorazí push notifikace s nicknamem (*„Dark Lord právě dokončil úkol 'Vyčesat Queenie'! 🐶“*).
   - Událost se zaznamená do živé **Časové osy / Kroniky sídla**.
5. **Žádost o zúčtování**: Hráč pošle všechny hotové karty Ruce. Ruka zobrazí počet karet, základ odměny, level multiplikátor a výslednou částku.
6. **Přidání do Osobního Balíčku**: Po zúčtování se karty přemístí do **Osobního balíčku karet** daného hráče.
7. **Měsíční Vyhodnocení & Ruka**: Na konci měsíce **Ruka podepíše šek** a vyplatí zisk přes Revolut.

---

## 📋 Katalog Úkolů (Kompletní přehled)

### 🟢 Lehké úkoly (Pohoda) – Odměna ~ 5 až 20 Kč
- **Vynést koš** (10 Kč)
- **Vyklidit nákup** (15 Kč)
- **Vyklidit myčku** (15 Kč)
- **Uklidit si prádlo** (20 Kč)
- **Vysát schodiště** (20 Kč)

### 🟡 Střední úkoly (Horší) – Odměna ~ 25 až 45 Kč
- **Vyčesat Queenie** (30 Kč)
- **Umýt toaletu** (40 Kč)
- **Příprava krmení pro psy** (35 Kč – obsahuje i nakrmení)
- **Sportovní aktivita** (35 Kč)
- **Zalít zahradu** (30 Kč – možnost plnit denně)
- **Večerní úklid** (45 Kč – kuchyň, předsíň, obývák)

### 🔴 Těžké úkoly & Speciální karty – Odměna ~ 50 až 100 Kč
- **Umýt koupelnu** (60 Kč / koupelna – 2 samostatné koupelny)
- **Vytřít podlahu parním mopem** (50 Kč)
- **Vyžehlit** (70 Kč)
- **Uvařit jídlo** (70 Kč)
- **Učení / Škola** (60 Kč)
- ✨ **Speciální karta: Vygruntovat pokojíček** (100 Kč – dostupná **1x týdně** pro hloubkový úklid)

---

## 📜 Kronika Sídla (Časová osa & Historie domu)

- Chronologický výpis událostí v reálném čase poháněný **Firebase Firestore Subscriptions** se zobrazením přezdívek hráčů.

---

## 🎨 Grafický Styl a UI Metafora (Resident Evil / Addams Family)

- **Vzhled a atmosféra**: Temný "Dark Art" styl sídla.
- **Postava**: **Ruka** přepočítává hotové karty, podepisuje šeky a spravuje peníze.
- **UI Metafora - Hrací karty**: Úkoly jako sběratelské karty.
- **Vizuální systém**: Detailní pravidla, paleta a prompty jsou v `DESIGN.md`.

---

## 👥 Uživatelé a Distribuce

- **Počet uživatelů**: Cca **4 lidé** (jedna domácnost).
- **Platformy**: **iOS** i **Android** (Flutter).
- **Distribuce**: **Firebase App Distribution** přes veřejný odkaz.

---

## 🎮 Levely, Měsíční Vyhodnocení & Revolut

| Úroveň | Multiplikátor odměny |
| :--- | :--- |
| 🥉 **Bronzový (Bronze)** | **1.0x** |
| 🥈 **Stříbrný (Silver)** | **1.1x** |
| 🥇 **Zlatý (Gold)** | **1.2x** |
| 🏆 **Platinový (Platinum)** | **1.3x** |

- **Měsíční Recap (Wrapped)**: Sdílitelné vizuální karty.
- **Výplata od Ruky**: **Ruka podepíše šek** a vygeneruje Revolut odkaz pro převod peněz.
