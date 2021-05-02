local af = Def.ActorFrame{ InitCommand=function(self) self:Center() end }

-- check SM5 version, current game (dance, pump, etc.), and RTT support
af[#af+1] = LoadActor("./CompatibilityChecks.lua")

-- -----------------------------------------------------------------------

local slc = SL.Global.ActiveColorIndex

-- semitransparent black quad as background for 7 decorative arrows
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:zoomto(_screen.w,0):diffuse(Color.Black) end,
	OnCommand=function(self) self:accelerate(0.3):zoomtoheight(128):diffusealpha(0.9):sleep(2.1) end,
	OffCommand=function(self) self:accelerate(0.3):zoomtoheight(0) end
}

-- loop to add 7 SM5 logo arrows to the primary ActorFrame
for i=1,7 do

	local arrow = Def.ActorFrame{
		InitCommand=function(self) self:x((i-4) * 50):diffusealpha(0) end,
		OnCommand=function(self)
			-- thonk
			if ThemePrefs.Get("VisualStyle")=="Thonk" then
				self:diffusealpha(1):rotationy(-90):sleep(i*0.1 + 0.2)
				self:smooth(0.25):rotationy(0):sleep(0.8):bouncebegin(0.8):y(_screen.h)
			-- everything else
			else
				self:sleep(i*0.1 + 0.2)
				self:linear(0.75):diffusealpha(1):linear(0.75):diffusealpha(0)
			end

			self:queuecommand("Hide")
		end,
		HideCommand=function(self) self:visible(false) end,
	}

	-- desaturated SM5 logo
	arrow[#arrow+1] = LoadActor("logo.png")..{
		InitCommand=function(self) self:zoom(0.1):diffuse(GetHexColor(slc-i-4, true)) end,
	}

	-- only add Thonk asset if needed
	if ThemePrefs.Get("VisualStyle")=="Thonk" then
		arrow[#arrow+1] = LoadActor("thonk.png")..{
			InitCommand=function(self) self:zoom(0.1):xy(6,-2) end,
		}
	end

	af[#af+1] = arrow
end

return af
