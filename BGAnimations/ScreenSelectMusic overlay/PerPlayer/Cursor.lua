-- the difficulty grid and per-player bouncing cursors don't support CourseMode
-- CourseContentsList.lua should be used instead
if GAMESTATE:IsCourseMode() then return end
-- ----------------------------------------------

local player = ...
local pn = ToEnumShortString(player)
local p = PlayerNumber:Reverse()[player]

local GetStepsToDisplay = LoadActor("../StepsDisplayList/StepsToDisplay.lua")
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

	PlayerJoinedMessageCommand=function(self, params)
		if params.Player == player then self:visible(true) end
	end,
	PlayerUnjoinedMessageCommand=function(self, params)
		if params.Player == player then self:visible(false) end
	end,

	OnCommand=function(self) self:queuecommand("Set") end,
	CurrentSongChangedMessageCommand=function(self) self:queuecommand("Set") end,
	CurrentStepsP1ChangedMessageCommand=function(self) self:queuecommand("Set") end,
	CurrentStepsP2ChangedMessageCommand=function(self) self:queuecommand("Set") end,

	SetCommand=function(self)
		local song = GAMESTATE:GetCurrentSong()

		if song then
			local playable_steps = SongUtil.GetPlayableSteps( song )
			local current_steps = GAMESTATE:GetCurrentSteps(player)

			for i,chart in pairs( GetStepsToDisplay(playable_steps) ) do
				if chart == current_steps then
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
}
