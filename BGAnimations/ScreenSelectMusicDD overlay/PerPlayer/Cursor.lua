local player = ...
local pn = ToEnumShortString(player)
local p = PlayerNumber:Reverse()[player]
local P1 = GAMESTATE:IsHumanPlayer(PLAYER_1)
local P2 = GAMESTATE:IsHumanPlayer(PLAYER_2)	

-- I feel like this surely must be the wrong way to do this...
local GlobalOffsetSeconds = PREFSMAN:GetPreference("GlobalOffsetSeconds")
local GetStepsToDisplay = LoadActor("../StepsDisplayList/StepsToDisplay.lua")

local RowIndex = 1

if GAMESTATE:IsCourseMode() then
return Def.ActorFrame { }
end

return Def.Sprite{
	Texture=THEME:GetPathB("ScreenSelectMusicDD","overlay/PerPlayer/highlight.png"),
	Name="Cursor"..pn,
	InitCommand=function(self)
	
		self:visible( false ):halign( p )

		self:zoom(IsUsingWideScreen() and WideScale(0.8,1) or 1)
		-- diffuse with white to make it less #OwMyEyes
		local color = PlayerColor(player)
		color[4] = 1
		color[1] = 0.8 * color[1] + 0.2
		color[2] = 0.8 * color[2] + 0.2
		color[3] = 0.8 * color[3] + 0.2
		self:diffuse(color)
		

		if player == PLAYER_1 then
			self:x( IsUsingWideScreen() and _screen.cx-330 or 0)
			self:y( IsUsingWideScreen() and WideScale(303,305.75) or 194)
			self:effectmagnitude(-6,0,6)
				if IsUsingWideScreen() then
				else
					self:align(-0.44,0.5)
				end

		elseif player == PLAYER_2 then
			self:y(IsUsingWideScreen()and WideScale(303,305.75) or 193)
			self:effectmagnitude(-6,0,6)
				if IsUsingWideScreen() then
					self:align(WideScale(-12.7,-12.21),0.49)
				else
					self:align(-0.44,0.48)
				end
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
	
	CloseThisFolderHasFocusMessageCommand=cmd(queuecommand,"Dissappear"),

	SetCommand=function(self)
		local song = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse()) or GAMESTATE:GetCurrentSong()
		if GAMESTATE:IsHumanPlayer(player) then
			self:playcommand( "Appear" .. pn)
		end
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
	DissappearCommand=function(self) self:visible(false) end,

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
				if IsUsingWideScreen() then
					self:x(WideScale(grid:GetChild("Blocks_"..RowIndex):GetY()/0.5 - 50,grid:GetChild("Blocks_"..RowIndex):GetY()/0.351 - 40))
				else
					self:x(grid:GetChild("Blocks_"..RowIndex):GetY()/0.351 - 40)
				end
			end
		end
	end
}
