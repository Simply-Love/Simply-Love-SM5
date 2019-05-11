local player = ...
local pn = ToEnumShortString(player)
local track_missbcheld = SL[pn].ActiveModifiers.MissBecauseHeld

local judgments = { "W1", "W2", "W3", "W4", "W5", "Miss" }
local TNSNames = {}

local tns_string = "TapNoteScore"
if SL.Global.GameMode ~= "Competitive" then tns_string = tns_string..SL.Global.GameMode end

-- tap note types
-- Iterating through the enum isn't worthwhile because the sequencing is so bizarre...
for i, judgment in ipairs(judgments) do
	TNSNames[#TNSNames+1] = THEME:GetString(tns_string, judgment)
end

local box_height = 146
local row_height = box_height/#judgments

local t = Def.ActorFrame{
	InitCommand=cmd(xy, 50, _screen.cy-36),
	OnCommand=function(self)
		if player == PLAYER_2 then
			self:x( self:GetX() * -1)
		end
	end
}

local miss_bmt

--  labels: W1 ---> Miss
for index, label in ipairs(TNSNames) do
	t[#t+1] = LoadFont("_miso")..{
		Text=label:upper(),
		InitCommand=function(self)
			self:zoom(0.8):horizalign(right)
				:x( (player == PLAYER_1 and -130) or -28 )
				:y( index * row_height )
				:diffuse( SL.JudgmentColors[SL.Global.GameMode][index] )

			-- Check for Decents/Way Offs
			local gmods = SL.Global.ActiveModifiers

			-- if Way Offs were turned off
			if gmods.DecentsWayOffs == "Decents Only" and label == THEME:GetString("TapNoteScore", "W5") then
				self:visible(false)

			-- if both Decents and WayOffs were turned off
			elseif gmods.DecentsWayOffs == "Off" and (label == THEME:GetString("TapNoteScore", "W4") or label == THEME:GetString("TapNoteScore", "W5")) then
				self:visible(false)
			end

			if index == #judgments then miss_bmt = self end
		end
	}
end

if track_missbcheld then
	t[#t+1] = LoadFont("_miso")..{
		Text=ScreenString("Held"),
		InitCommand=function(self)
			self:y(140):zoom(0.6):halign(1)
				:diffuse( SL.JudgmentColors[SL.Global.GameMode][6] )
		end,
		OnCommand=function(self)
			self:x( miss_bmt:GetX() - miss_bmt:GetWidth()/1.15 )
		end
	}
end

return t