local t = Def.ActorFrame{}
local sequence = { "W1", "W2", "W3", "W4", "W5", "Hold", "Mine", "Roll" }

local sequenceStrings = {
	THEME:GetString("TapNoteScore", "W1"),
	THEME:GetString("TapNoteScore", "W2"),
	THEME:GetString("TapNoteScore", "W3"),
	THEME:GetString("TapNoteScore", "W4"),
	THEME:GetString("TapNoteScore", "W5"),
	THEME:GetString("RadarCategory", "Holds"),
	THEME:GetString("RadarCategory", "Mines"),
	THEME:GetString("RadarCategory", "Rolls")
}

-- Header text
t[#t+1] = LoadFont("_wendy small")..{
	Text=THEME:GetString("ScreenOptionsTimingWindows", "Important"),
	InitCommand=cmd(xy,94, 20; zoom, 0.5),
	OnCommand=cmd(diffuseshift; effectperiod,1; effectcolor1, Color.Red; effectcolor2, Color.White)
}

t[#t+1] = LoadFont("_miso")..{
	Text=THEME:GetString("ScreenOptionsTimingWindows", "Warning"),
	InitCommand=cmd(horizalign, left; xy,180, 20; zoom, 0.9)
}


-- Current (retrieved from Preferences.ini)
t[#t+1] = LoadFont("_miso")..{
	Text=THEME:GetString("ScreenOptionsTimingWindows", "CurrentTimingWindows"),
	InitCommand=cmd(xy,_screen.cx-70, _screen.cy-90; zoom, 0.9; horizalign, right)
}
-- New (to be written to Preferences.ini)
t[#t+1] = LoadFont("_miso")..{
	Text=THEME:GetString("ScreenOptionsTimingWindows", "NewTimingWindows"),
	InitCommand=cmd(xy,_screen.cx+70, _screen.cy-90; zoom, 0.9; horizalign, left)
}

t[#t+1] = Def.Quad{
	InitCommand=cmd(zoomto, 80, _screen.h/2; xy, _screen.cx, _screen.cy + 50),
	OnCommand=cmd(diffuse,color("#071016"); diffusealpha,0.8)
}

t[#t+1] = Border(80, _screen.h/2,1)..{
	InitCommand=cmd(xy, _screen.cx, _screen.cy + 50)
}

local CurrentTimingWindows = WhichTimingIsBeingUsed()

for i=1,#sequence do

	for k,v in pairs(TimingWindowValues[CurrentTimingWindows]) do
		if k == sequence[i] then

			-- the current values
			t[#t+1] = LoadFont("_miso")..{
				Text=("%0.6f"):format(v),
				InitCommand=cmd(zoom, 0.9 ),
				OnCommand=function(self)
					self:xy(_screen.cx-100, (_screen.cy-84) + (i*30))
				end
			}

			-- the values that will be written
			t[#t+1] = LoadFont("_miso")..{
				Text=("%0.6f"):format(v),
				InitCommand=cmd(zoom, 0.9 ),
				OnCommand=function(self)
					self:xy(_screen.cx+100, (_screen.cy-84) + (i*30))
				end,
				TimingWindowChangedMessageCommand=function(self, params)
					self:settext(("%0.6f"):format(TimingWindowValues[params.TimingWindow][k]))
				end
			}
			break
		end
	end

	t[#t+1] = LoadFont("_miso")..{
		Text=sequenceStrings[i],
		InitCommand=cmd(zoom, 0.9),
		OnCommand=function(self)
			self:xy(_screen.cx, (_screen.cy-84) + (i*30))
			i = i+1
		end
	}

	-- faux gridlines
	if i < #sequence then
		t[#t+1] = Def.Quad{
			InitCommand=cmd(zoomto, _screen.w/2+50, 1; xy, _screen.cx, (_screen.cy - 70) + (i*30); diffusealpha,0.125 ),
		}
	end

end

return t