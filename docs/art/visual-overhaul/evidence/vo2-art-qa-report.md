# VO2 Visual QA Report

Date: 2026-05-12  
Agent: VO2 Visual QA Agent  
Scope: Read-only audit of current VO2 screenshots/assets against `docs/art/concepts/concept-screenshot.png` and `docs/specs/visual-overhaul-v2-spec.md`.

## Verdict

**FAIL.** VO2 does not meet the concept-quality bar yet. The environment improved, but the current evidence and assets do not resolve the user's core complaints: characters still read bland/small against the environment, signage is weak, current gameplay evidence does not prove ball/opponent readability, and the run animation remains too slight.

## Evidence Reviewed

- Concept target: `docs/art/concepts/concept-screenshot.png` (852x1846, sha256 `8467025A6893`)
- Spec: `docs/specs/visual-overhaul-v2-spec.md`
- Decomp: `docs/art/visual-overhaul/visual-overhaul-v2-decomp.md`
- Current serve screenshot: `docs/art/visual-overhaul/evidence/vo2-final-serve.png` (1344x2992, sha256 `70DF7D00342E`)
- Current rally/shot screenshots: `docs/art/visual-overhaul/evidence/vo2-final-rally.png`, `vo2-final-dink.png`, `vo2-final-lob.png`, `vo2-final-smash.png` (all sha256 `4A422370CCBF`)
- Drive screenshot: `docs/art/visual-overhaul/evidence/vo2-final-drive.png` (sha256 `25F9A4DAB5B3`)
- Player contact sheet: `docs/art/visual-overhaul/contact-sheets/vo2-player-ingame.png`
- Opponent contact sheet: `docs/art/visual-overhaul/contact-sheets/vo2-opponent-ingame.png`
- Player run sheet: `dink_rivals/assets/images/sprites/player_run.png` (288x72, six 48x72 frames, sha256 `E48480E05369`)
- Opponent run sheet: `dink_rivals/assets/images/sprites/opponent_run.png` (288x72, six 48x72 frames, sha256 `2F6AB3709868`)
- Signage layer: `dink_rivals/assets/images/environment/classic/layer_fence_signage.png` (979x1606, sha256 `EDB238BC41E5`)
- Net layer: `dink_rivals/assets/images/environment/classic/layer_net.png` (979x1606, sha256 `B906E972DAA1`)

## Prioritized Findings

### P0 - Gameplay Evidence Is Not Valid For VO2 Closeout

**Fail.** `vo2-final-rally.png`, `vo2-final-dink.png`, `vo2-final-lob.png`, and `vo2-final-smash.png` are byte-identical fault/serve-overlay captures, not distinct rally/shot states. They show `FAULT! TWO BOUNCE` and `OPPONENT TO SERVE`, so they cannot validate ball trail, shot poses, opponent visibility, or net occlusion during live play.

Evidence: `docs/art/visual-overhaul/evidence/vo2-final-rally.png`, `vo2-final-dink.png`, `vo2-final-lob.png`, `vo2-final-smash.png`.

Impact: VO2 cannot be marked visually complete because the required rally/dink/lob/smash acceptance evidence is effectively missing.

### P1 - Characters Still Do Not Match The Environment Quality

**Fail.** The environment is painterly/high-detail pixel art, while player/opponent sprites remain tiny, low-detail, and token-like. In `vo2-final-serve.png`, the near player is visibly smaller and simpler than the concept target; cap, face, limbs, shoes, and paddle do not carry the same readable mass as `concept-screenshot.png`. The far opponent is even weaker and visually collapses into the fence/signage band.

Evidence: `docs/art/visual-overhaul/evidence/vo2-final-serve.png`, `docs/art/visual-overhaul/contact-sheets/vo2-player-ingame.png`, `docs/art/visual-overhaul/contact-sheets/vo2-opponent-ingame.png`.

Spec conflict: `visual-overhaul-v2-spec.md` requires clearly drawn pixel-art athletes with visible cap, face, paddle, and mid-action pose at gameplay distance.

### P1 - Run Animation Still Reads Incomplete

**Fail.** The run sheets have six frames, but the pose delta is modest and mostly reads as a small shuffle. The silhouette lacks the strong leg/arm extension and squash/stretch expected from the concept's arcade athlete style. At gameplay scale this will read as sliding unless movement speed is high.

Evidence: `dink_rivals/assets/images/sprites/player_run.png`, `dink_rivals/assets/images/sprites/opponent_run.png`, plus contact sheets `docs/art/visual-overhaul/contact-sheets/vo2-player-ingame.png` and `vo2-opponent-ingame.png`.

Spec conflict: VO2 requires animation transitions to play without frame snap and characters to read as mid-action athletes, not small tokens.

### P1 - Net/Occlusion Readability Is Not Proven And Looks Risky

**Fail.** The current accepted screenshots do not include a clean live-rally ball crossing the net. In `vo2-final-serve.png`, the far opponent sits low in the busy fence/signage/net band and loses leg readability. In the duplicate fault captures, the modal darkens the whole screen, so they cannot validate whether the ball/opponent remain readable through or around the net.

Evidence: `docs/art/visual-overhaul/evidence/vo2-final-serve.png`, `docs/art/visual-overhaul/evidence/vo2-final-rally.png`, `dink_rivals/assets/images/environment/classic/layer_net.png`.

Impact: The user's complaint that the net hides the ball/opponent remains unresolved by evidence. This must be recaptured during a live rally with ball positions in front of, behind, and crossing the net.

### P2 - Signage Is Legible But Art Direction Is Weak

**Fail.** The signage layer is cleaner than v1, but it does not hit the concept. The concept's central banner has a strong branded logo composition with large cream/red text and a pickleball icon; the current main sign is a flat rectangle with plain `DINK RIVALS` text. The right `PICKLEBALL LEGENDS` sign is legible but clipped/awkward in runtime framing, and the left fence includes blank placards that look unfinished.

Evidence: `dink_rivals/assets/images/environment/classic/layer_fence_signage.png`, `docs/art/visual-overhaul/evidence/vo2-final-serve.png`, compared to `docs/art/concepts/concept-screenshot.png`.

Spec conflict: VO2 calls for backdrop signage that reads as an arcade pickleball venue, with prominent branded banner and framed secondary sign.

### P2 - Environment Layer Dimensions Do Not Match The Spec Canvas

**Fail.** The VO2 spec states environment layers share the 941x1672 canvas. Current `layer_fence_signage.png` and `layer_net.png` are 979x1606. Runtime may compensate, but this is a normalization miss and increases risk of projection/signage/net alignment drift.

Evidence: `dink_rivals/assets/images/environment/classic/layer_fence_signage.png` (979x1606), `dink_rivals/assets/images/environment/classic/layer_net.png` (979x1606).

## Passes

- Environment is now recognizably denser and more venue-like than earlier phase evidence.
- Score/HUD plaques are present and generally follow the concept anchors.
- Player and opponent are color-distinct in contact sheets.
- Run sheets technically contain the required six 48x72 frames.

## Required Before Closeout

1. Recapture valid gameplay evidence for rally, dink, drive, lob, smash, and ball-net crossing. Current duplicate fault captures are not acceptable closeout evidence.
2. Regenerate or repaint character sheets to match the environment's detail level and the concept's athlete read at full-screen gameplay scale.
3. Rework run poses with clearer stride extremes and stronger silhouette changes.
4. Rework signage composition: concept-like central logo banner, no blank placards, runtime framing that does not clip the secondary sign.
5. Validate net/ball/opponent readability with specific screenshots where the ball crosses the net and the opponent is active behind it.
