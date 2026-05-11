# Phase 5.1 Delta Inventory

Last updated: 2026-05-11

## Reference Set

- Concept target: `docs/art/concept-screenshot.png`
- Baseline gameplay screenshot: `docs/art/phase-5.1-screenshot.png`
- Earlier serve-state screenshot: `docs/art/phase-5-current-serve.png`

## High-Priority Deltas

1. **Player black artifacts**
   - Baseline shows dark paddle/shadow blobs reading as accidental black marks around both player models.
   - Fix target: no high-priority racket-head shadows; paddle silhouettes stay intentional, rimmed, and separated from the body.

2. **Character model consistency**
   - Baseline player/opponent read as narrow stick figures and prior serve/rally states could appear like different models.
   - Fix target: player and opponent use wider chunky silhouettes, stable cap/body/feet baselines, and consistent transparent sprite sheets across idle/run/swing/special sheets.

3. **Stretched fence and trees**
   - Baseline fence/tree dressing reads horizontally stretched and sparse compared with the concept's dense courtside park.
   - Fix target: raster props preserve source aspect ratio, fence has procedural posts/mesh, and background trees fill the top court edge without stretching.

4. **Floating court**
   - Baseline court appears as a flat slab on top of the environment.
   - Fix target: court has a wider apron, feathered grass transition, contact shadow, and edge shade so it sits inside the park surface.

5. **Environment too basic**
   - Baseline has limited side/back detail and large plain green areas.
   - Fix target: layered tree line, hedge/fence band, side foliage, benches/bags/lamp/signs, and quieter control-area ground.

6. **Court/net polish**
   - Baseline court is readable but plain, and the net can feel heavy against the court.
   - Fix target: retain strong court-line readability while adding subtle edge shading, scuffs, kitchen contrast, and coherent shadows.

7. **HUD/control proportions**
   - Baseline serve/swing/move controls dominate the bottom more than the concept.
   - Fix target: preserve touch hit regions but draw smaller, calmer visual rings and slightly tighter score panels.

## Acceptance Screenshot Set

- `phase-5.1-final-serve.png`: waiting-to-serve state with serve button and both players visible.
- `phase-5.1-final-rally.png`: rally state with ball, net, both players, and normal controls.
- `phase-5.1-final-pause.png`: pause overlay checked for visual regressions.
- `phase-5.1-final-comparison.md`: concept / baseline / final notes and residual follow-ups.

## Scope Guardrails

- Do not change scoring, match rules, serve mechanics, ball physics, AI, ads, monetization, or progression.
- Do not add shot buttons.
- Preserve the movement stick + swing stick + automatic racket contact contract.
- Avoid `CourtProjection` changes. `CourtLayoutSystem` framing changes require screenshot evidence.
