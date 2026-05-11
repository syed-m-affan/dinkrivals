# Ticket Status

Last updated: 2026-05-11

## Current Assessment

Phase 0 is implemented and has been iterated through ten tuning/control passes plus a 2026-05-10 playtest follow-up (P0-003 movement pointer reset, P0-004 serve mechanic, P0-005 swing speed/ball speed tuning). The codebase includes a playable gray-box court, visible swing controls, ball-on-racket serve + SERVE button, full racket-segment hitbox, pseudo-3D physics, opponent AI, debug overlay, reset point, and deterministic tests.

Phase 1 implementation is present: match state, scoring, rules, point flow, expanded contact classifications, AI classification choices, score display, and rally feedback. 2026-05-10 follow-ups added P1-008 (OOB fault now resolves — soft rebound removed for in-play balls) and P1-009 (lob/smash thresholds re-tuned, AI lobs more often).

Phase 2 implementation is complete (`P2-001..P2-006` are `done`) with 2026-05-10 follow-up P2-008 wrapping the game canvas in `SafeArea` so it no longer overlaps the notch / notification bar.

Closeout (2026-05-10): P0-002, P1-007, and P2-007 are now `done`. Human playtest on Pixel 10 Pro XL confirmed movement pointer survival, ball-on-racket serve + SERVE button, soft vs firm swing differentiation, OOB faults firing, lob/smash classifications, notch-clear canvas, pause/resume/return-to-menu/hardware-back flows, settings persistence across kill+relaunch, 5+ minute uptime without crash, and the post-fix scoring rule (double-bounce takes precedence over OOB). Phases 0, 1, and 2 are closed.

Perspective follow-up (2026-05-11): New gray-box Phase 0 tickets track the user-reported camera issue: `docs/art/phase-2-screenshot.png` feels too top-down and lacks depth compared with `docs/art/concept-screenshot.png`. P0-006 retunes court projection/framing, P0-007 adds rendering depth cues, and P0-008 verifies the result on Android.

Perspective implementation (2026-05-11): P0-006 and P0-007 are complete. The gray-box court now uses a taller 3/4 projection with stronger near/far scale, reserved control space, a compressed debug overlay, raised net geometry, projected player/opponent bodies, and stronger ball/shadow depth cues. Pixel 10 Pro XL screenshot spot-check confirms the scene is materially less top-down; P0-008 remains the formal 5-minute device QA and screenshot comparison gate.

Phase 3 planning (2026-05-11): Phase 3 fake ad framework tickets are now queued. The work is split into fake ad service, pure frequency rules, rewarded post-match flow, interstitial natural-break flow, debug eligibility visibility, and final Android QA. Phase 3 must not add real AdMob, production ad IDs, banners during gameplay, IAP, or any ad before first gameplay.

Phase 3 implementation (2026-05-11): P3-001 through P3-005 are implemented and automated verification passes. P3-006 is in `review`: debug APK installs and launch command returns OK on Pixel 10 Pro XL, but the full manual fake-ad QA checklist still needs a human pass because screenshot capture showed the device lock screen.

Phase 5 planning (2026-05-11): Phase 5 visual identity pass tickets are queued (P5-001..P5-007). The work is split into asset pipeline + palette + pixel court art (P5-001), player/opponent sprites (P5-002), ball/paddle sprites (P5-003), UI theme + scoreboard + feedback restyle + portraits + menu logo (P5-004), audio service + SFX wired to the existing `soundEnabled` flag (P5-005), haptics service wired to the existing `hapticsEnabled` flag (P5-006), and Android verification (P5-007). Phase 5 must not introduce real AdMob, IAP, tournament/unlocks, new shot buttons, or any change to `CourtProjection`, ball physics, scoring/rules, or AI. Phase 4 (real AdMob test ads) is deliberately not queued yet — it can be planned in parallel or deferred until after Phase 5 lands.

Phase 5 implementation (2026-05-11): P5-001 through P5-006 are complete. The project now has the Phase 5 asset directories, generated placeholder retro court/logo/portrait/sprite/SFX assets, centralized `VisualPalette`, palette-driven court/kitchen/net/touch-control/game UI rendering, player/opponent idle-run-swing sprites, ball and paddle sprites, themed scoreboard with serving indicator, per-shot feedback colors, menu logo, roster portraits, audio service wired to `soundEnabled`, and haptics service wired to `hapticsEnabled`. P5-007 is in `review`: `flutter analyze`, `flutter test` (96 tests), `flutter build apk --debug`, and `flutter install --debug -d 58011FDCQ00992` pass, but the manual Android QA checklist still needs human validation.

Phase 5A-5G planning (2026-05-11): Visual expansion tickets are queued as discrete work, not phase-sized wrappers. Phase 5A locks concept direction and rendering conventions; 5B adds Classic Court environment dressing; 5C polishes court/net/shadows; 5D expands character personality and animation; 5E adds short-lived VFX and rally juice; 5F restyles HUD/screens/court cards; 5G verifies screenshots, Android performance, and closeout. These tickets must preserve the locked control contract, scoring/rules, ball physics, AI, ad placement, and existing settings behavior unless a future non-visual ticket explicitly changes them.

Phase 5A-5G implementation start (2026-05-11): P5A-001 through P5A-003 are complete with baseline/gap docs, visual direction, render-layer rules, asset folders, and pubspec declarations. P5B-001/P5B-002 are complete with low-detail retro ChatGPT-generated environment placeholder assets, manifests, and data-driven Classic environment rendering; P5B-003 is in `review` pending Android environment screenshots. P5C-001/P5C-003 are complete with projected court/kitchen polish, upgraded net/cast-shadow rendering, and a shared directional shadow helper across ball/player/opponent/props/paddle head. P5D-001/P5D-003 are complete with data-driven character visual definitions, roster wiring, expanded ready/hit-confirm/point-result animation states, refreshed roster portraits, and a character-check contact sheet. P5E-001/P5E-002 are complete with placeholder VFX assets, deterministic VFX layer, and contact/bounce event wiring; P5E-003 code is implemented and in `review` pending Android performance smoke. P5F-001/P5F-002/P5F-003/P5F-004 are complete with reusable arcade UI primitives, in-match HUD/control restyle, restyled menu/roster/settings/pause/end-match screens, and court-card placeholder assets. P5G-001 is complete with repeatable UI goldens and blocker-documented gameplay screenshot gaps; P5G-002/P5G-003 are in `review` pending Android QA and final closeout. P5H-001 through P5H-007 are queued as discrete follow-up tickets for remaining non-blocking visual gaps. Claude review was used when available for court/net/shadows/character/VFX/HUD/screen-restyle/backlog decisions; Codex subagent fallback critique was used when Claude was rate-limited. Latest verification passed with `flutter pub get`, `flutter analyze`, `flutter test` (127 tests), and `flutter build apk --debug`; no Android device was visible for the latest install, so the refreshed `dink_rivals-debug.apk` is at workspace root and ignored.

Phase 5.1 planning (2026-05-11): Phase 5.1 Concept Fidelity Correction Pass is queued to close the gap between the latest Phase 5.1 gameplay screenshot and `docs/art/concept-screenshot.png`. The work is split into screenshot triage (P51A), player artifact cleanup (P51B), character pose/scale consistency (P51C), environment de-stretching (P51D), court grounding/grass integration (P51E), park depth/richness (P51F), court/net polish (P51G), HUD/control proportions (P51H), and Android visual QA/closeout (P51I). Claude and a Codex subagent both contributed to the planning breakdown. Phase 5.1 remains visual-only and must preserve scoring/rules/physics/AI/ad behavior and the locked movement + swing-stick control contract.

Phase 5.1 implementation (2026-05-11): P51A through P51H are implemented. The pass added a delta inventory and comparison note, removed high-priority racket-head shadows that read as black player artifacts, regenerated chunkier transparent player/opponent/paddle sprite sheets, preserved raster prop aspect ratios, added a procedural tree/fence backdrop, improved court grounding with apron feather/contact shadow/edge shade, added richer park detail, and reduced visual control dominance while preserving touch hit regions. Claude and a Codex subagent both reviewed the implementation plan. Verification passed with `flutter analyze`, `flutter test` (133 tests), `flutter build apk --debug`, Android install/launch on Pixel 10 Pro XL (`58011FDCQ00992`), and Android screenshot capture for serve/rally/pause states. P51I is in `review`: the full 5-minute Android smoke is still incomplete because the long-running smoke was interrupted around 3 minutes and the Pixel disconnected from Flutter/ADB before a clean restart could finish. The refreshed `dink_rivals-debug.apk` is copied to the workspace root and ignored.

Phase 5.2 planning (2026-05-11): Phase 5.2 Concept Composition and Identity Pass is queued to move the current Phase 5.1 visuals materially closer to `docs/art/concept-screenshot.png` and `docs/art/concept-sheet.png`. The work is split into baseline/delta inventory (P52A-001), visual tokens/layering/AI art rules (P52A-002), projection reinforcement (P52B), court zoning (P52C), net rebuild and serving-indicator relocation (P52D), backdrop signage (P52E), character identity sprites/portraits (P52F), scoreboard/rally/last-shot readout (P52G), top-center feedback banner (P52H), ball trail/contact juice (P52I), visual-only power meter/control polish (P52J), park depth pass two (P52K), final HUD safe-area polish (P52L), and Android visual QA/closeout (P52M). Claude and two Codex subagents reviewed the plan; their conditional signoff is recorded in `docs/art/phase-5.2-planning-review.md`. Phase 5.2 remains visual-only and must preserve scoring/rules/physics/AI/ad behavior and the locked movement + swing-stick control contract.

Phase 5.2 implementation (2026-05-11): P52A-001 through P52L-001 are complete; P52M-001 is in `review` for the physical-device/human validation gate. The pass added delta/art-direction docs, extended `VisualPalette`/layering rules, reinforced the 3/4 court projection, rebuilt court zoning and net treatment, added rear signage/lamp/planter park depth, regenerated player/opponent sprites and roster portraits, added scoreboard rally/last-shot readouts, top-center feedback banner, fixed-buffer ball trail/contact/bounce VFX, and visual control polish. Claude reviewed the generated contact sheet, requested a Rally Queen portrait readability fix, then reported no remaining blockers. Verification passed with `flutter analyze`, `flutter test`, `flutter build apk --debug`, Android emulator install/launch on `emulator-5554`, and menu/gameplay smoke screenshots. The current debug APK also installed on Pixel 10 Pro XL, but latest physical screenshot capture stayed on the lockscreen bouncer and was discarded. Human physical-device playtest and subjective concept signoff remain outside this automated closeout.

## Dashboard

| ID | Phase | Status | Priority | Parallel | Depends on | Summary |
| --- | --- | --- | --- | --- | --- | --- |
| P0-001 | 0 | done | high | legacy | [] | Original blank court rally loop ticket; implementation exists. |
| P0-002 | 0 | done | high | closeout | [] | Close Phase 0 with final QA, notes, and handoff cleanup. |
| P1-001 | 1 | done | high | A | [] | Add match state and scoring system. |
| P1-002 | 1 | done | high | B | [] | Add rules system for bounds, bounce, and kitchen faults. |
| P1-003 | 1 | done | high | C | [P1-001, P1-002] | Integrate point, serve, score, and match flow into the game loop. |
| P1-004 | 1 | done | high | D | [] | Expand shot types and hit/target logic for lob and smash. |
| P1-005 | 1 | done | medium | E | [P1-004] | Improve opponent AI for beginner rallies under Phase 1 shots/rules. |
| P1-006 | 1 | done | medium | F | [P1-001, P1-003, P1-004] | Add scoreboard and rally feedback text. |
| P1-007 | 1 | done | high | final | [P1-003, P1-005, P1-006] | Phase 1 verification, Android QA checklist, and notes. |
| P2-001 | 2 | done | high | A | [] | App shell: GoRouter + Riverpod, route scaffolding for menu/game/settings/roster. |
| P2-002 | 2 | done | high | B | [] | Save service backed by `shared_preferences` for sound/haptics/matches-completed. |
| P2-003 | 2 | done | high | C | [P2-001] | Main menu with Quick Match / Roster / Settings, plus roster placeholder listing the four MVP characters. |
| P2-004 | 2 | done | high | D | [P2-001, P2-002] | Settings screen with persisted Sound and Haptics toggles. |
| P2-005 | 2 | done | high | E | [P2-001] | Game screen wrapper, Pause button, Pause overlay, and pause-aware `update(dt)`. |
| P2-006 | 2 | done | high | F | [P2-001, P2-005] | End-match summary screen with Rematch / Return to Menu and `matchesCompleted` increment. |
| P2-007 | 2 | done | high | final | [P2-002, P2-003, P2-004, P2-005, P2-006] | Phase 2 verification, Android QA checklist, and notes. |
| P0-003 | 0 | done | high | A | [] | Movement pointer survives `resetPoint()` so the player keeps moving through a point loss. |
| P0-004 | 0 | done | high | A | [] | Serve mechanic: ball glued to racket tip + SERVE button launches along racket direction. |
| P0-005 | 0 | done | medium | A | [] | Swing-speed / ball-speed tuning so soft vs firm swings produce visibly different shots. |
| P0-006 | 0 | done | high | perspective | [] | Retune gray-box court projection/framing so the game reads less top-down and closer to the concept screenshot. |
| P0-007 | 0 | done | high | depth-cues | [] | Add gray-box net, scale, shadow, and height cues so the scene has clearer depth. |
| P0-008 | 0 | todo | high | final | [P0-006, P0-007] | Device QA for the perspective pass against concept and Phase 2 screenshots. |
| P1-008 | 1 | done | high | A | [] | Removed soft boundary rebound for in-play balls so OOB faults trigger. |
| P1-009 | 1 | done | medium | A | [] | Lob/smash thresholds re-tuned + AI lob probability raised. |
| P2-008 | 2 | done | medium | A | [] | Game canvas wrapped in `SafeArea` so it no longer overlaps notch / status bar. |
| P3-001 | 3 | done | high | A | [] | Add `AdService` interface and `FakeAdService` without real ad SDK integration. |
| P3-002 | 3 | done | high | B | [] | Add pure ad placement system for interstitial session/time frequency rules. |
| P3-003 | 3 | done | high | C | [P3-001] | Add optional fake rewarded ad action on the post-match screen. |
| P3-004 | 3 | done | high | D | [P3-001, P3-002] | Show fake interstitial modal only at eligible post-match natural breaks. |
| P3-005 | 3 | done | medium | E | [P3-001, P3-002] | Add debug visibility for ad eligibility and frequency gates. |
| P3-006 | 3 | review | high | final | [P3-001, P3-002, P3-003, P3-004, P3-005] | Phase 3 fake ad framework verification and Android QA. |
| P5-001 | 5 | done | high | A | [] | Visual palette, asset pipeline, and pixel-style court art (preserves 3/4 projection). |
| P5-002 | 5 | done | high | B | [P5-001] | Player and opponent sprite components with idle/run/swing animations driven by `PlayerState`. |
| P5-003 | 5 | done | high | C | [P5-001] | Ball and paddle sprites; shadow component unchanged; height-scale curve preserved. |
| P5-004 | 5 | done | high | D | [P5-001] | UI theme + scoreboard restyle (serving indicator) + DINK/DRIVE/LOB/SMASH/FAULT colors + roster portraits + menu logo. |
| P5-005 | 5 | done | high | A | [] | Audio service + hit/bounce/point/fault/menu-click SFX wired to `soundEnabled`. |
| P5-006 | 5 | done | medium | A | [] | Haptics service for player hit (light) and player point win (medium), wired to `hapticsEnabled`. |
| P5-007 | 5 | review | high | final | [P5-001, P5-002, P5-003, P5-004, P5-005, P5-006] | Phase 5 verification, Android QA checklist, and notes. |
| P5A-001 | 5A | done | high | A | [P5-007] | Capture current Phase 5 screenshot baseline and concept gap inventory. |
| P5A-002 | 5A | done | high | B | [P5A-001] | Create visual-direction source of truth with locked/provisional decisions and readability rules. |
| P5A-003 | 5A | done | high | C | [P5A-002] | Define asset folders, render-layer map, occlusion rules, and SafeArea conventions. |
| P5B-001 | 5B | done | high | A | [P5A-002, P5A-003] | Generate Classic Court environment placeholder assets and manifest. |
| P5B-002 | 5B | done | high | B | [P5B-001] | Add data-driven Classic environment component and prop placement. |
| P5B-003 | 5B | review | medium | final | [P5B-002] | Android environment readability QA and screenshots. |
| P5C-001 | 5C | done | high | A | [P5A-002] | Replace early court surface with richer Classic Court texture and kitchen treatment. |
| P5C-002 | 5C | done | high | B | [P5A-003] | Upgrade net art with posts, rail, mesh, and cast shadow. |
| P5C-003 | 5C | done | medium | C | [P5C-001, P5C-002] | Add shared directional shadows and subtle lighting pass. |
| P5D-001 | 5D | done | high | A | [P5A-002] | Add data-driven character visual definitions for the four MVP characters. |
| P5D-002 | 5D | done | high | B | [P5D-001] | Expand character sprite sheets and animation states without hitbox changes. |
| P5D-003 | 5D | done | medium | C | [P5D-001, P5D-002] | Update matching roster portraits and document character visual QA. |
| P5E-001 | 5E | done | high | A | [P5A-003] | Add VFX framework and placeholder VFX assets. |
| P5E-002 | 5E | done | high | B | [P5E-001] | Wire contact, bounce, dink/drive/lob/smash VFX to existing events. |
| P5E-003 | 5E | review | medium | C | [P5E-002] | Add ball trails, point bursts, and Android VFX performance check. |
| P5F-001 | 5F | done | high | A | [P5A-002] | Add reusable arcade UI primitives and theme tokens. |
| P5F-002 | 5F | done | high | B | [P5F-001] | Restyle concept HUD, scoreboard, feedback, pause button, and controls. |
| P5F-003 | 5F | done | high | C | [P5F-001] | Restyle menu, roster, settings, pause overlay, and end-match screens. |
| P5F-004 | 5F | done | medium | D | [P5F-001] | Add court card assets/placeholders without court-selection scope. |
| P5G-001 | 5G | done | high | A | [P5B-003, P5C-003, P5D-003, P5E-003, P5F-002, P5F-003, P5F-004] | Automated visual verification and screenshot comparison set. |
| P5G-002 | 5G | review | high | B | [P5G-001] | Android performance and readability QA for expanded visuals. |
| P5G-003 | 5G | review | high | final | [P5G-001, P5G-002] | Visual gap backlog and Phase 5A-5G closeout. |
| P51A-001 | 5.1A | done | high | A | [P5G-001] | Lock current Phase 5.1 baseline and create concept delta inventory. |
| P51B-001 | 5.1B | done | high | B | [P51A-001, P5D-002] | Remove black artifacts/matte halos around player and opponent models. |
| P51C-001 | 5.1C | done | high | C | [P51B-001] | Make character scale, pose, and direction readable and consistent before/after serve. |
| P51D-001 | 5.1D | done | high | D | [P51A-001, P5B-002] | Fix stretched fence/trees/props with proportionate data-driven placement. |
| P51E-001 | 5.1E | done | high | E | [P51D-001, P5C-003] | Ground the court with believable grass/pavement transitions and contact shadows. |
| P51F-001 | 5.1F | done | high | F | [P51D-001, P51E-001] | Add layered park depth and background richness closer to the concept screenshot. |
| P51G-001 | 5.1G | done | medium | G | [P51E-001, P5C-003] | Polish court surface, kitchen, net, lines, and shadow cohesion. |
| P51H-001 | 5.1H | done | medium | H | [P51A-001, P5F-002] | Tune HUD and control proportions against concept and latest gameplay screenshot. |
| P51I-001 | 5.1I | review | high | final | [P51B-001, P51C-001, P51D-001, P51E-001, P51F-001, P51G-001, P51H-001] | Verify Phase 5.1 on Android, write comparison, and queue residual gaps. |
| P5H-001 | 5H | todo | high | A | [P5G-001] | Add a reliable gameplay golden capture harness for Flame-rendered states. |
| P5H-002 | 5H | todo | medium | B | [P5G-001] | Evaluate and add a Flutter web screenshot capture path if accepted. |
| P5H-003 | 5H | todo | medium | C | [P5G-001] | Improve main menu logo prominence and top-band composition. |
| P5H-004 | 5H | todo | medium | D | [P5D-003] | Improve Rally Queen portrait readability at roster-card scale. |
| P5H-005 | 5H | todo | medium | D | [P5D-003] | Strengthen Veteran portrait accent readability. |
| P5H-006 | 5H | todo | medium | E | [P5B-002, P5C-003] | Add a cheap far-background band for more environment depth. |
| P5H-007 | 5H | todo | low | F | [P5D-002] | Add subtle idle/ready character micro-animation without gameplay changes. |
| P52A-001 | 5.2A | done | high | A | [P51I-001] | Capture Phase 5.2 baseline screenshots and create concept delta inventory. |
| P52A-002 | 5.2A | done | high | A | [P52A-001] | Extend visual tokens, render-layer rules, safe-area rules, and AI art prompts/export checks. |
| P52B-001 | 5.2B | done | high | B | [P52A-002] | Reinforce 3/4 projection and framing with screenshot and coordinate-stability gates. |
| P52C-001 | 5.2C | done | high | C | [P52B-001] | Add concept court zoning, apron, kitchen tint, and line contrast. |
| P52D-001 | 5.2D | done | high | C | [P52B-001] | Rebuild net and relocate the floating serving indicator into the scoreboard flow. |
| P52E-001 | 5.2D | done | high | D | [P52A-002] | Add rear fence signage band with original Dink Rivals and park sign assets. |
| P52F-001 | 5.2E | done | high | E | [P52A-002, P51C-001] | Upgrade character identity sprites and matching roster portraits while keeping `RacketComponent` separate. |
| P52G-001 | 5.2F | done | high | F | [P52A-002, P52D-001] | Restyle scoreboard with YOU/RIVAL labels, serving dot, rally counter, and last-shot readout. |
| P52H-001 | 5.2G | done | high | F | [P52G-001] | Replace floating rally number with a top-center shot/fault/point feedback banner. |
| P52I-001 | 5.2H | done | high | G | [P52A-002] | Add fixed-buffer ball trail and refreshed contact/bounce VFX. |
| P52J-001 | 5.2I | done | high | H | [P52A-002] | Add visual-only swing power meter and concept-style control polish without input changes. |
| P52K-001 | 5.2J | done | medium | D | [P52E-001] | Add lamp/planter/bench/tree-band park depth pass two. |
| P52L-001 | 5.2I | done | medium | H | [P52J-001, P52G-001, P52H-001] | Final HUD/control safe-area and proportion polish. |
| P52M-001 | 5.2K | review | high | final | [P52C-001, P52D-001, P52E-001, P52F-001, P52G-001, P52H-001, P52I-001, P52J-001, P52K-001, P52L-001] | Phase 5.2 Android visual QA, comparison doc, and Phase 5.3 residual backlog. |

## Open Coordination Notes

- Phase 5A-5G is visual expansion work only. It may add assets, visual components, UI style, and QA documentation, but it must not alter scoring/rules, ball physics, AI, ad placement, the movement + swing-stick control contract, or monetization/progression scope. Phase 5A direction tickets should be completed before broad environment, court, character, VFX, or UI expansion tickets.
- Phase 5.1 is a concept-fidelity correction pass. Start with P51A-001; do not implement visual fixes until current-vs-concept deltas and acceptance shots are documented. It may supersede some P5H follow-ups, but only after P51A maps them. Preserve controls/scoring/rules/physics/AI/ads. Avoid `CourtProjection`; change `CourtLayoutSystem` only if P51A proves framing blocks concept fidelity.
- Phase 5.2 is a concept composition and identity pass. Start with P52A-001/P52A-002 before implementation. Projection work in P52B is serial and high risk; court/net placement should wait for it. P52E/P52K, P52G/P52H, and P52J/P52L are intentionally serialized by shared file ownership. P5H-003 through P5H-007 are absorbed, superseded, or deferred by Phase 5.2 planning; P52A-001 must record the exact handling.
- Existing worktree has local changes from prior Phase 0 tuning. Do not revert them.
- `dink_rivals/PHASE_NOTES.md` is the authoritative playtest history.
- Phase 1 should preserve the current visible movement joystick, swing-stick racket control, automatic racket contact, full racket-segment hitbox, and enlarged play area unless a ticket explicitly changes them.
- Shot names are contact classifications, not UI commands. Do not add dink/drive/lob/smash buttons while completing current tickets.
- Scoring and rules should be testable outside Flame components.
- Avoid adding menus, ads, art, persistence, audio, or progression while Phase 1 is active.
- During Phase 2 work, preserve the Phase 0/Phase 1 control contract and all existing gameplay/AI/physics behavior. Only the wrapping app shell and persistence surfaces are in scope. No ads, no real audio/haptics, no art pass — those phases come later.
- Phase 2 must not break the "no forced ad before first gameplay" rule; ad logic does not exist yet and should not be introduced ahead of Phase 3.
- P0-006 through P0-008 are a gray-box perspective correction. Do not add production art assets, change scoring/rules/AI, or alter the locked movement + swing-stick control contract while completing them.
- Phase 3 uses fake ads only. Do not add `google_mobile_ads`, real AdMob app IDs, production ad unit IDs, IAP, remove-ads purchase logic, or banners. Fake interstitials may appear only at post-match natural breaks after frequency gates pass; fake rewarded ads must be user-initiated.
- Phase 5 is art + audio only. Do not touch `CourtProjection`, `CourtLayoutSystem`, ball physics, scoring/rules, AI logic, or the locked control contract (movement stick + swing stick + automatic racket-contact classification — no dink/drive/lob/smash buttons). No real AdMob, IAP, tournament, or unlock work in Phase 5. Reuse the existing `soundEnabled` / `hapticsEnabled` flags from `SaveService` — do not add new settings toggles. All component colors must read from `VisualPalette`; no new hardcoded color literals.
