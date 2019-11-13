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
		self:visible( GAMESTATE:IsHumanPlayer(player) )
		self:halign( p )

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
	end,

	OnCommand=function(self) self:queuecommand("Set") end,
	CurrentSongChangedMessageCommand=function(self) self:queuecommand("Set") end,
	CurrentCourseChangedMessageCommand=function(self) self:queuecommand("Set") end,

	CurrentStepsP1ChangedMessageCommand=function(self) self:queuecommand("Set") end,
	CurrentTrailP1ChangedMessageCommand=function(self) self:queuecommand("Set") end,
	CurrentStepsP2ChangedMessageCommand=function(self) self:queuecommand("Set") end,
	CurrentTrailP2ChangedMessageCommand=function(self) self:queuecommand("Set") end,

	SetCommand=function(self)
		local SongOrCourse = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse()) or GAMESTATE:GetCurrentSong()

		if SongOrCourse then
			local StepsOrTrail = (GAMESTATE:IsCourseMode() and SongOrCourse:GetAllTrails()) or SongUtil.GetPlayableSteps( SongOrCourse )

			if StepsOrTrail then
				self:playcommand("StepsHaveChanged", {Steps=GetStepsToDisplay(StepsOrTrail), Player=player})
			end
		end
	end,

	PlayerJoinedMessageCommand=function(self, params)
		if params.Player == player then self:visible(true) end
	end,
	PlayerUnjoinedMessageCommand=function(self, params)
		if params.Player == player then self:visible(false) end
	end,

	StepsHaveChangedCommand=function(self, params)

		if params and params.Player == player then
			-- if we have params, but no steps
			-- it means we're on hovering on a group
			if not params.Steps then
				-- so, since we're on a group, no charts should be specifically available
				-- making any row on the grid temporarily able-to-be-moved-to
				RowIndex = RowIndex + params.Direction

			else
				local StepsOrTrail = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player) or GAMESTATE:GetCurrentSteps(player)

				-- otherwise, we have been passed steps
				for i,chart in pairs(params.Steps) do
					if chart == StepsOrTrail then
						RowIndex = i
						break
					end
				end
			end

			-- keep within reasonable limits because Edit charts are a thing
			RowIndex = clamp(RowIndex, 1, 5)

			-- update cursor y position
			local sdl = self:GetParent():GetParent():GetChild("StepsDisplayList")
			if sdl then
				local grid = sdl:GetChild("Grid")
				self:y(sdl:GetY() + grid:GetY() + grid:GetChild("Blocks_"..RowIndex):GetY() + 1 )
			end
		end
	end
}
