local player = ...
local pn = ToEnumShortString(player)

local judgments = { "W1", "W2", "W3", "W4", "W5", "Miss" }
local TNSNames = {}

local mode = ""
if SL.Global.GameMode == "StomperZ" then mode = "StomperZ"
elseif SL.Global.GameMode == "ECFA" then mode = "ECFA" end


-- tap note types
-- Iterating through the enum isn't worthwhile because the sequencing is so bizarre...
for i, judgment in ipairs(judgments) do
	TNSNames[#TNSNames+1] = THEME:GetString("TapNoteScore" .. mode, judgment)
end


local t = Def.ActorFrame{
	InitCommand=cmd(xy, 50, _screen.cy-24),
	OnCommand=function(self)
		if player == PLAYER_2 then
			self:x( self:GetX() * -1)
		end
	end
}


--  labels: W1 ---> Miss
for index, label in ipairs(TNSNames) do
	t[#t+1] = LoadFont("_miso")..{
		Text=label:upper(),
		InitCommand=cmd(zoom,0.775; horizalign,right ),
		BeginCommand=function(self)
			self:x( (player == PLAYER_1 and -130) or -28 )
			self:y((index-1)*24 + 8)

			-- if StomperZ, color the JudgmentLabel
			if mode == "StomperZ" then
				self:diffuse( SL.JudgmentColors.StomperZ[index] )

			-- if ECFA, color the JudgmentLabel
			elseif mode == "ECFA" then
				self:diffuse( SL.JudgmentColors.ECFA[index] )
			end


			-- Check for Decents/Way Offs
			local gmods = SL.Global.ActiveModifiers

			-- if Way Offs were turned off
			if gmods.DecentsWayOffs == "Decents Only" and label == THEME:GetString("TapNoteScore", "W5") then
				self:visible(false)

			-- if both Decents and WayOffs were turned off
			elseif gmods.DecentsWayOffs == "Off" and (label == THEME:GetString("TapNoteScore", "W4") or label == THEME:GetString("TapNoteScore", "W5")) then
				self:visible(false)
			end


		end
	}
end


return t