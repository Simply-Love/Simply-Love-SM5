local player = ...
local StepsOrTrail
local possible, rv, pss

local TapNoteScores = { 'W1', 'W2', 'W3', 'W4', 'W5', 'Miss' }
local TapNoteJudgments = { W1=0, W2=0, W3=0, W4=0, W5=0, Miss=0 }
local RadarCategories = { 'Holds', 'Mines', 'Rolls' }
local RadarCategoryJudgments = { Holds=0, Mines=0, Rolls=0 }

local leadingZeroAttr

local t = Def.ActorFrame{
	InitCommand=function(self)
		self:zoom(0.8)
	end
}

-- do "regular" TapNotes first
for index, window in ipairs(TapNoteScores) do

	-- player performance value
	t[#t+1] = Def.BitmapText{
		Font="_ScreenEvaluation numbers",
		Text="0000",
		InitCommand=function(self)
			self:zoom(0.5):horizalign(right)
			if index <= SL.Global.ActiveModifiers.WorstTimingWindow or index==#TapNoteScores then
				self:diffuse( SL.JudgmentColors[SL.Global.GameMode][index] )
				leadingZeroAttr = { Length=3, Diffuse=Brightness(self:GetDiffuse(), 0.35) }
				self:AddAttribute(0, leadingZeroAttr )
			else
				self:diffuse(Brightness({1,1,1,1},0.25))
			end
		end,
		BeginCommand=function(self)
			self:x( 180 )
			self:y((index-1)*35 - 282)
		end,
		JudgmentMessageCommand=function(self, params)
			if params.Player ~= player then return end
			if params.HoldNoteScore then return end

			if params.TapNoteScore and ToEnumShortString(params.TapNoteScore) == window then
				TapNoteJudgments[window] = TapNoteJudgments[window] + 1
				self:settext( string.format("%04d", TapNoteJudgments[window]) )

				leadingZeroAttr = { Length=(4-tonumber(tostring(TapNoteJudgments[window]):len())), Diffuse=Brightness(SL.JudgmentColors[SL.Global.GameMode][index], 0.5) }
				self:AddAttribute(0, leadingZeroAttr )
			end
		end
	}

end

-- then handle holds, mines, hands, rolls
for index, RCType in ipairs(RadarCategories) do

	-- player performance value
	t[#t+1] = LoadFont("_ScreenEvaluation numbers")..{
		Text="000",
		InitCommand=cmd(zoom,0.5; horizalign, right),
		BeginCommand=function(self)
			self:y((index-1)*35 - 178)
			self:x( -54 )

			leadingZeroAttr = { Length=2, Diffuse=color("#5A6166") }
			self:AddAttribute(0, leadingZeroAttr )
		end,
		JudgmentMessageCommand=function(self, params)
			if params.Player ~= player then return end
			if not params.TapNoteScore then return end

			if RCType=="Mines" and params.TapNoteScore == "TapNoteScore_AvoidMine" then
				RadarCategoryJudgments.Mines = RadarCategoryJudgments.Mines + 1
				self:settext( string.format("%03d", RadarCategoryJudgments.Mines) )
			end

			if RCType=="Holds" and params.TapNote and params.TapNote:GetTapNoteSubType() == "TapNoteSubType_Hold" then
				RadarCategoryJudgments.Holds = RadarCategoryJudgments.Holds + 1
				self:settext( string.format("%03d", RadarCategoryJudgments.Holds) )
			end

			if RCType=="Rolls" and params.TapNote and params.TapNote:GetTapNoteSubType() == "TapNoteSubType_Roll" then
				RadarCategoryJudgments.Rolls = RadarCategoryJudgments.Rolls + 1
				self:settext( string.format("%03d", RadarCategoryJudgments.Rolls) )
			end

			leadingZeroAttr = { Length=(3-tonumber(tostring(RadarCategoryJudgments[RCType]):len())), Diffuse=color("#5A6166") }
			self:AddAttribute(0, leadingZeroAttr )
		end
	}

	--  slash
	t[#t+1] = LoadFont("_miso")..{
		Text="/",
		InitCommand=cmd(diffuse,color("#5A6166"); zoom, 1.25; horizalign, right),
		BeginCommand=function(self)
			self:y((index-1)*35 - 178)
			self:x(-40)
		end
	}

	-- possible value
	t[#t+1] = LoadFont("_ScreenEvaluation numbers")..{
		InitCommand=cmd(zoom,0.5; horizalign, right),
		BeginCommand=function(self)

			StepsOrTrail = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)
			if StepsOrTrail then
				rv = StepsOrTrail:GetRadarValues(player)
				possible = rv:GetValue( RCType )
			else
				possible = 0
			end

			self:y((index-1)*35 - 178)
			self:x( 16 )
			self:settext( string.format("%03d", possible) )
			local leadingZeroAttr = { Length=3-tonumber(tostring(possible):len()); Diffuse=color("#5A6166") }
			self:AddAttribute(0, leadingZeroAttr )
		end
	}
end

return t