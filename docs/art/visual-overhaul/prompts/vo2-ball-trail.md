# VO2 Ball Trail Prompt Packet

Inherits from `vo2-shared-style-rules.md`.

## Purpose

Guide ball, trail, contact, bounce, and point VFX tuning for VO2-5 while preserving the existing eight-effect runtime set.

## Target Output

- Optional VFX reference sheet or replacement sprites with transparent background.
- Suggested sheet: 4 columns by 2 rows matching the existing eight effects:
  - dinkSpark
  - driveArc
  - lobArc
  - smashBand
  - missWhiff
  - bounceRing
  - trailSegment
  - pointBurst
- Individual VFX should fit in compact square cells with generous padding.
- Ball visual target: 12-16 px readable core on a 1920-tall Pixel gameplay capture.

## Palette Pulls

Ball: `ballPrimary` #FFE24A, `ballHighlight` family #F8FFE8, `ballAccentRim` #FFD84C.

Trail and contact: `uiAccent` #FFCB47, `feedbackDink` #77E6C6, `feedbackDrive` #FFCB47, `feedbackLob` #8FC7FF, `feedbackSmash` #FF6A3D, `feedbackFault` #FF5A72.

Shadow: `projectedShadow` #061211 and `courtApronNavy` #163B57.

## Generation Prompt

Create a compact hard-edge pixel-art pickleball VFX reference sheet on a transparent or flat chroma-key background. Include eight separated effects: small dink sparkle, horizontal drive slash arc, upward lob scoop arc, vertical overhead smash impact band, miss whiff arc, bounce ring oval, fast ball trail segment, and point burst star. Use crisp pixel edges, no blur, no smoke, no labels, and the locked v2 palette. VFX should be bright and readable but short-lived, sized to support a ball with a 12-16 px visible core on a tall phone screen.

## Trail Rules

- Trail segment should taper and fade, not look like a solid rope.
- Lob arc can be taller and softer than drive but still hard-edged.
- Drive arc should read flatter and faster than lob.
- Smash band should be vertical/diagonal and brief, not a full-screen explosion.
- Bounce ring must stay below the ball and not hide court lines.

## Reject If

Reject if it violates `vo2-shared-style-rules.md`, creates smoke clouds, glow fog, magic spell effects, soft airbrush trails, effects larger than the player torso, or VFX that obscure the ball/paddle relationship.
