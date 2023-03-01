-- the MusicWheelItem for CourseMode contains the basic colored Quads
-- use that as a common base, and add in a Sprite for "Has Edit"
local af = LoadActor("../MusicWheelItem Course NormalPart.lua")

local stepstype = GAMESTATE:GetCurrentStyle():GetStepsType()

-- using a png in a Sprite ties the visual to a specific rasterized font (currently Miso),
-- but Sprites are cheaper than BitmapTexts, so we should use them where dynamic text is not needed
af[#af+1] = Def.Sprite{
	Texture=THEME:GetPathG("", "Has Edit (doubleres).png"),
	InitCommand=function(self)
		self:horizalign(left):visible(false):zoom(0.375)
		self:x( _screen.w/(WideScale(2.15, 2.14)) - self:GetWidth()*self:GetZoom() - 8 )

		if DarkUI() then self:diffuse(0,0,0,1) end
	end,
	SetCommand=function(self, params)
		self:visible(params.Song and params.Song:HasEdits(stepstype) or false)
	end
}

for player in ivalues(GAMESTATE:GetEnabledPlayers()) do
	-- Only use lamps if a profile is found
	if PROFILEMAN:IsPersistentProfile(player) then
		af[#af+1] = LoadActor("GetLamp.lua", player)..{}

		-- Add ITL EX scores to the song wheel as well.
		-- It will be centered to the item if only one player is enabled, and stacked otherwise.
		af[#af+1] = Def.BitmapText{
			Font="Wendy/_wendy monospace numbers",
			Text="",
			InitCommand=function(self)
				self:visible(false)
				self:zoom(0.2)
				self:x( _screen.w/(WideScale(2.15, 2.14)) - self:GetWidth()*self:GetZoom() - 40 )
				if GAMESTATE:GetNumSidesJoined() == 2 then
					if player == PLAYER_1 then
						self:addy(-11)
					else
						self:addy(4)
					end
				else
					self:addy(-4)
				end
				self:diffuse(SL.JudgmentColors["FA+"][1])
			end,
			SetCommand=function(self, params)
				local pn = ToEnumShortString(player)
				if params.Song ~= nil then
					local song = params.Song
					local song_dir = song:GetSongDir()
					if song_dir ~= nil and #song_dir ~= 0 then
						if SL[pn].ITLData["pathMap"][song_dir] ~= nil then
							local hash = SL[pn].ITLData["pathMap"][song_dir]
							if SL[pn].ITLData["hashMap"][hash] ~= nil then
								self:settext(tostring(SL[pn].ITLData["hashMap"][hash]["ex"] / 100))
								self:visible(true)
								return
							end
						end
					end
				end
				self:visible(false)
			end,
		}
	end
end

return af