local player = ...

local IsUltraWide = (GetScreenAspectRatio() > 21/9)
local NoteFieldIsCentered = (GetNotefieldX(player) == _screen.cx)

local possible, rv, pss
local StepsOrTrail = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)
local total_tapnotes = StepsOrTrail:GetRadarValues(player):GetValue( "RadarCategory_Notes" )

-- determine how many digits are needed to express the number of notes in base-10
local digits = (math.floor(math.log10(total_tapnotes)) + 1)
-- display a minimum 4 digits for aesthetic reasons
digits = math.max(4, digits)

-- generate a Lua string pattern that will be used to leftpad with 0s
local pattern = ("%%0%dd"):format(digits)


local TapNoteScores = { 'W1', 'W2', 'W3', 'W4', 'W5', 'Miss' }
local TapNoteJudgments = { W1=0, W2=0, W3=0, W4=0, W5=0, Miss=0 }
local RadarCategories = { 'Holds', 'Mines', 'Rolls' }
local RadarCategoryJudgments = { Holds=0, Mines=0, Rolls=0 }

local leadingZeroAttr
local row_height = 35

local t = Def.ActorFrame{
	Name="JudgmentNumbers",
	InitCommand=function(self)
		self:zoom(0.8)
	end
}

-- do "regular" TapNotes first
for index, window in ipairs(TapNoteScores) do

	-- player performance value
	t[#t+1] = LoadFont("Wendy/_ScreenEvaluation numbers")..{
		Text=(pattern):format(0),
		InitCommand=function(self)
			self:zoom(0.5):horizalign(left)

			if SL.Global.ActiveModifiers.TimingWindows[index] or index==#TapNoteScores then
				self:diffuse( SL.JudgmentColors[SL.Global.GameMode][index] )
				leadingZeroAttr = { Length=(digits-1), Diffuse=Brightness(self:GetDiffuse(), 0.35) }
				self:AddAttribute(0, leadingZeroAttr )
			else
				self:diffuse(Brightness({1,1,1,1},0.25))
			end
		end,
		BeginCommand=function(self)
			self:x( 108 )
			self:y((index-1)*row_height - 282)

			-- horizontally squishing the numbers isn't pretty, but I'm not sure what else to do
			-- when people want to play "24 hours of 100 bpm stream" on a 16:9 display with Center1Player enabled  :(
			if (not IsUsingWideScreen() and digits > 5)
			or (NoteFieldIsCentered and digits > 4)
			then
				self:x(104):maxwidth(WideScale(140,185))
			end

			if IsUltraWide and (#GAMESTATE:GetHumanPlayers() > 1) and (digits > 4) then
				self:x(104):maxwidth(165)
			end
		end,
		JudgmentMessageCommand=function(self, params)
			if params.Player ~= player then return end
			if params.HoldNoteScore then return end

			if params.TapNoteScore and ToEnumShortString(params.TapNoteScore) == window then
				TapNoteJudgments[window] = TapNoteJudgments[window] + 1
				self:settext( (pattern):format(TapNoteJudgments[window]) )

				leadingZeroAttr = {
					Length=(digits - (math.floor(math.log10(TapNoteJudgments[window]))+1)),
					Diffuse=Brightness(SL.JudgmentColors[SL.Global.GameMode][index], 0.35)
				}
				self:AddAttribute(0, leadingZeroAttr )
			end
		end
	}

end

-- then handle holds, mines, hands, rolls
for index, RCType in ipairs(RadarCategories) do

	-- player performance value
	t[#t+1] = LoadFont("Wendy/_ScreenEvaluation numbers")..{
		Text="000",
		InitCommand=function(self) self:zoom(0.5):horizalign(right) end,
		BeginCommand=function(self)
			self:y((index-1)*row_height - 178)
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

			elseif RCType=="Holds" and params.TapNote and params.TapNote:GetTapNoteSubType() == "TapNoteSubType_Hold" then
				RadarCategoryJudgments.Holds = RadarCategoryJudgments.Holds + 1
				self:settext( string.format("%03d", RadarCategoryJudgments.Holds) )

			elseif RCType=="Rolls" and params.TapNote and params.TapNote:GetTapNoteSubType() == "TapNoteSubType_Roll" then
				RadarCategoryJudgments.Rolls = RadarCategoryJudgments.Rolls + 1
				self:settext( string.format("%03d", RadarCategoryJudgments.Rolls) )
			end

			leadingZeroAttr = { Length=(3-tonumber(tostring(RadarCategoryJudgments[RCType]):len())), Diffuse=color("#5A6166") }
			self:AddAttribute(0, leadingZeroAttr )
		end
	}

	--  slash
	t[#t+1] = LoadFont("Common Normal")..{
		Text="/",
		InitCommand=function(self) self:diffuse(color("#5A6166")):zoom(1.25):horizalign(right) end,
		BeginCommand=function(self)
			self:y((index-1)*row_height - 178)
			self:x(-40)
		end
	}

	-- possible value
	t[#t+1] = LoadFont("Wendy/_ScreenEvaluation numbers")..{
		InitCommand=function(self) self:zoom(0.5):horizalign(right) end,
		BeginCommand=function(self)

			possible = 0
			StepsOrTrail = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)

			if StepsOrTrail then
				rv = StepsOrTrail:GetRadarValues(player)
				possible = rv:GetValue( RCType )
				-- non-static courses (for example, "Most Played 1-4") will return -1 here
				if possible < 0 then possible = 0 end
			end

			self:y((index-1)*row_height - 178)
			self:x( 16 )
			self:settext( string.format("%03d", possible) )
			local leadingZeroAttr = { Length=3-tonumber(tostring(possible):len()); Diffuse=color("#5A6166") }
			self:AddAttribute(0, leadingZeroAttr )
		end
	}
end

return t