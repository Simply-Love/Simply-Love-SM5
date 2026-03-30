-- ScreenMiniMenuContext is a screen drawn on top of ScreenOptionsManageProfiles
-- when the player wants to manage a particular local profile.
-- It is styled to appear as a modal, with ScreenOptionsManageProfiles visible
-- in the background.

local num_rows
local row_height  = 28
local container_w = 240

local underlay = Def.ActorFrame {
	InitCommand=function(self) self:queuecommand("Capture") end,
	CaptureCommand=function(self)
		-- how many rows do we need to accommodate?
		num_rows = #SCREENMAN:GetTopScreen():GetChild("Container"):GetChild("")
		-- If there are more than 10 rows, they collapse via scroller anyway
		-- so don't accommodate the decorative border for more than 10
		num_rows = math.min(10, num_rows)
		self:queuecommand("Size")
	end
}

-- darken the background behind the modal
underlay[#underlay+1] = Def.Quad{
	SizeCommand=function(self)
		self:x(_screen.cx)
		self:zoomto(_screen.w*2, _screen.h*2):diffuse(0,0,0,0.75)
	end
}


-- modal of choices for managing this local profile
-- the MiniMenu choices (set P1, set P2, edit, rename, delete, merge, move, etc.)
-- are hardcoded by the SM5 engine for now
underlay[#underlay+1] = Def.ActorFrame{
	InitCommand=function(self) self:xy(_screen.cx-container_w, -16) end,

	-- decorative border
	Def.Quad{
		SizeCommand=function(self) self:zoomto(container_w, row_height*num_rows) end,
	},

	-- local profile's display name at top of modal
	LoadFont(ThemePrefs.Get("ThemeFont") .. " Normal")..{
		InitCommand=function(self) self:xy(-99, -118):halign(0):diffuse(Color.Black) end,
		BeginCommand=function(self)
			local profile = GAMESTATE:GetEditLocalProfile()
			if profile then
				self:settext(profile:GetDisplayName())
				DiffuseEmojis(self)
			end
		end
	}
}

return underlay