# Stitch Screen Specifications: Gangs / Teams Feature

These screen specifications and prompts are prepared for **Stitch MCP** (Option 4 hybrid workflow) so you can generate or refine high-fidelity screens on your workstation and keep them 100% aligned with [`DESIGN.md`](../DESIGN.md).

## Shared Design System Tokens
- **Canvas**: Mobile `390 × 844` (dark mode only)
- **Void (Background)**: `#0B0B0D`
- **Coal (Cards / Dialogs)**: `#17171A` with `1px` border `#3B3329`
- **Bone (Primary Text / Linework)**: `#E9E0D0`
- **Tarnished Gold (Focus / Active / Invite Code)**: `#C6A15B`
- **Blood Wine (Primary CTA / Danger Actions)**: `#6E1830` with `#9B3B48` border
- **Typography**: Narrow high-contrast editorial serif for titles/headers (`GRIMGRIND`, screen titles); compact uppercase grotesk sans with wide letter-spacing for micro-labels (`SPRÁVA SÍDEL`, `NEBEZPEČNÁ ZÓNA`).

---

## Screen 1: My Gangs (`Moje Gangy`)
**Flutter target**: [`MyGangsPage`](../lib/gangs_screens.dart)

**Stitch Prompt**:
> Mobile app screen in dark Victorian gothic card-game style (`#0B0B0D` background, `#17171A` cards, `#C6A15B` tarnished gold accents, `#E9E0D0` bone-white serif typography). Top AppBar titled "Moje Gangy". Eyebrow label "SPRÁVA SÍDEL" in gold uppercase. Two side-by-side action buttons: primary "Založit Gang" and outlined "Přijmout kód". Below, a vertical list of Gang cards: active Gang card has a `#C6A15B` 1.5px border, a small `#6E1830` "AKTIVNÍ" badge, role ("Ruka (Vlastník)" or "Člen"), member nickname, member count, invite code `GRIM-42`, and a "Spravovat" button on the right. No "Leave Gang" button.

---

## Screen 2: Create / Setup Gang (`Založit nový Gang`)
**Flutter target**: [`showCreateGangDialog`](../lib/gangs_screens.dart) & [`_GangSetupScreen`](../lib/main.dart)

**Stitch Prompt**:
> Dark Victorian gothic modal/screen (`#17171A` surface on `#0B0B0D` backdrop, `#3B3329` borders, `#C6A15B` gold accents). Title "Založit nový Gang" in bone-white serif. Form fields with subtle borders: "Název Gangu / Sídla", "Tvoje přezdívka (Ruka)", a 3-option segmented selector for grammatical sex labeled "Pohlaví (pro správné skloňování v kronice)" with options "Muž", "Žena", "Neutrální", and numeric field "Kurz: kolik Coinů = 1 Kč". Bottom actions: "Zrušit" text button and primary "Založit" button with a castle icon.

---

## Screen 3: Manage Gang, Share Invite & Dangerous Delete
**Flutter target**: [`ManageGangPage`](../lib/gangs_screens.dart)

**Stitch Prompt**:
> Dark Victorian gothic mobile screen (`#0B0B0D` background). Top section is a `#17171A` card with eyebrow "POZVÁNKA PRO PŘÁTELE (IM ODKAZ)" in `#C6A15B` gold, large spaced monospace invite code `GRIM-42`, subtle URL `https://grim-grind.web.app/join?code=GRIM-42`, primary button "Zkopírovat zvací odkaz do zpráv", and outlined button "Obnovit zvací kód". Bottom section is a Danger Zone card with `#6E1830` blood-wine border, eyebrow "NEBEZPEČNÁ ZÓNA", warning text, and a solid `#6E1830` button "Smazat Gang". Overlay/second state shows a confirmation dialog "Opravdu smazat Gang?" requiring the owner to type the exact Gang name into a text field before enabling the blood-wine "Trvale smazat" button.

---

## Screen 4: Accept Invitation (`Přijmout pozvánku`)
**Flutter target**: [`showAcceptInviteDialog`](../lib/gangs_screens.dart) & [`hosting/public/join.html`](../hosting/public/join.html)

**Stitch Prompt**:
> Dark Victorian gothic modal dialog (`#17171A` surface, `#C6A15B` gold highlight box). Title "Přijmout pozvánku do Gangu". Highlighted box at top showing "Pozvánka do: Sídlo Addamsů" in gold on `#0B0B0D`. Input field "Zvací kód nebo odkaz" prefilled with `GRIM-42`, input field "Tvoje přezdívka v tomto Gangu", and 3-option segmented selector "Muž / Žena / Neutrální" for grammatical gender. Bottom actions: "Zrušit" and primary "Připojit se".
