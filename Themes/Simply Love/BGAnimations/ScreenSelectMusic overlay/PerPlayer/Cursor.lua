local player = ...
local pn = ToEnumShortString(player)
local p = PlayerNumber:Reverse()[player]

-- I feel like this surely must be the wrong way to do this...
local GlobalOffsetSeconds = PREFSMAN:GetPreference("GlobalOffsetSeconds")

local RowIndex = 1

return Def.Sprite{
	Texture=THEME:GetPathB("ScreenSelectMusic", "overlay/PerPlayer/arrow.png"),
	Name="Cursor"..pn,
	InitCommand=function(self)
		self:visible( false ):halign( p )

		self:zoom(0.575)
		self:bounce():effectclock("beatnooffset")

		if player == PLAYER_1 then
			self:x( IsUsingWideScreen() and _screen.cx-330 or 0)
			self:effectmagnitude(-3,0,0)

		elseif player == PLAYER_2 then
			self:rotationz(180)
			self:x(IsUsingWideScreen() and _screen.cx-28 or 276)
			self:effectmagnitude(3,0,0)
		end

		self:effectperiod(1):effectoffset( -10 * GlobalOffsetSeconds)

		if GAMESTATE:IsHumanPlayer(player) then
			self:playcommand( "Appear" .. pn)
		end
	end,

	OnCommand=cmd(queuecommand,"Set"),
	CurrentSongChangedMessageCommand=cmd(queuecommand,"Set"),
	CurrentCourseChangedMessageCommand=cmd(queuecommand,"Set"),

	CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set"),
	CurrentTrailP1ChangedMessageCommand=cmd(queuecommand,"Set"),
	CurrentStepsP2ChangedMessageCommand=cmd(queuecommand,"Set"),
	CurrentTrailP2ChangedMessageCommand=cmd(queuecommand,"Set"),

	SetCommand=function(self)
		local song = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse()) or GAMESTATE:GetCurrentSong()

		if song then
			steps = (GAMESTATE:IsCourseMode() and song:GetAllTrails()) or SongUtil.GetPlayableSteps( song )

			if steps then
				StepsToDisplay = GetStepsToDisplay(steps)
				self:playcommand("StepsHaveChanged", {Steps=StepsToDisplay, Player=player})
			end
		end
	end,


	PlayerJoinedMessageCommand=function(self, params)
		if params.Player == player then
			self:playcommand( "Appear" .. pn)
		end
	end,
	PlayerUnjoinedMessageCommand=function(self, params)
		if params.Player == player then
			self:visible(false)
		end
	end,

	["Appear" .. pn .. "Command"]=function(self) self:visible(true) end,

	StepsHaveChangedCommand=function(self, params)

		if params and params.Player == player then
			-- if we have params, but no steps
			-- it means we're on hovering on a group
			if not params.Steps then
				-- so, since we're on a group, no charts should be specifically available
				-- making any row on the grid temporarily able-to-be-moved-to
				RowIndex = RowIndex + params.Direction

			else
				-- otherwise, we have been passed steps
				for index,chart in pairs(params.Steps) do
					if GAMESTATE:IsCourseMode() then
						if chart == GAMESTATE:GetCurrentTrail(player) then
							RowIndex = index
							break
						end
					else
						if chart == GAMESTATE:GetCurrentSteps(player) then
							RowIndex = index
							break
						end
					end
				end
			end

			-- keep within reasonable limits
			if RowIndex > 5 then RowIndex = 5
			elseif RowIndex < 1 then RowIndex = 1
			end

			-- update cursor y position
			local sdl = self:GetParent():GetParent():GetChild("StepsDisplayList")
			if sdl then
				local grid = sdl:GetChild("Grid")
				self:y(sdl:GetY() + grid:GetY() + grid:GetChild("Blocks_"..RowIndex):GetY() + 1 )
			end
		end
	end
}
