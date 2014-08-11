local t = Def.ActorFrame{}
local sequence = { "W1", "W2", "W3", "W4", "W5", "Hold", "Mine", "Roll" }

t[#t+1] = LoadFont("_wendy small")..{
	Text="Important:",
	InitCommand=cmd(xy,94, 20; zoom, 0.5),
	OnCommand=cmd(diffuseshift; effectperiod,1; effectcolor1, Color.Red; effectcolor2, Color.White)
}

t[#t+1] = LoadFont("_misoreg hires")..{
	Text="Timing Windows will remain the same, even if you change your theme!",
	InitCommand=cmd(horizalign, left; xy,180, 20; zoom, 0.9)
}

t[#t+1] = LoadFont("_misoreg hires")..{
	Text="Current Timing Windows\n(As retrieved from Preferences.ini)",
	InitCommand=cmd(xy,_screen.cx-150, _screen.cy-80; zoom, 0.9)
}

t[#t+1] = LoadFont("_misoreg hires")..{
	Text="New Timing Windows\n(These will be written to Preferences.ini)",
	InitCommand=cmd(xy,_screen.cx+150, _screen.cy-80; zoom, 0.9)
}

t[#t+1] = Def.Quad{
	InitCommand=cmd(zoomto, 80, _screen.h/2; xy, _screen.cx, _screen.cy + 70),
	OnCommand=cmd(diffuse,color("#071016"); diffusealpha,0.8)
}

t[#t+1] = Border(80, _screen.h/2,1)..{
	InitCommand=cmd(xy, _screen.cx, _screen.cy + 70) 
}

local CurrentTimingWindows = WhichTimingIsBeingUsed()

for i=1,#sequence do	
	
	for k,v in pairs(TimingWindowValues[CurrentTimingWindows]) do
		if k == sequence[i] then
			
			-- the current values
			t[#t+1] = LoadFont("_misoreg hires")..{
				Text=("%0.6f"):format(v),
				InitCommand=cmd(zoom, 0.9 ),
				OnCommand=function(self)
					self:xy(_screen.cx-100, (_screen.cy-64) + (i*30))
				end
			}
	
			-- the values that will be written
			t[#t+1] = LoadFont("_misoreg hires")..{
				Text=("%0.6f"):format(v),
				InitCommand=cmd(zoom, 0.9 ),
				OnCommand=function(self)
					self:xy(_screen.cx+100, (_screen.cy-64) + (i*30))
				end,
				TimingWindowChangedMessageCommand=function(self, params)
					self:settext(("%0.6f"):format(TimingWindowValues[params.TimingWindow][k]))
				end
			}
			break
		end
	end
	
	t[#t+1] = LoadFont("_misoreg hires")..{
		Text=sequence[i],
		InitCommand=cmd(zoom, 0.9),
		OnCommand=function(self)
			self:xy(_screen.cx, (_screen.cy-64) + (i*30))
			i = i+1
		end
	}
	
	-- faux gridlines
	if i < #sequence then
		t[#t+1] = Def.Quad{
			InitCommand=cmd(zoomto, _screen.w/2+50, 1; xy, _screen.cx, (_screen.cy - 50) + (i*30); diffusealpha,0.125 ),
		}
	end	
	
end





return t