local player = ...
local pn = ToEnumShortString(player)
local p = PlayerNumber:Reverse()[player]

local text_table, marquee_index

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
	["Appear"..pn.."Command"]=function(self) self:visible(true):ease(0.5, 275):addy(scale(p,0,1,-1,1) * 30) end,

	InitCommand=function(self)
		self:visible( false ):halign( p )

		if player == PLAYER_1 then

			self:y(_screen.cy + 44)
			self:x( _screen.cx - (IsUsingWideScreen() and 356 or 346))

		elseif player == PLAYER_2 then

			self:y(_screen.cy + 97)
			self:x( _screen.cx - 210)
		end

		if GAMESTATE:IsHumanPlayer(player) then
			self:queuecommand("Appear" .. pn)
		end
	end,

	-- colored background quad
	Def.Quad{
		Name="BackgroundQuad",
		InitCommand=cmd(zoomto, 175, _screen.h/28; x, 113; diffuse, DifficultyIndexColor(1) ),
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

	--STEPS label
	Def.BitmapText{
		Font="_miso",
		OnCommand=cmd(diffuse, color("0,0,0,1"); horizalign, left; x, 30; settext, Screen.String("STEPS"))
	},

	--stepartist text
	Def.BitmapText{
		Font="_miso",
		InitCommand=cmd(diffuse,color("#1e282f"); horizalign, left; x, 75; maxwidth, 115),
		StepsHaveChangedCommand=function(self)

			local SongOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong()
			local StepsOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSteps(player)

			-- always stop tweening when steps change in case a MarqueeCommand is queued
			self:stoptweening()

			-- clear the stepartist text, in case we're hovering over a group title
			self:settext("")

			if SongOrCourse and StepsOrCourse then
				text_table = GetStepsCredit(player)
				marquee_index = 0

				-- only queue a marquee if there are things in the text_table to display
				if #text_table > 0 then self:queuecommand("Marquee") end
			end
		end,
		MarqueeCommand=function(self)
			-- increment the marquee_index, and keep it in bounds
			marquee_index = (marquee_index % #text_table) + 1
			-- retrieve the text we want to display
			local text = text_table[marquee_index]

			-- set this BitmapText actor to display that text
			self:settext( text )

			-- account for the possibility that emojis shouldn't be diffused to Color.Black
			for i=1, text:utf8len() do
				if text:utf8sub(i,i):byte() >= 240 then
					self:AddAttribute(i-1, { Length=1, Diffuse={1,1,1,1} } )
				end
			end

			-- sleep 2 seconds before queueing the next Marquee command to do this again
			self:sleep(2):queuecommand("Marquee")
		end,
		OffCommand=function(self) self:stoptweening() end
	}
}