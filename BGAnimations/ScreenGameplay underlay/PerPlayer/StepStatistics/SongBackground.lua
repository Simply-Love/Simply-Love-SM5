local player = ...

-- AspectRatios is a global table defined in _fallback/Scripts/02 Utilities.lua
-- that lists aspect ratios supported by SM5 as key/value pairs.  I am misusing it here to index
-- my own crop_amount table with the numbers it provides so I can look up how much to crop the
-- song's background by. Indexing with floating-point keys seems inadvisable, but I don't have
-- enough CS background to say for certain. I'll change this if (when) issues are identified.

local crop_amount = {
	-- notefield is not centered
	[false] = {
		[AspectRatios.FourThree] = 0.5,
		[AspectRatios.SixteenNine] = 0.5,
		[AspectRatios.SixteenTen] = 0.5,
	},
	-- notefield is centered
	[true] = {
		-- centered notefield + 4:3 AspectRatio means that StepStats should be disabled and we
		-- should never get here, but specify 1 to crop the entire background away Just In Case.
		[AspectRatios.FourThree] = 1,
		-- These are supported, however, when the notefield is centered.
		[AspectRatios.SixteenNine] = 0.3515,
		[AspectRatios.SixteenTen] = 0.333333,
	}
}

-- round the DisplayAspectRatio value from the user's Preferences.ini file to not exceed
-- 5 decimal places of precision to match the AspectRatios table from the _fallback theme
local ar = round(PREFSMAN:GetPreference("DisplayAspectRatio"), 5)
local centered = PREFSMAN:GetPreference("Center1Player")

local bg

-- if the player has Hide Background enabled, use a black Quad to hide the scrolling graph
if SL[ToEnumShortString(player)].ActiveModifiers.HideSongBG then
	bg = Def.Quad{ OnCommand=function(self) self:diffuse(0,0,0,1):FullScreen() end }

-- otherwise, load the Song's background into a Sprite and use that to hide the scrolling graph
else
	bg = Def.Sprite{
		CurrentSongChangedMessageCommand=function(self)
			-- Background scaling and cropping is handled by the _fallback theme via
			-- scale_or_crop_background(), which is defined in _fallback/Scripts/02 Actor.lua
			self:LoadFromCurrentSongBackground():scale_or_crop_background()
		end
	}
end

-- the cropping behavior will be the same regardless of whether it is a Quad or a Sprite
bg.InitCommand=function(self)
	if player == PLAYER_1 then
		self:cropright( crop_amount[centered][ar] )

	elseif player == PLAYER_2 then
		self:cropleft( crop_amount[centered][ar] )
	end
end

return bg
