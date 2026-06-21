# Portrait / Vertical Mode

A portrait (vertical) layout for **single-player** Simply Love on a monitor
rotated 90° — for example a 9:16 / 1080×1920 display with a dance pad. Turning
the monitor sideways gives roughly **1.7× more arrow-scrolling space**.

This is **not** a feature fork. It is built on current mainline Simply Love, so
every modern feature still works:

- GrooveStats integration (auto-submit, leaderboards, rivals, QR login)
- EX score
- Quint Star grade
- FA+ mode

Portrait support is added by branching the **layout** on screen orientation, so
the theme still runs correctly in landscape and no feature code is touched.


## Setup

1. Rotate your monitor to portrait in your OS display settings.
2. Switch to this theme in ITGmania.
3. In *Graphics / Sound Options*, pick the portrait aspect ratio / resolution if
   one is offered. If not, edit `Preferences.ini` directly:

   ```
   DisplayAspectRatio=0.562500   # 9:16
   DisplayHeight=1920            # DisplayWidth is ignored
   ```

   `Preferences.ini` lives in your ITGmania save folder, **not** in the theme.
   Restart ITGmania after changing it.

For other portrait resolutions, set `DisplayAspectRatio` to `width / height`
(e.g. 720×1280 is also `0.562500`) and `DisplayHeight` to the pixel height.


## How it works

StepMania's virtual coordinate system keeps the **height fixed at 480** and sets
the **width to `480 × aspect_ratio`**. So in 9:16 portrait the virtual screen is
about **270 wide × 480 tall** (`_screen.w ≈ 270`, `_screen.h = 480`,
`_screen.cx ≈ 135`). The dance notefield is 256 virtual units wide, so when
centered it fills ~95% of the portrait width.

Because Simply Love was designed for landscape (width > height), its HUD elements
position themselves with offsets like `_screen.cx ± ~288`, which land far
off-screen on a 270-wide portrait screen. The breakage is therefore mostly
**horizontal**; vertical positions (and the receptor / draw-distance math) stay
valid because the virtual height is unchanged.

The portrait layer has two pieces:

- **`Scripts/SL-Helpers.lua`** — `IsVerticalScreen()` returns
  `GetScreenAspectRatio() <= 1`. This is the single check the layout branches on.

- **`Scripts/SL-Positions.lua`** — a `Positions` table that returns a portrait
  value when the screen is vertical and otherwise the exact value mainline would
  have used. This is the **central tuning surface**: most portrait magic numbers
  live here so they can be adjusted in one place.

Individual screen files add small `if IsVerticalScreen() then … end` branches
(or call into `Positions`) only where the landscape math breaks. Centering the
notefield also reuses Simply Love's existing "Center 1 Player" code paths, so
several HUD elements (NPS graph, BPM, etc.) reflow automatically.


## Tuning workflow

Theme layout is visual and iterative, and it can only be verified on the actual
portrait display. The loop is:

1. Build / pull the theme onto the portrait machine.
2. Play a song and screenshot each screen.
3. Adjust the numbers (mostly in `Scripts/SL-Positions.lua`, or the relevant
   screen file) and repeat.

When reporting layout issues, a screenshot per screen (gameplay, song select,
evaluation) is the most useful thing to share.


## Status

**Done — gameplay (first pass):**

- Notefield centered horizontally (`metrics.ini` → `Positions`)
- Score (and EX score) moved to the top-right, scaled down
- Difficulty meter moved to the top-right corner
- Life meter: Standard centered in the top strip; Vertical pinned to the left
  edge; Surround spans the full width behind the arrows
- Song-info bar fitted to the portrait width
- Danger / fail flash covers the full screen
- Header, BPM, and the NPS graph reflow automatically via the centered-notefield
  paths

**Done — song select (first pass):**

- Banner centered and scaled to fit, near the top
- Song-description panel centered below the banner and fitted to width
- Density graph centered and fitted to width
- Step-artist credit brought on-screen
- GrooveStats leaderboard (1P) fitted to width
- Radar pane centered for single player

**Done — evaluation (first pass):**

- Per-player panes / upper results centered (were at `_screen.cx ± 155`, off the
  left of the portrait canvas)
- Lower pane kept a single centered column instead of double width
- Results banner scaled to fit width

**Needs screenshot tuning:**

- Gameplay top strip and the EX Target Score / Pacemaker overlay
- Evaluation in-pane content (judgment breakdown, GrooveStats QR, offset
  histogram) once the panes are centered
- Song-description inner content offset; density-graph vs. music-wheel overlap;
  radar-pane columns at the narrower width

**Scope:** single player only. Two-player layout is not targeted; if a second
player is never joined, its actors are never created, so P2 graphics stay out of
the way.


## Credits

The portrait layout approach — the `IsVerticalScreen()` helper and the
`Positions` abstraction — is adapted from
[Sereni's Simply-Love-SM5-Vertical](https://github.com/Sereni/Simply-Love-SM5-Vertical)
(based on SL 4.9), re-derived on top of current mainline Simply Love.
