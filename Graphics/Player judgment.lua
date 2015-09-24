local kids, JudgmentSet
local player = Var "Player"
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers

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
			JudgmentSet:zoom(0.85)
		else
			JudgmentSet:zoom(0.9)
		end

		JudgmentSet:decelerate(0.1):zoom(0.8):sleep(1)
		JudgmentSet:accelerate(0.2):zoom(0)
	end

	t[#t+1] = Def.Sprite{
		Name="JudgmentWithOffsets",
		InitCommand=function(self)

			self:pause():visible(false)

			-- if we are on ScreenEdit, judgment font is always "Love"
			if string.match(tostring(SCREENMAN:GetTopScreen()),"ScreenEdit") then
				self:Load( THEME:GetPathG("", "_judgments/Love") )
			elseif mods.JudgmentGraphic == "3.9" then
				self:Load( THEME:GetPathG("", "_judgments/3_9"))
			else
				self:Load( THEME:GetPathG("", "_judgments/" .. mods.JudgmentGraphic) )
			end

		end,
		ResetCommand=cmd(finishtweening;x,0;y,0;stopeffect;visible,false)
	}
end

return t
