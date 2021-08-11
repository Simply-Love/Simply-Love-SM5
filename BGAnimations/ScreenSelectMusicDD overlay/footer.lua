-- tables of rgba values
local light = {0.65,0.65,0.65,1}
local P1 = SCREEN_LEFT + 20
local P2 = SCREEN_RIGHT - 20
local nsj = GAMESTATE:GetNumSidesJoined()

return Def.ActorFrame{
	Def.Quad{
		Name="Footer",
		InitCommand=function(self)
			self:zoomto(_screen.w, 32)
			self:vertalign(bottom)
			self:y(SCREEN_BOTTOM)
			self:x(SCREEN_CENTER_X)
			self:diffuse(light)
		end,
		ScreenChangedMessageCommand=function(self)
		end
	},
	
	-- Text to warn the player that songs may be missing from the music wheel with their current filters. 
	-- Otherwise nothing here is necessary.
	LoadFont("Miso/_miso")..{
		Name="Filter_Warning",
		Text="",
		InitCommand=function(self)
			if IsUsingFilters() then
				self:settext("Filters Active!")
			else
				self:settext("")
			end
			self:draworder(102)
			self:zoom(0.95)
			self:y(SCREEN_BOTTOM - 16)
			if nsj == 1 then
				if GAMESTATE:IsPlayerEnabled(0) == true then
					self:x(P1)
					self:horizalign(left)
				else
					self:x(P2)
					self:horizalign(right)
				end
			elseif nsj == 2 then
				self:x(P1)
				self:horizalign(left)
			end
			self:diffuse(color("#780000"))
			self:diffusealpha(0)
		end,
		OnCommand=function(self)
			self:sleep(0.1):decelerate(0.33):diffusealpha(1)
		end,
	},
	
	-- Text to warn the player that songs may be missing from the music wheel with their current filters. 
	-- Otherwise nothing here is necessary.
	LoadFont("Miso/_miso")..{
		Name="Filter_Warning",
		Text="",
		InitCommand=function(self)
			if nsj == 2 then
				if IsUsingFilters() then
					self:settext("Filters Active!")
				else
					self:settext("")
				end
				self:draworder(102)
				self:zoom(0.95)
				self:y(SCREEN_BOTTOM - 16)
				self:x(P2)
				self:horizalign(right)
				self:diffuse(color("#780000"))
				self:diffusealpha(0)
			else 
			end
		end,
		OnCommand=function(self)
			self:sleep(0.1):decelerate(0.33):diffusealpha(1)
		end,
	},
	
}