local kids, JudgmentSet
local player = Var "Player"
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers

-- - - - - - - - - - - - - - - - - - - - - -

if mods.JudgmentGraphic ~= "None" then
	-- a Judgment might be saved to a profile from a previous GameMode
	-- that doesn't exist in the current GameMode.  If so, attempt to set
	-- it to the first available Judgment graphic.  If none are available,
	-- set it to "None" as a last resort fallback.
	local path
	if SL.Global.GameMode == "StomperZ" then
		path = THEME:GetPathG("", "_judgments/StomperZ")
	else
		path = THEME:GetPathG("", "_judgments/Competitive")
	end

	local files = FILEMAN:GetDirListing(path .. "/")
	local judgment_exists = false
	for i,filename in ipairs(files) do
		if string.match(filename, " %dx%d") then
			local name = filename:gsub(" %dx%d", ""):gsub(" %(doubleres%)", ""):gsub(".png", "")
			if mods.JudgmentGraphic == name then
				judgment_exists = true
				break
			end
		else
			table.remove(files,i)
		end
	end
	if not judgment_exists then
		mods.JudgmentGraphic = files[1] or "None"
	end
end
-- - - - - - - - - - - - - - - - - - - - - -

local JudgeCmds = {
	TapNoteScore_W1 = THEME:GetMetric( "Judgment", "JudgmentW1Command" ),
	TapNoteScore_W2 = THEME:GetMetric( "Judgment", "JudgmentW2Command" ),
	TapNoteScore_W3 = THEME:GetMetric( "Judgment", "JudgmentW3Command" ),
	TapNoteScore_W4 = THEME:GetMetric( "Judgment", "JudgmentW4Command" ),
	TapNoteScore_W5 = THEME:GetMetric( "Judgment", "JudgmentW5Command" ),
	TapNoteScore_Miss = THEME:GetMetric( "Judgment", "JudgmentMissCommand" )
}

local TNSFrames = {
	TapNoteScore_W1 = 0,
	TapNoteScore_W2 = 1,
	TapNoteScore_W3 = 2,
	TapNoteScore_W4 = 3,
	TapNoteScore_W5 = 4,
	TapNoteScore_Miss = 5
}


local t = Def.ActorFrame {
	Name="Player Judgment"
}


if mods.JudgmentGraphic and mods.JudgmentGraphic ~= "None" then

	t.InitCommand=function(self)
		kids = self:GetChildren()
		JudgmentSet = kids.JudgmentWithOffsets
	end
	t.JudgmentMessageCommand=function(self, param)
		if param.Player ~= player then return end
		if not param.TapNoteScore then return end
		if param.HoldNoteScore then return end

		-- frame check; actually relevant now.
		local iNumStates = JudgmentSet:GetNumStates()
		local frame = TNSFrames[ param.TapNoteScore ]
		if not frame then return end
		if iNumStates == 12 then
			frame = frame * 2
			if not param.Early then
				frame = frame + 1
			end
		end
		self:playcommand("Reset")

		-- begin commands
		JudgmentSet:visible( true )
		JudgmentSet:setstate( frame )

		-- frame0 is like (-fantastic)
		-- frame1 is like (fantastic-)
		if frame == 0 or frame == 1 then
			JudgmentSet:zoom(0.80)
		else
			JudgmentSet:zoom(0.85)
		end

		JudgmentSet:decelerate(0.1):zoom(0.75):sleep(1)
		JudgmentSet:accelerate(0.2):zoom(0)
	end

	t[#t+1] = Def.Sprite{
		Name="JudgmentWithOffsets",
		InitCommand=function(self)

			self:pause():visible(false)

			-- if we are on ScreenEdit, judgment font is always "Love"
			if string.match(tostring(SCREENMAN:GetTopScreen()),"ScreenEdit") then
				self:Load( THEME:GetPathG("", "_judgments/Love") )
			else
				if SL.Global.GameMode ~= "StomperZ" then
					if mods.JudgmentGraphic == "3.9" then
						self:Load( THEME:GetPathG("", "_judgments/3_9"))
					else
						self:Load( THEME:GetPathG("", "_judgments/Competitive/" .. mods.JudgmentGraphic) )
					end
				else
					self:Load( THEME:GetPathG("", "_judgments/StomperZ/" .. mods.JudgmentGraphic) )
				end
			end

		end,
		ResetCommand=cmd(finishtweening; stopeffect; visible,false)
	}
end

return t