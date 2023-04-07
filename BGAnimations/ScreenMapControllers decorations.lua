local headerHeight = 50

-- we'll figure out how many rows (that is, how many mappable buttons) there are
-- after the screen has initialized and we can get the scroller via SCREENMAN
local num_buttons
-- same with scroller_y; define to be 0 for now
local scroller_y = 0
-- I don't quite know where this is defined (Metrics somewhere?  Source code?), so I'm left hardcoding it for now
local first_row_y = 66

local af = Def.ActorFrame{
	-- a Quad to move around the screen as the focus of the scroller changes
	Def.Quad{
		InitCommand=function(self) self:zoomto(74,20):diffuse(1,0,0,0.5):xy(157, first_row_y) end,

		-- I'm having MapControllersFocusChanged and MapControllersFocusLost broadcast
		-- via MESSAGEMAN in Metrics.ini in the [ScreenMapControllers] section.
		MapControllersFocusChangedMessageCommand=function(self, params)
			local y = first_row_y

			-- As the player moves down the list of buttons, all the rows move in unison for a while
			-- so that the item with focus remains near the top.
			-- As the end of the list approaches, the rows stop moving.
			-- We want our Quad to do the opposite so that it stays with the y of the currently active BitmapText.
			if num_buttons and params.bmt:GetParent().ItemIndex > num_buttons-10 then
				y = (params.bmt:GetParent().ItemIndex - (num_buttons-10)) * 24 + scroller_y
			end

			local x = params.bmt:GetX()
			self:visible(true):xy(x,y)
		end,
		MapControllersFocusLostMessageCommand=function(self)
			self:visible(false)
		end
	},

	Def.ActorProxy{
		Name="Scroller",
		OnCommand=function(self)
			local scroller = SCREENMAN:GetTopScreen():GetChild("LineScroller")
			self:SetTarget(scroller)
			num_buttons = #scroller:GetChild("Line")
			-- need to queue so that the Scroller itself has time to apply its OnCommand as defined in Metrics.ini
			-- then we can get the y value that... doesn't seem to be accessible in any other way
			self:queuecommand("GetScrollerY")
		end,
		GetScrollerYCommand=function(self)
			scroller_y = SCREENMAN:GetTopScreen():GetChild("LineScroller"):GetY()
		end

	}
}

for i,player in ipairs( PlayerNumber ) do
	-- colored Quad serving as a background for the text "PLAYER 1" or "PLAYER 2"
	af[#af+1] = Def.Quad{
		InitCommand=function(self)
			self:align(PlayerNumber:Reverse()[player], 0):x(player==PLAYER_1 and 0 or _screen.w)
				:zoomto(_screen.cx, headerHeight):diffuse(PlayerColor(player)):diffusealpha(0.8)
		end
	}

	af[#af+1] = LoadFont(ThemePrefs.Get("ThemeFont") .. " Header")..{
		Text=("%s %i"):format(THEME:GetString("ScreenTestInput", "Player"), PlayerNumber:Reverse()[player]+1),
		InitCommand=function(self)
			self:halign(PlayerNumber:Reverse()[OtherPlayer[player]])
				:x(_screen.cx + 110 * (player==PLAYER_1 and -1 or 1) )
				:y(headerHeight/2):zoom(0.8):diffusealpha(0)
		end,
		OnCommand=function(self) self:linear(0.5):diffusealpha(1) end,
		OffCommand=function(self) self:linear(0.5):diffusealpha(0) end,
	}
end

af[#af+1] = Def.Quad{
	Name="DevicesBG",
	InitCommand=function(self)
		self:x(_screen.cx):y(headerHeight/2):zoomto(SL_WideScale(160, 200), headerHeight*0.65):diffuse(0.5,0.5,0.5,0.9)
	end
}

return af