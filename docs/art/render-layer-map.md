# Render Layer Map and Occlusion Rules

Last updated: 2026-05-11

## Intended Draw Order

1. Far environment backdrop: dark tree band, fence, wall, and rear signage.
2. Off-court ground and low-contrast background texture.
3. Decorative props that are clearly behind or beside the court.
4. Court surface.
5. Court markings, kitchen treatment, scuffs, and court material details.
6. Net cast shadow.
7. Ball shadow and player/opponent/prop shadows. Paddle/racket-head shadows are intentionally omitted so high-priority paddle rendering cannot create black blobs over the player models.
8. Net posts, mesh, and rail at their existing court-y priority.
9. Player, opponent, and paddles with existing y-priority depth sorting.
10. Ball sprite above its shadow.
11. Ball trail, then short-lived contact, bounce, smash, and point VFX.
12. HUD score, pause, rally/last-shot readouts, and top-center feedback banner.
13. Touch controls, serve button, and visual-only power meter.
14. Modal overlays such as pause and fake ads.

## Occlusion Rules

- Decorative props must not cover active court lines, kitchen boundaries, net center, ball, ball shadow, paddles, score, pause, feedback, or controls.
- Raster environment props must preserve their source aspect ratio. Use repeated/procedural fence treatment instead of stretching a single fence image across a wide band.
- Foreground dressing may overlap only off-court margins and only when it does not block control hit regions.
- Bottom control regions should remain visually quiet; do not place saturated foliage, high-frequency tile detail, or prop silhouettes under translucent sticks.
- Top-third dressing must be checked against the far player, scoreboard, pause control, and rally feedback before it is promoted from placeholder to final.
- Net mesh may overlap the ball briefly by depth, but mesh alpha must keep the ball readable.
- VFX may flash over the ball for a few frames but must not hide the ball during sustained motion.
- HUD and controls always win over world rendering.

## Safe-Area Rules

- Game content must respect `MediaQuery.viewPadding` on Android phones with notches or gesture navigation.
- Score and pause controls belong inside the top safe area.
- Movement, swing, and serve controls belong above bottom gesture/nav area.
- Feedback banners sit below the score/pause row and must not collide with scoreboard, pause, far player, rear signage, or tall-phone safe areas.
- Power meters and labels may not extend outside the reduced Flame canvas or alter touch hit regions.

## Asset Folder Conventions

- `assets/images/environment/classic/`: Classic Court environment props and ground.
- `assets/images/environment/shared/`: reusable trees, shadows, signs, and prop fragments.
- `assets/images/vfx/`: short-lived effect sprites and trail segments.
- `assets/images/ui/hud/`: HUD panels, badges, score frames, and in-match UI fragments.
- `assets/images/ui/court_cards/`: non-interactive court card art for future screens.

## Naming Conventions

- Use lowercase snake_case.
- Prefix environment assets by role: `ground_`, `fence_`, `tree_`, `bench_`, `lamp_`, `sign_`, `banner_`, `bag_`, `shadow_`.
- Prefix VFX assets by event: `hit_`, `bounce_`, `trail_`, `smash_`, `point_`.
- Prefix HUD assets by component: `score_`, `pause_`, `feedback_`, `control_`, `serve_`.
