DDSortMenuCursorPosition = 1
IsSortMenuInputToggled = false

local function GetMaxCursorPosition()
	local curSong = GAMESTATE:GetCurrentSong()
	local SongIsSelected
	
	if curSong then 
		SongIsSelected = true
	else
		SongIsSelected = false
	end
	
	-- the minimum amount of items
	local MaxCursorPosition = 10
	
	if GAMESTATE:GetCurrentStyle():GetStyleType() ~= 'StyleType_TwoPlayersTwoSides' then
		MaxCursorPosition = MaxCursorPosition + 1
	end
	
	return tonumber(MaxCursorPosition)
end

local t = Def.ActorFrame{
	Name="MenuCursor",
	InitCommand=function(self)
		self:draworder(106)
	end,

	Def.Quad{
		Name="Cursor",
		InitCommand=function(self)
			self:xy(SCREEN_CENTER_X + 145,SCREEN_CENTER_Y - 135)
			self:diffuse(color("#FFFFFF"))
			self:zoomx(190)
			self:zoomy(20)
			self:diffusealpha(0.5)
			self:horizalign(right)
			self:visible(true)
			self:queuecommand("FadeOut")
		end,
		
		InitializeDDSortMenuMessageCommand=function(self)
			self:stoptweening()
			self:xy(SCREEN_CENTER_X + 145,SCREEN_CENTER_Y - 135)
			self:diffuse(color("#FFFFFF"))
			self:zoomx(190)
			self:zoomy(20)
			self:diffusealpha(0.5)
			self:horizalign(right)
			self:visible(true)
			self:queuecommand("FadeOut")
			DDSortMenuCursorPosition = 1
		end,
		
		FadeInCommand=function(self)
			self:stoptweening()
			self:linear(0.7):diffusealpha(0.5)
			self:queuecommand("FadeOut")
		end,
		
		FadeOutCommand=function(self)
			self:stoptweening()
			self:linear(0.7):diffusealpha(0.2)
			self:queuecommand("FadeIn")
		end,
		
		UpdateCursorColorMessageCommand=function(self)
			if IsSortMenuInputToggled == true then
				self:stoptweening()
				self:diffusealpha(0.5)
				self:diffuse(color("#FFFFFF")):diffusealpha(0.2)
				self:queuecommand("FadeOut")
			else
				self:diffuse(color("#59ff85")):diffusealpha(0.2)
				self:queuecommand("FadeOut")
			end
		end,
		
		------------ I'm so sorry, this is garbage mama ------------
		
		ToggleSortMenuMovementMessageCommand=function(self)
			if IsSortMenuInputToggled == false then
				IsSortMenuInputToggled = true
			else
				IsSortMenuInputToggled = false
			end
		end,
		
		
		-- Wraps the cursor if it gets to the top or bottom and stops it
		-- if selected an option that needs to navigate left/right to select.
			MoveCursorLeftMessageCommand=function(self)
				if IsSortMenuInputToggled == false then
					if DDSortMenuCursorPosition == 1 then
						DDSortMenuCursorPosition = GetMaxCursorPosition()
						self:playcommand("UpdateCursor")
					else
						DDSortMenuCursorPosition = DDSortMenuCursorPosition - 1
						self:playcommand("UpdateCursor")
					end
				else end
			end,
				
			MoveCursorRightMessageCommand=function(self)
				if IsSortMenuInputToggled == false then
					if DDSortMenuCursorPosition == GetMaxCursorPosition() then
						DDSortMenuCursorPosition = 1
						self:playcommand("UpdateCursor")
					else
						DDSortMenuCursorPosition = DDSortMenuCursorPosition + 1
						self:playcommand("UpdateCursor")
					end
				else end
			end,
			
		---- This is telling the cursor where to go for each movement.
		UpdateCursorCommand=function(self)
			self:stoptweening()
			self:decelerate(0.2)
			-- Main sort
			if DDSortMenuCursorPosition == 1 then
				self:xy(SCREEN_CENTER_X + 145,SCREEN_CENTER_Y - 135)
				self:zoomx(190)
			-- Lower Difficulty filter
			elseif DDSortMenuCursorPosition == 2 then
				self:zoomx(40)
				self:xy(SCREEN_CENTER_X + 55,SCREEN_CENTER_Y - 110)
			-- Upper Difficulty filter
			elseif DDSortMenuCursorPosition == 3 then
				self:zoomx(40)
				self:xy(SCREEN_CENTER_X + 135,SCREEN_CENTER_Y - 110)
			-- Lower Bpm Filter
			elseif DDSortMenuCursorPosition == 4 then
				self:zoomx(40)
				self:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y - 85)
			-- Upper Bpm Filter
			elseif DDSortMenuCursorPosition == 5 then
				self:zoomx(40)
				self:xy(SCREEN_CENTER_X + 80,SCREEN_CENTER_Y - 85)
			-- Lower Length Filter
			elseif DDSortMenuCursorPosition == 6 then
				self:zoomx(65)
				self:xy(SCREEN_CENTER_X + 48.5,SCREEN_CENTER_Y - 60)
			-- Upper Length Filter
			elseif DDSortMenuCursorPosition == 7 then
				self:zoomx(65)
				self:xy(SCREEN_CENTER_X + 147.5,SCREEN_CENTER_Y - 60)
			-- Reset sorts
			elseif DDSortMenuCursorPosition == 8 then
				self:zoomx(170)
				self:xy(SCREEN_CENTER_X + 85,SCREEN_CENTER_Y - 20)
				
			-- Switch between Song/Course select
			elseif DDSortMenuCursorPosition == 9 then
				self:zoomx(170)
				self:xy(SCREEN_CENTER_X + 85,SCREEN_CENTER_Y + 5)
				
			-- Song Search or Switch from single/double
			elseif DDSortMenuCursorPosition == 10 then
				self:zoomx(170)
				self:xy(SCREEN_CENTER_X + 85,SCREEN_CENTER_Y + 30)
			-- Switch from single/double or test input
			elseif DDSortMenuCursorPosition == 11 then
				self:zoomx(170)
				self:xy(SCREEN_CENTER_X + 85,SCREEN_CENTER_Y + 55)
			end
			self:queuecommand("FadeOut")
			
		end,
	},
	
}

return t