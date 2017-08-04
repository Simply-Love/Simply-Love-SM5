local player = ...
local pn = ToEnumShortString(player)

local mode = ""
if SL.Global.GameMode == "StomperZ" then mode = "StomperZ" end
if SL.Global.GameMode == "ECFA" then mode = "ECFA" end

-- tap note types
-- Iterating through the enum isn't worthwhile because the sequencing is so bizarre...
local TNSNames = {
	THEME:GetString("TapNoteScore" .. mode, "W1"),
	THEME:GetString("TapNoteScore" .. mode, "W2"),
	THEME:GetString("TapNoteScore" .. mode, "W3"),
	THEME:GetString("TapNoteScore" .. mode, "W4"),
	THEME:GetString("TapNoteScore" .. mode, "W5"),
	THEME:GetString("TapNoteScore" .. mode, "Miss")
}

local Colors = {
	Competitive = {
		color("#21CCE8"),	-- blue
		color("#e29c18"),	-- gold
		color("#66c955"),	-- green
		color("#5b2b8e"),	-- purple
		color("#c9855e"),	-- peach?
		color("#ff0000")	-- red
	},
	StomperZ = {
		color("#FFFFFF"),	-- white
		color("#e29c18"),	-- gold
		color("#66c955"),	-- green
		color("#21CCE8"),	-- blue
		color("#000000"),	-- black
		color("#ff0000")	-- red
	},
	ECFA = {
		color("#21CCE8"),	-- blue
		color("#FFFFFF"),	-- white
		color("#e29c18"),	-- gold
		color("#66c955"),	-- green
		color("#9e00f7"),	-- purple
		color("#ff0000")	-- red
	}
}

local RadarCategories = {
	THEME:GetString("ScreenEvaluation", 'Holds'),
	THEME:GetString("ScreenEvaluation", 'Mines'),
	THEME:GetString("ScreenEvaluation", 'Rolls')
}


local af = Def.ActorFrame{}


--  labels: W1, W2, W3, W4, W5, Miss
for i, label in ipairs(TNSNames) do
	af[#af+1] = LoadFont("_miso")..{
		Text=label:upper(),
		InitCommand=cmd(zoom,0.833; horizalign,right ),
		BeginCommand=function(self)
			self:x(80):y((i-1)*28 - 226)
				:diffuse( Colors[SL.Global.GameMode][i] )


			local gmods = SL.Global.ActiveModifiers
			local mode = SL.Global.GameMode
			if (mode == "Casual" or mode == "Competitive") then mode = "" end

			-- if Way Offs were turned off
			if gmods.DecentsWayOffs == "Decents Only" and label == THEME:GetString("TapNoteScore" .. mode, "W5") then
				self:visible(false)

			-- if both Decents and WayOffs were turned off
			elseif gmods.DecentsWayOffs == "Off" and (label == THEME:GetString("TapNoteScore" .. mode, "W4") or label == THEME:GetString("TapNoteScore" .. mode, "W5")) then
				self:visible(false)
			end
		end
	}
end

-- labels: holds, mines, rolls
for i, label in ipairs(RadarCategories) do
	af[#af+1] = LoadFont("_miso")..{
		Text=label,
		InitCommand=cmd(zoom,0.833; horizalign,right ),
		BeginCommand=function(self)
			self:x(-94):y((i-1)*28 - 143)
		end
	}
end

return af