#!/usr/bin/env bash
set -euo pipefail

mkdir -p assets/cards assets/art

cards=(trash shopping dishwasher laundry stairs queenie toilet dogs sport garden evening bathroom mop ironing cooking school room)
symbols=("skull trash urn" "grocery satchel" "haunted plates" "folded shirt" "spiral staircase" "gothic hound" "porcelain throne" "hound food bowl" "winged dumbbell" "thorn watering can" "candelabra broom" "clawfoot bathtub" "steam mop staff" "antique iron" "witch cauldron" "forbidden book" "haunted bedroom")
colors=("#66816A" "#66816A" "#66816A" "#66816A" "#66816A" "#C6A15B" "#C6A15B" "#C6A15B" "#C6A15B" "#C6A15B" "#C6A15B" "#9B3B48" "#9B3B48" "#9B3B48" "#9B3B48" "#9B3B48" "#846BA3")
motifs=(
  "roundrectangle 255,245 385,430 18,18 line 235,245 405,245 line 282,215 358,215"
  "roundrectangle 220,265 420,440 18,18 bezier 265,285 265,190 375,190 375,285"
  "circle 270,330 270,235 circle 380,350 380,275 line 225,455 430,455"
  "path 'M 250,245 L 190,300 L 235,350 L 270,325 L 270,455 L 370,455 L 370,325 L 405,350 L 450,300 L 390,245 L 350,285 L 290,285 Z'"
  "polyline 205,440 205,390 260,390 260,340 315,340 315,290 370,290 370,240 435,240"
  "circle 320,360 320,300 circle 255,275 255,245 circle 295,235 295,205 circle 345,235 345,205 circle 385,275 385,245"
  "ellipse 320,360 95,75 0,360 line 270,430 250,465 line 370,430 390,465"
  "path 'M 220,360 Q 320,445 420,360 L 390,430 L 250,430 Z' circle 270,300 270,280 circle 320,280 320,260 circle 370,300 370,280"
  "roundrectangle 205,305 270,365 15,15 roundrectangle 370,305 435,365 15,15 line 270,335 370,335 line 190,285 190,385 line 450,285 450,385"
  "roundrectangle 235,315 370,420 15,15 line 370,335 435,290 line 435,290 455,315 bezier 280,310 250,245 330,225 350,290"
  "line 260,220 385,465 line 230,250 290,220 line 215,275 275,245 path 'M 365,420 L 435,385 L 455,430 L 385,465 Z'"
  "path 'M 205,315 Q 320,440 435,315 L 420,420 L 220,420 Z' line 190,290 450,290 line 250,420 235,465 line 390,420 405,465"
  "line 315,205 315,450 line 290,205 340,205 path 'M 270,390 L 360,390 L 405,465 L 225,465 Z'"
  "path 'M 235,420 Q 250,250 365,250 Q 420,320 395,420 Z' line 250,420 420,420 circle 355,315 355,295"
  "path 'M 210,330 Q 320,470 430,330 L 395,445 L 245,445 Z' line 190,310 450,310 line 265,255 245,205 line 320,255 320,190 line 375,255 405,210"
  "path 'M 205,245 Q 270,215 320,270 Q 370,215 435,245 L 435,440 Q 370,410 320,460 Q 270,410 205,440 Z' line 320,270 320,460"
  "roundrectangle 205,285 435,445 15,15 line 205,350 435,350 line 245,285 245,235 line 390,285 390,235 line 190,465 450,465"
)
font="/System/Library/Fonts/Supplemental/Times New Roman Bold.ttf"
italic="/System/Library/Fonts/Supplemental/Times New Roman Bold Italic.ttf"

for i in "${!cards[@]}"; do
  card="${cards[$i]}"
  label="${symbols[$i]}"
  accent="${colors[$i]}"
  magick -size 640x800 radial-gradient:"#30252d-#09090b" \
    -fill none -stroke "$accent" -strokewidth 12 -draw "roundrectangle 26,26 614,774 28,28" \
    -stroke "#E9E0D0" -strokewidth 3 -draw "roundrectangle 43,43 597,757 22,22" \
    -stroke "$accent" -strokewidth 7 -fill "#111114" -draw "circle 320,330 320,118" \
    -stroke "#0B0B0D" -strokewidth 18 -fill none -draw "${motifs[$i]}" \
    -stroke "#E9E0D0" -strokewidth 9 -fill none -draw "${motifs[$i]}" \
    -stroke "$accent" -strokewidth 5 -draw "line 220,505 420,505 line 250,525 390,525" \
    -fill "$accent" -stroke none -gravity south -font "$font" -pointsize 24 -annotate +0+108 "GRIMGRIND • $((i + 1))" \
    "assets/cards/$card.png"
done

magick -size 1400x720 radial-gradient:"#351d2a-#08080a" \
  -fill "#141116" -stroke "#C6A15B" -strokewidth 10 -draw "path 'M 850,680 C 820,500 835,250 970,150 C 1105,190 1180,400 1140,680 Z'" \
  -fill "#E9E0D0" -stroke "#0B0B0D" -strokewidth 8 -draw "circle 974,184 974,100" \
  -fill "#161117" -draw "path 'M 895,180 C 900,65 1060,40 1088,190 C 1030,130 970,120 895,180 Z'" \
  -fill "#6E1830" -stroke "#C6A15B" -strokewidth 7 -draw "path 'M 865,340 C 900,230 1040,220 1080,340 L 1125,680 L 820,680 Z'" \
  -fill "#E9E0D0" -stroke "#0B0B0D" -strokewidth 7 -draw "path 'M 900,345 C 760,380 650,435 550,505 L 590,550 C 720,490 835,455 945,430 Z'" \
  -fill "#C6A15B" -stroke "#0B0B0D" -strokewidth 8 -draw "polygon 330,500 805,500 750,585 380,585" \
  -fill "#17171A" -stroke "#E9E0D0" -strokewidth 5 -draw "polygon 395,475 490,260 610,310 550,500 polygon 550,490 650,255 770,305 705,505" \
  -fill "#E9E0D0" -font "$italic" -pointsize 64 -gravity northwest -annotate +80+95 "VYBER SI" \
  -fill "#C6A15B" -font "$font" -pointsize 88 -annotate +80+165 "SVUJ OSUD" \
  -fill "#968C80" -font "$font" -pointsize 30 -annotate +84+275 "Dama sidla servíruje dnesni karty." \
  "assets/art/card_bearer.png"
