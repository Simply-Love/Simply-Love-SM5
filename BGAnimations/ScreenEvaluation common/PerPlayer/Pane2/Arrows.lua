local player = ...
local pn = ToEnumShortString(player)

local ps = GAMESTATE:GetPlayerState(player)
-- NOTESKIN:LoadActorForNoteSkin() expects the noteskin name to be all lowercase?
local noteskin = ps:GetCurrentPlayerOptions():NoteSkin():lower()

local game = GAMESTATE:GetCurrentGame():GetName()
local columns = {
	pump = { "DownLeft", "UpLeft", "Center", "UpRight", "DownRight" },
	techno = { "DownLeft", "Left", "UpLeft", "Down", "Up", "UpRight", "Right", "DownRight" },
	dance = { "Left", "Down", "Up", "Right" }
}

local box_width = 230
local column_width = box_width/#columns[game]

local judgments = { "W1", "W2", "W3", "W4", "W5", "Miss" }


local af = Def.ActorFrame{}

for i,column in ipairs( columns[game] ) do

	af[#af+1] = NOTESKIN:LoadActorForNoteSkin( column, "Tap Note", noteskin)..{
		OnCommand=function(self)
			self:xy( i*column_width - 104, _screen.cy-41):zoom(0.4)
		end
	}

	for j, judgment in ipairs(judgments) do
		af[#af+1] = Def.BitmapText{
			Font="_miso",
			Text=SL[pn].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1].column_judgments[i][judgment],
			OnCommand=function(self)
				self:xy(i*column_width-104, _screen.cy-40 + j*24)
					:zoom(0.9)
			end
		}
	end
end

return af