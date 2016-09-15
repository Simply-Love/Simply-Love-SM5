local player = ...
local pn = ToEnumShortString(player)

local ps = GAMESTATE:GetPlayerState(player)
-- NOTESKIN:LoadActorForNoteSkin() expects the noteskin name to be all lowercase?
local noteskin = ps:GetCurrentPlayerOptions():NoteSkin():lower()
local style = ToEnumShortString(GAMESTATE:GetCurrentStyle():GetStyleType())

local game = GAMESTATE:GetCurrentGame():GetName()
local columns = {
	pump = { "DownLeft", "UpLeft", "Center", "UpRight", "DownRight" },
	techno = { "DownLeft", "Left", "UpLeft", "Down", "Up", "UpRight", "Right", "DownRight" },
	dance = { "Left", "Down", "Up", "Right" }
}

local box_width = 230
local column_width = box_width/#columns[game]

local judgments = { "W1", "W2", "W3", "W4", "W5", "Miss" }

-- need to store the number of columns PRIOR to looping
-- otherwise we enter an infinite loop because the upper bound keeps growing!
local num_columns = #columns[game]

if style == "OnePlayerTwoSides" then
	for i=1,num_columns do
		table.insert(columns[game], columns[game][i])
	end
end


local af = Def.ActorFrame{}

for i,column in ipairs( columns[game] ) do


	-- The arrow for this column
	af[#af+1] = NOTESKIN:LoadActorForNoteSkin( column, "Tap Note", noteskin)..{
		OnCommand=function(self)
			self:xy( i*column_width - 104, _screen.cy-41):zoom(0.4)
		end
	}


	-- the number of judgments for each possible judgment for this column
	for j, judgment in ipairs(judgments) do
		af[#af+1] = Def.BitmapText{
			Font="_miso",
			Text=SL[pn].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1].column_judgments[i][judgment],
			OnCommand=function(self)
				self:xy(i*column_width-104, _screen.cy-40 + j*24)
					:zoom(0.9)

				local gmods = SL.Global.ActiveModifiers

				-- if Way Offs were turned off
				if gmods.DecentsWayOffs == "Decents Only" and judgment == "W5" then
					self:visible(false)

				-- if both Decents and WayOffs were turned off
				elseif gmods.DecentsWayOffs == "Off" and (judgment == "W4" or judgment == "W5") then
					self:visible(false)
				end
			end
		}
	end
end

return af