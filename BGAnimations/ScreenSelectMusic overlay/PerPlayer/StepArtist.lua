local player = ...
local pn = ToEnumShortString(player)
local p = PlayerNumber:Reverse()[player]

return Def.ActorFrame{
	Name="StepArtistAF_" .. pn,
	InitCommand=cmd(draworder,1),

	-- song and course changes
	OnCommand=cmd(queuecommand, "StepsHaveChanged"),
	CurrentSongChangedMessageCommand=cmd(queuecommand, "StepsHaveChanged"),
	CurrentCourseChangedMessageCommand=cmd(queuecommand, "StepsHaveChanged"),

	PlayerJoinedMessageCommand=function(self, params)
		if params.Player == player then
			self:queuecommand("Appear" .. pn)
		end
	end,
	PlayerUnjoinedMessageCommand=function(self, params)
		if params.Player == player then
			self:ease(0.5, 275):addy(scale(p,0,1,1,-1) * 30):diffusealpha(0)
		end
	end,

	-- depending on the value of pn, this will either become
	-- an AppearP1Command or an AppearP2Command when the screen initializes
	["Appear"..pn.."Command"]=function(self) self:visible(true):zoomy(0):sleep(0.2):accelerate(0.2):zoomy(1):decelerate(0.2):zoomy(0.6):accelerate(0.1):zoomy(1) end,

	InitCommand=function(self)
		self:visible( false ):halign( p )

		if player == PLAYER_1 then

			self:y(_screen.cy + 15)
			self:x( _screen.cx - (IsUsingWideScreen() and 356 or 320))

		elseif player == PLAYER_2 then

			self:y(_screen.cy + 126)
			self:x( _screen.cx - (IsUsingWideScreen() and 210 or 183))
		end

		if GAMESTATE:IsHumanPlayer(player) then
			self:queuecommand("Appear" .. pn)
		end
	end,

	-- colored background
	Def.ActorFrame{
			InitCommand=function(self)
				self:x(86)
				if player == PLAYER_1 then
					self:rotationx(180)
					self:y(1.5)
				elseif player == PLAYER_2 then
					self:rotationy(180)
					self:y(-1.5)
				end
		end,
			LoadActor("stepartistbubble")..{
				InitCommand=cmd(zoomto, 175, _screen.h/15; diffuse, DifficultyIndexColor(1) ),
				StepsHaveChangedCommand=function(self)
					local StepsOrTrail = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player) or GAMESTATE:GetCurrentSteps(player)

					if StepsOrTrail then
						local difficulty = StepsOrTrail:GetDifficulty()
						self:diffuse( DifficultyColor(difficulty) )
					else
						self:diffuse( PlayerColor(player) )
					end
				end
			},
	},

	--STEPS label
	Def.BitmapText{
		Font="_miso",
		OnCommand=function(self)
				self:diffuse(0,0,0,1)
				self:horizalign(left)
				self:settext(THEME:GetString("ScreenSelectMusic", "STEPS"))
				self:maxwidth(40)
				if player == PLAYER_1 then
					self:x(3)
					self:y(-3)
				elseif player == PLAYER_2 then
					self:x(130)
					self:y(2)
				end
			end
	},

	--stepartist text
	Def.BitmapText{
		Font="_miso",
		InitCommand=function(self)
			self:diffuse(color("#1e282f"))
			self:maxwidth(122)
				if player == PLAYER_1 then
					self:horizalign(left)
					self:x(46)
					self:y(-3)
				elseif player == PLAYER_2 then
					self:horizalign(right)
					self:x(126)
					self:y(2)
				end
				self:queuecommand('LoopC')
		end,
		LoopCCommand=function(self)
			if GAMESTATE:IsCourseMode() then
				self:diffusealpha(1)
			else
				self:diffusealpha(1)
				self:sleep(2)
				self:diffusealpha(0)
				self:sleep(4)
				self:queuecommand('LoopC')
			end
		end,
		StepsHaveChangedCommand=function(self)

			local SongOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong()
			local StepsOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSteps(player)

			-- if we're hovering over a group title, clear the stepartist text
			if not SongOrCourse then
				self:settext("")
			elseif StepsOrCourse then

				local stepartist = GAMESTATE:IsCourseMode() and StepsOrCourse:GetScripter() or StepsOrCourse:GetAuthorCredit()
				self:settext(stepartist or ""):diffuse( color("#1e282f") )

				for i=1, stepartist:utf8len() do
					if stepartist:utf8sub(i,i):byte() >= 240 then
						self:AddAttribute(i-1, { Length=1, Diffuse={1,1,1,1} } )
					end
				end
			end
		end,
		OffCommand=function(self)
			self:stoptweening()
		end,
	},

	--Steps Discription Text
	Def.BitmapText{
		Font="_miso",
		InitCommand=function(self)
			self:diffusealpha(0)
			self:diffuse(color("#1e282f"))
			self:maxwidth(122)
				if player == PLAYER_1 then
					self:horizalign(left)
					self:x(46)
					self:y(-3)
				elseif player == PLAYER_2 then
					self:horizalign(right)
					self:x(126)
					self:y(2)
				end
			self:queuecommand('LoopD')
		end,
		LoopDCommand=function(self)
			self:diffusealpha(0)
			self:sleep(2)
			self:diffusealpha(1)
			self:sleep(2)
			self:diffusealpha(0)
			self:sleep(2)
			self:queuecommand('LoopD')
		end,
		StepsHaveChangedCommand=function(self)

			local SongOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong()
			local StepsOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSteps(player)

			if not SongOrCourse then
				self:settext("")
			elseif StepsOrCourse then

				local stepartist = GAMESTATE:IsCourseMode() and StepsOrCourse:GetScripter() or StepsOrCourse:GetAuthorCredit()
				local Description = GAMESTATE:GetCurrentSteps(player):GetDescription()

				--If there is no Description tag filled out, we want to show the Credit tag by default so that the marquee doesn't have blanks in it.
				--(the vast majority of .ssc files only fill out the credit tag and leave Description and ChartName blank).
				--This is a great way to create the illusion that the credit text scrolls the available values but only shows stepartist when only that is available.
					if
						GAMESTATE:GetCurrentSteps(player):GetDescription() == ""
					then
						self:settext(stepartist and stepartist or "")
						self:diffuse( color("#1e282f") )
						for i=1, stepartist:utf8len() do
							if stepartist:utf8sub(i,i):byte() >= 240 then
								self:AddAttribute(i-1, { Length=1, Diffuse={1,1,1,1} } )
							end
						end
					else
						self:settext(Description)
						self:diffuse( color("#1e282f") )
						for i=1, Description:utf8len() do
							if Description:utf8sub(i,i):byte() >= 240 then
								self:AddAttribute(i-1, { Length=1, Diffuse={1,1,1,1} } )
							end
						end
					end
			end
		end,
		OffCommand=function(self)
			self:stoptweening()
		end
	},

	--Steps ChartName Text
	Def.BitmapText{
		Font="_miso",
		InitCommand=function(self)
			self:diffusealpha(0)
			self:diffuse(color("#1e282f"))
			self:maxwidth(122)
				if player == PLAYER_1 then
					self:horizalign(left)
					self:x(46)
					self:y(-3)
				elseif player == PLAYER_2 then
					self:horizalign(right)
					self:x(126)
					self:y(2)
				end
			self:queuecommand('LoopN')
		end,
		LoopNCommand=function(self)
			self:diffusealpha(0)
			self:sleep(4)
			self:diffusealpha(1)
			self:sleep(2)
			self:diffusealpha(0)
			self:queuecommand('LoopN')
		end,
		StepsHaveChangedCommand=function(self)

			local SongOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong()
			local StepsOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSteps(player)

			if not SongOrCourse then
				self:settext("")
			elseif StepsOrCourse then

				local stepartist = GAMESTATE:IsCourseMode() and StepsOrCourse:GetScripter() or StepsOrCourse:GetAuthorCredit()
				local ChartName = GAMESTATE:GetCurrentSteps(player):GetChartName()
				if
					GAMESTATE:GetCurrentSteps(player):GetChartName() == ""
				then
						self:settext(stepartist and stepartist or "")
						self:diffuse( color("#1e282f") )
						for i=1, stepartist:utf8len() do
							if stepartist:utf8sub(i,i):byte() >= 240 then
								self:AddAttribute(i-1, { Length=1, Diffuse={1,1,1,1} } )
							end
						end
				else
					self:settext(ChartName)
					self:diffuse( color("#1e282f") )
					for i=1, ChartName:utf8len() do
						if ChartName:utf8sub(i,i):byte() >= 240 then
							self:AddAttribute(i-1, { Length=1, Diffuse={1,1,1,1} } )
						end
					end
				end
			end
		end,
		OffCommand=function(self)
			self:stoptweening()
		end
	},
}
