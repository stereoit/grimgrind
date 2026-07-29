# GrimGrind Art Bible

This document is the source of truth for generated artwork, UI illustrations, card art, store screenshots, and marketing materials. Every generated image should reuse the same visual grammar so the game feels like one illustrated deck rather than a collection of unrelated assets.

## Creative North Star

**A mischievous gothic household game illustrated like a forbidden Victorian card deck found in a teenager's room.** The mood is dark and mysterious, but never gory, photorealistic, or genuinely frightening. It should feel collectible, witty, tactile, and slightly rebellious.

Reference qualities, not copyrighted characters: Victorian occult engravings, 1890s mansion architecture, screen-printed gig posters, tarot composition, inked graphic novels, aged playing cards, moonlit botanical studies, and dry macabre humor.

## Fixed Visual DNA

- **Medium:** hand-inked engraving with visible cross-hatching, limited screen-print color, subtle paper grain.
- **Composition:** centered heraldic subject, strong silhouette, symmetrical framing with one intentional asymmetry.
- **Perspective:** mostly orthographic or shallow three-quarter view. Avoid wide-angle and cinematic depth of field.
- **Linework:** ivory or desaturated gold key lines on near-black. Medium-weight outer contour, fine interior hatching.
- **Lighting:** impossible moonlight from upper-left, narrow burgundy rim light, no glossy 3D highlights.
- **Texture:** 8-12% paper grain, sparse dust, occasional ink misregistration under 2 px. Never grunge over text.
- **Human presence:** hands, shadows, silhouettes, or cropped figures only. The house and objects are characters.
- **Humor:** one small visual joke per image, such as an offended dust bunny or aristocratic trash bag.

## Palette

Use no more than five colors in a single asset.

| Token | Hex | Usage |
| --- | --- | --- |
| Void | `#0B0B0D` | Background and deepest shadow |
| Coal | `#17171A` | Raised surfaces and secondary black |
| Bone | `#E9E0D0` | Primary linework and text |
| Tarnished gold | `#C6A15B` | Rewards, focus, sacred objects |
| Blood wine | `#6E1830` | Actions, danger, dramatic rim light |
| Moss | `#66816A` | Easy cards |
| Bruise | `#846BA3` | Special cards |

No neon gradients, rainbow lighting, pure white, pure red, cyan tech glow, or generic purple-blue gaming palettes.

## Card Illustration System

All card art uses a vertical 4:5 canvas with these zones:

1. Top 12%: suit and difficulty mark.
2. Middle 58%: one oversized household object as a heraldic emblem.
3. Bottom 22%: empty dark value field for title, time, and reward overlays.
4. Outer 4%: double-line engraved frame with tiny thorns at corners.

Difficulty changes density, not the base style:

- **Easy:** open negative space, moss accent, one object, sparse hatch.
- **Medium:** gold accent, two supporting objects, denser shadow.
- **Hard:** blood-wine accent, dramatic diagonal, architectural background.
- **Special:** bruise and gold accents, radial occult geometry, tiny stars, maximum detail.

Recurring suit language:

- Clubs: routine and maintenance, rounded leaves and simple knots.
- Diamonds: care and consistency, angular crystal and water motifs.
- Hearts: effort and craft, thorned heart and flame motifs.
- Stars: rare feats, moon phases and seven-point stars.

## The Hand

The Hand is GrimGrind's only recurring character. It is a disembodied, elegant right hand in a fitted black Victorian glove with a narrow bone-white cuff and one tarnished-gold signet ring. Long expressive fingers, graphic silhouette, no wounds or body horror. It enters from the right edge and interacts with receipts, coins, cards, and ink stamps.

For accounting scenes, the Hand hovers over a dark ledger while gold numbers and card silhouettes form a clean infographic around it. Its pose should be precise and slightly judgmental, never aggressive.

## Icon And Logo

The app icon is a bone-white gloved hand holding a gold seven-point star inside a blood-wine circular seal on Void black. Thick silhouette, no text, recognizable at 16 px. The wordmark `GRIMGRIND` is uppercase, narrow high-contrast serif, tracked widely. Do not place the full wordmark inside the app icon.

## Typography In Artwork

- Headlines: narrow, high-contrast editorial serif in uppercase.
- Labels and numbers: compact grotesk sans in uppercase with wide tracking.
- Never ask an image model to generate final text. Reserve empty areas and typeset in the app or design tool.
- Maximum two type families and three weights per composition.

## Motion

- Cards enter with a 2-degree rotation and settle flat in 220 ms.
- The Hand counts with three deliberate finger taps, 180 ms apart.
- Gold accents may shimmer once; nothing loops continuously.
- Transitions resemble cards sliding across felt, not generic fades or bounces.

## Generation Prompt Template

Use this exact foundation, replacing only the bracketed subject:

> Vertical 4:5 collectible task card illustration of [SUBJECT], mischievous gothic household game, Victorian copperplate engraving, hand-inked cross-hatching, centered heraldic object, near-black paper, bone-white linework, tarnished-gold and [DIFFICULTY COLOR] screen-print accents, shallow perspective, symmetrical double-line tarot frame with tiny thorn corners, moonlight from upper-left, subtle paper grain, one tiny dark-humor detail, generous empty dark title area at bottom, five-color maximum, crisp graphic silhouette, no text, no logo, no people, no gore, no photorealism, no 3D render, no neon, no gradient, no copyrighted characters.

## Negative Prompt

> photorealistic, glossy 3D, Pixar, anime, kawaii, cyberpunk, neon, blue-purple gradient, lens flare, cinematic depth of field, gore, blood splatter, zombie, horror face, full human figure, illegible lettering, generated text, watermark, busy background, thin low-contrast silhouette, generic mobile game UI

## Consistency Checklist

- Canvas and safe zones match the card template.
- Subject reads at thumbnail size.
- Palette contains Void, Bone, and no more than three accents.
- Engraved linework and paper grain are visible.
- Light comes from upper-left.
- Exactly one humorous micro-detail appears.
- Bottom title area remains clear.
- No generated text or logos are baked into card art.
- The result still belongs beside every previously approved card.
