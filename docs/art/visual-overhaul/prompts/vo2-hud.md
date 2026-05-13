# VO2 HUD Prompt Packet

Inherits from `vo2-shared-style-rules.md`.

## Purpose

Define the visual target for code-rendered or generated-reference HUD plaques: score block, feedback plaque, rally strip, pause button, serve button, and out-of-match plaque chrome.

## Target Output

These assets may be generated as visual reference sheets, then implemented with Flutter/Flame drawing where required.

- Score block reference: two panels, `YOU 05` and `RIVAL 03`, total width 26-30% of screen.
- Feedback plaque reference: top-center, two lines, about 30-34% of screen width and 5-6% of screen height.
- Rally strip reference: text-only, two lines, no border.
- Pause plaque reference: top-right square, same border language.
- Serve button reference: compact bottom-center arcade button, >=48 dp touch target.
- Menu/end-match plaque chrome: same border, inner highlight, and shadow language.

## Palette Pulls

Score player panel: `scoreboardPlayer` visual family #1C5FA8, `playerPrimary` #3C86FF.

Score opponent panel: `scoreboardOpponent` visual family #A83E3E, `opponentPrimary` #FF5F5F.

Text and border: `courtLineWhite` #F4F7E8.

Feedback plaque fill: `feedbackBanner` visual family #F1E8C8, with `feedbackBannerBorder` #533F28 and `feedbackBannerText` #0D2030.

Accents: `uiAccent` #FFCB47, `feedbackDink` #77E6C6, `feedbackDrive` #FFCB47, `feedbackLob` #8FC7FF, `feedbackSmash` #FF6A3D, `feedbackFault` #FF5A72.

## Generation Prompt

Create a hard-edge pixel-art arcade sports HUD reference sheet for a mobile pickleball game. Include a two-panel score block reading `YOU 05` and `RIVAL 03`, a cream top-center feedback plaque reading `DINK!` over `NICE SHOT`, a simple text rally strip reading `RALLY: 6` and `LAST SHOT: DINK`, a square pause plaque, and a compact serve button. Use chunky rectangular plaques with 3 px dark outer border, 2 px light inner highlight, subtle lower-right drop shadow, blocky readable lettering, and the locked v2 palette. Keep the design compact and phone-readable.

## Implementation Notes

- Runtime HUD may be code-painted. The generated sheet is an art-direction reference, not a mandatory sprite atlas.
- Text must fit inside the plaque at all phone widths.
- Preserve Android safe areas.
- Do not add new shot buttons; dink/drive/lob/smash remain automatic contact classifications.

## Reject If

Reject if it violates `vo2-shared-style-rules.md`, uses malformed text, creates ornate UI that cannot be code-rendered simply, uses thin borders, hides gameplay, breaks safe-area assumptions, or suggests new controls outside the existing movement/swing/serve contract.
