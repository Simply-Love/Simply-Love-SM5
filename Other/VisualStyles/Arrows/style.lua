-- VisualStyle options:
-- id: saved preference value; use a unique name.
-- name: display name. choice: optional short label or emoji for the options menu.
-- colorOverBackground: optional; omitted uses Color.White by default and Color.Black in RainbowMode.
-- colorOverBackground.default: foreground RGBA color; defaults to Color.White.
-- colorOverBackground.rainbowMode: foreground RGBA color; omit from an explicit table to disable RainbowMode.
-- Image and actor backgrounds must implement their own RainbowMode behavior when opting in.
-- background.type: default (moving pattern), image (still image), or actor (Lua actor).
-- background.file: file relative to this folder; optional texture for default, required for image and actor.
-- background.fit: cover (default) or contain; used by image backgrounds.
-- background.dim: black overlay from 0 to 1 (default 0); used by image backgrounds.
-- background.color: optional #RRGGBB backdrop color outside RainbowMode and holidays.
-- title: optional title-screen layout; positions are relative to screen center.
-- title.textY / textZoom / textRotation: title text position, scale, and rotation.
-- title.logoY / logoZoom / logoRotation: decorative logo position, scale, and rotation.
-- title.infoY / infoZoom: theme information position and scale.
-- assets.TitleLogo: optional replacement for the decorative game logo.
-- assets: optional table of graphic names to files relative to this folder.
-- sounds: optional table of sound names to audio files relative to this folder.
-- sounds.menuMusic: menu loop; defaults to Hearts. sounds.gameOverMusic: defaults to fold.ogg.
-- sounds.evaluationMusic: replaces the random evaluation music when provided.
-- sounds.evaluationSummaryMusic: replaces the silent summary music outside December.
-- sounds.evaluationPassed / evaluationFailed: optional result sounds.
-- sounds.titleToGameplay: optional sound when Gameplay is chosen on the title screen.
-- Holiday menu music takes precedence except for Thonk; Spooky's title sound is seasonal.
-- Graphics resolve within the style folder; missing graphics fall back to Hearts.
-- FallbackBanners/banner1 (doubleres).png, etc. provide per-color banners; missing banners use Arrows.
-- The December holiday background overrides the foreground color with Color.White.

return {
	id = "Arrows",
	name = "Arrows",
	choice = "↖",
	colorOverBackground = {
		default = Color.White,
		rainbowMode = Color.Black,
	},
	background = { type = "default" },
}
