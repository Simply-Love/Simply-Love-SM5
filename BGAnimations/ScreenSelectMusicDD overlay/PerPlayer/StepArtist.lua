local player = ...
local pn = ToEnumShortString(player)
local p = PlayerNumber:Reverse()[player]

local text_table, marquee_index
local nsj = GAMESTATE:GetNumSidesJoined()

if GAMESTATE:IsCourseMode() then
return end

return Def.ActorFrame{
	Name="StepArtistAF_" .. pn,

	-- song and course changes
	OnCommand=function(self) self:queuecommand("Reset") end,
	["CurrentSteps"..pn.."ChangedMessageCommand"]=function(self) self:queuecommand("Reset") end,
	CurrentSongChangedMessageCommand=function(self) self:queuecommand("Reset") end,
	CurrentCourseChangedMessageCommand=function(self) self:queuecommand("Reset") end,

	PlayerJoinedMessageCommand=function(self, params)
		if params.Player == player then
			self:queuecommand("Appear" .. pn)
		end
	end,

	-- Digital Dance doesn't support player unjoining (that I'm aware of!) but this
	-- animation is left here as a reminder to a future me to maybe look into it.
	PlayerUnjoinedMessageCommand=function(self, params)
		if params.Player == player then
			self:ease(0.5, 275):addy(scale(p,0,1,1,-1) * 30):diffusealpha(0)
		end
	end,

	-- depending on the value of pn, this will either become
	-- an AppearP1Command or an AppearP2Command when the screen initializes
	["Appear"..pn.."Command"]=function(self) self:visible(true):ease(0.5, 275):addy(scale(p,0,1,-1,1) * 30) end,

	InitCommand=function(self)
		self:visible( false ):halign( p )

		if player == PLAYER_1 then

			self:y(IsUsingWideScreen() and _screen.cy + 58 or _screen.cy + 14)
			self:x( _screen.cx - (IsUsingWideScreen() and 453 or 347))
			if not IsUsingWideScreen() then
				if nsj == 2 then
					self:y(353)
				end
			end
		elseif player == PLAYER_2 then
			self:y(_screen.cy - 2)
			self:x( _screen.cx - (IsUsingWideScreen() and WideScale(-29,-136) or 346))
			if not IsUsingWideScreen() then
				self:y(_screen.cy - 27)
				if nsj == 2 then
					self:y(293)
					self:x(_screen.cx - 25)
				elseif nsj == 1 then
					self:y(192)
				end
			end
		end

		if GAMESTATE:IsHumanPlayer(player) then
			self:queuecommand("Appear" .. pn)
		end
	end,

	-- colored background quad
	Def.Quad{
		Name="BackgroundQuad",
		InitCommand=function(self) 
			self:zoomto(IsUsingWideScreen() and WideScale(160,267) or 310, _screen.h/28)
			self:x(IsUsingWideScreen() and WideScale(212,158) or 181)
			if not IsUsingWideScreen() then
				if nsj == 2 and player == PLAYER_2 then
					self:zoomx(320)
					self:addx(4)
				end
			end
		end,
		ResetCommand=function(self)
			local StepsOrTrail = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player) or GAMESTATE:GetCurrentSteps(player)

			if StepsOrTrail then
				local difficulty = StepsOrTrail:GetDifficulty()
				self:diffuse( DifficultyColor(difficulty) )
			else
				self:diffuse( PlayerColor(player) )
			end
		end
	},

	--STEPS label
	LoadFont("Common Normal")..{
		Text=GAMESTATE:IsCourseMode() and Screen.String("SongNumber"):format(1),
		InitCommand=function(self)
			self
			:diffuse(0,0,0,1)
			:horizalign(left)
			:x(IsUsingWideScreen() and WideScale(130,28) or 30)
			:maxwidth(40)
			:zoom(0.9)
			if not GAMESTATE:IsCourseMode() then
				if GAMESTATE:GetCurrentStyle():GetStyleType() == 'StyleType_OnePlayerOneSide' or  GAMESTATE:GetCurrentStyle():GetStyleType() ==  'StyleType_TwoPlayersTwoSides' then
					self:settext("Single:")
				elseif GAMESTATE:GetCurrentStyle():GetStyleType() == 'StyleType_OnePlayerTwoSides' then
					self:settext("Double:")
				else
					self:settext("STEPS:")
				end
			
			end
		end,
		UpdateTrailTextMessageCommand=function(self, params)
			self:settext( THEME:GetString("ScreenSelectCourse", "SongNumber"):format(params.index) )
		end
	},

	--stepartist text
	LoadFont("Common Normal")..{
		InitCommand=function(self)
			self:diffuse(color("#1e282f")):horizalign(left)

			if GAMESTATE:IsCourseMode() then
				self:x(60):maxwidth(138)
			else
				self
				:x(IsUsingWideScreen() and WideScale(168,65) or 68)
				:maxwidth(IsUsingWideScreen() and WideScale(140,250) or 295)
				:zoom(0.9)
			end
		end,
		ResetCommand=function(self)

			local SongOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong()
			local StepsOrTrail = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player) or GAMESTATE:GetCurrentSteps(player)

			-- always stop tweening when steps change in case a MarqueeCommand is queued
			self:stoptweening()

			if SongOrCourse and StepsOrTrail then

				text_table = GetStepsCredit(player)
				marquee_index = 0

				-- don't queue a Marquee in CourseMode
				-- each TrailEntry text change will be broadcast from CourseContentsList.lua
				-- to ensure it stays synced with the scrolling list of songs
				if not GAMESTATE:IsCourseMode() then
					-- only queue a Marquee if there are things in the text_table to display
					if #text_table > 0 then
						self:queuecommand("Marquee")
					else
						-- no credit information was specified in the simfile for this stepchart, so just set to an empty string
						self:settext("")
					end
				end
			else
				-- there wasn't a song/course or a steps object, so the MusicWheel is probably hovering
				-- on a group title, which means we want to set the stepartist text to an empty string for now
				self:settext("")
			end
		end,
		MarqueeCommand=function(self)
			-- increment the marquee_index, and keep it in bounds
			marquee_index = (marquee_index % #text_table) + 1
			-- retrieve the text we want to display
			local text = text_table[marquee_index]

			-- set this BitmapText actor to display that text
			self:settext( text )

			-- check for emojis; they shouldn't be diffused to Color.Black
			DiffuseEmojis(self, text)

			if not GAMESTATE:IsCourseMode() then
				-- sleep 2 seconds before queueing the next Marquee command to do this again
				if #text_table > 1 then
					self:sleep(2):queuecommand("Marquee")
				end
			else
				self:sleep(0.5):queuecommand("m")
			end
		end,
		UpdateTrailTextMessageCommand=function(self, params)
			if text_table then
				self:settext( text_table[params.index] or "" )
			end
		end,
		OffCommand=function(self) self:stoptweening() end
	}
}