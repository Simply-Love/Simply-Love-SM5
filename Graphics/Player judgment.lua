local player = Var "Player"
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers
local kids, JudgmentSet

------------------------------------------------------------
-- A profile might ask for a judgment graphic that doesn't exist in the current GameMode
-- If so, use the first available Judgment graphic
-- If that fails too, fail gracefully and do nothing
local mode = SL.Global.GameMode
if mode == 'Casual' then mode = 'Competitive' end -- copied out of PlayerOptions ...
local graphics = GetJudgmentGraphics(SL.Global.GameMode)
local wanted_graphics = mods.JudgmentGraphic
if not FindInTable(wanted_graphics, graphics) then
	wanted_graphics = graphics[1] or "None"
end

if wanted_graphics == "None" then return end

-- - - - - - - - - - - - - - - - - - - - - -

local TNSFrames = {
	TapNoteScore_W1 = 0,
	TapNoteScore_W2 = 1,
	TapNoteScore_W3 = 2,
	TapNoteScore_W4 = 3,
	TapNoteScore_W5 = 4,
	TapNoteScore_Miss = 5
}

local t = Def.ActorFrame {
	Name="Player Judgment",

	InitCommand=function(self)
		kids = self:GetChildren()
		JudgmentSet = kids.JudgmentWithOffsets
	end,

	JudgmentMessageCommand=function(self, param)
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

		-- this should match the custom JudgmentTween() from SL for 3.95
		JudgmentSet:zoom(0.8):decelerate(0.1):zoom(0.75):sleep(0.6):accelerate(0.2):zoom(0)
	end,

	Def.Sprite{
		Name="JudgmentWithOffsets",
		InitCommand=function(self)

			self:pause():visible(false)

			-- if we are on ScreenEdit, judgment graphic is always "Love"
			-- because ScreenEdit is a mess and not worth bothering with.
			if string.match(tostring(SCREENMAN:GetTopScreen()), "ScreenEdit") then
				self:Load( THEME:GetPathG("", "_judgments/Competitive/Love") )

			else
				self:Load( THEME:GetPathG("", "_judgments/" .. mode .. "/" .. wanted_graphics) )
			end

		end,
		ResetCommand=cmd(finishtweening; stopeffect; visible,false)
	}
}

return t
