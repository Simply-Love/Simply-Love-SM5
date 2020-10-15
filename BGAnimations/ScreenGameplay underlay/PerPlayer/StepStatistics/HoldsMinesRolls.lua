local player = ...

local IsUltraWide = (GetScreenAspectRatio() > 21/9)
local NoteFieldIsCentered = (GetNotefieldX(player) == _screen.cx)

local RadarCategories = { 'Holds', 'Mines', 'Rolls' }
local RCJudgments = { Holds=0, Mines=0, Rolls=0 }

local row_height = 28

-- -----------------------------------------------------------------------

local af = Def.ActorFrame{}
af.InitCommand=function(self)
	self:x(player==PLAYER_1 and 155 or -85)
	self:y(-124)

	if NoteFieldIsCentered and IsUsingWideScreen() then
		self:x( player==PLAYER_1 and 155 or -88 )
	end

	-- adjust for smaller panes when ultrawide and both players joined
	if IsUltraWide and #GAMESTATE:GetHumanPlayers() > 1 then
		self:x( player==PLAYER_1 and 14 or 50 )
	end
end


-- then handle holds, mines, hands, rolls
for index, RCType in ipairs(RadarCategories) do

	-- player performance value
	af[#af+1] = LoadFont("Wendy/_ScreenEvaluation numbers")..{
		Text="000",
		InitCommand=function(self)
			self:zoom(0.4)
			self:halign(PlayerNumber:Reverse()[OtherPlayer[player]])
			self:x( 0 )
			self:y((index-1)*row_height - 22)
		end,
		BeginCommand=function(self)
			leadingZeroAttr = { Length=2, Diffuse=color("#5A6166") }
			self:AddAttribute(0, leadingZeroAttr )
		end,
		JudgmentMessageCommand=function(self, params)
			if params.Player ~= player then return end
			if not params.TapNoteScore then return end

			if RCType=="Mines" and params.TapNoteScore == "TapNoteScore_AvoidMine" then
				RCJudgments.Mines = RCJudgments.Mines + 1
				self:settext( string.format("%03d", RCJudgments.Mines) )

			elseif RCType=="Holds" and params.TapNote and params.TapNote:GetTapNoteSubType() == "TapNoteSubType_Hold" then
				RCJudgments.Holds = RCJudgments.Holds + 1
				self:settext( string.format("%03d", RCJudgments.Holds) )

			elseif RCType=="Rolls" and params.TapNote and params.TapNote:GetTapNoteSubType() == "TapNoteSubType_Roll" then
				RCJudgments.Rolls = RCJudgments.Rolls + 1
				self:settext( string.format("%03d", RCJudgments.Rolls) )
			end

			leadingZeroAttr = { Length=(3-tonumber(tostring(RCJudgments[RCType]):len())), Diffuse=color("#5A6166") }
			self:AddAttribute(0, leadingZeroAttr )
		end
	}

	--  slash
	af[#af+1] = LoadFont("Common Normal")..{
		Text="/",
		InitCommand=function(self)
			self:diffuse(color("#5A6166")):zoom(1.25)
			self:halign(PlayerNumber:Reverse()[OtherPlayer[player]])
			self:x( 45 * (player==PLAYER_1 and -1 or 1) )
			self:y((index-1)*row_height - 22)
		end
	}

	-- possible value
	af[#af+1] = LoadFont("Wendy/_ScreenEvaluation numbers")..{
		InitCommand=function(self)
			self:zoom(0.4)
			self:halign(PlayerNumber:Reverse()[player])
			self:x( 100 * (player==PLAYER_1 and -1 or 1) )
			self:y((index-1)*row_height - 22)
		end,
		BeginCommand=function(self)

			possible = 0
			StepsOrTrail = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)

			if StepsOrTrail then
				rv = StepsOrTrail:GetRadarValues(OtherPlayer[player])
				possible = rv:GetValue( RCType )
				-- non-static courses (for example, "Most Played 1-4") will return -1 here
				if possible < 0 then possible = 0 end
			end

			self:settext( string.format("%03d", possible) )
			local leadingZeroAttr = { Length=3-tonumber(tostring(possible):len()); Diffuse=color("#5A6166") }
			self:AddAttribute(0, leadingZeroAttr )
		end
	}
end

-- labels: holds, mines, rolls
for i, label in ipairs(RadarCategories) do
	af[#af+1] = LoadFont("Common Normal")..{
		Text=THEME:GetString("ScreenEvaluation",label),
		InitCommand=function(self)
			self:zoom(0.833)
			self:x( player==PLAYER_1 and -110 or -10 )
			self:y((i-1)*row_height - 18)
			self:horizalign( right )
		end
	}
end

return af