local player = ...
local pn = ToEnumShortString(player)
local p = PlayerNumber:Reverse()[player]

local text_table, marquee_index

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

	-- Simply Love doesn't support player unjoining (that I'm aware of!) but this
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

			if GAMESTATE:IsCourseMode() then
				self:x( _screen.cx - (IsUsingWideScreen() and 356 or 346))
				self:y(_screen.cy + 32)
			else
				self:x( _screen.cx - (IsUsingWideScreen() and 356 or 346))
				self:y(_screen.cy + 12)
			end

		elseif player == PLAYER_2 then

			if GAMESTATE:IsCourseMode() then
				self:x( _screen.cx - 210)
				self:y(_screen.cy + 85)
			else
				self:x( _screen.cx - 244)
				self:y(_screen.cy + 40)
			end
		end

		if GAMESTATE:IsHumanPlayer(player) then
			self:queuecommand("Appear" .. pn)
		end
	end,

	-- colored background quad
	Def.Quad{
		Name="BackgroundQuad",
		InitCommand=function(self) self:zoomto(175, _screen.h/28):x(113):diffuse(color("#000000")) end,
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
		Text=GAMESTATE:IsCourseMode() and Screen.String("SongNumber"):format(1) or Screen.String("STEPS"),
		InitCommand=function(self)
			self:diffuse(0,0,0,1):horizalign(left):x(30):maxwidth(40):zoom(0.8)
		end,
		UpdateTrailTextMessageCommand=function(self, params)
			self:settext( THEME:GetString("ScreenSelectCourse", "SongNumber"):format(params.index) )
		end
	},

	--stepartist text
	LoadFont("Common Normal")..{
		InitCommand=function(self)
			self:diffuse(color("#1e282f")):horizalign(left):zoom(0.8)

			if GAMESTATE:IsCourseMode() then
				self:x(60):maxwidth(138)
			else
				self:x(75):maxwidth(124):diffuse(color("#000000"))
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