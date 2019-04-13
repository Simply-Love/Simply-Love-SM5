-- don't bother for Casual gamemode
if SL.Global.GameMode == "Casual" then return end

local player = ...
local judgments = {}
for i=1,GAMESTATE:GetCurrentStyle():ColumnsPerPlayer() do
	judgments[#judgments+1] = { W1=0, W2=0, W3=0, W4=0, W5=0, Miss=0, MissBecauseHeld=0 }
end

local buttons = {
	dance = { "Left", "Down", "Up", "Right" },
	pump = { "DownLeft", "UpLeft", "Center", "UpRight", "DownRight" }
}

local held = {}
for player in ivalues(GAMESTATE:GetHumanPlayers()) do
	held[player] = {
		dance = { Left=false, Down=false, Up=false, Right=false },
		pump = { DownLeft=false, UpLeft=false, Center=false, UpRight=false, DownRight=false }
	}
end

local current_game = GAMESTATE:GetCurrentGame():GetName()

local InputHandler = function(event)
	-- if any of these, don't attempt to handle input
	if not event.PlayerNumber or not event.button then return false end

	if event.type == "InputEventType_FirstPress" then
		held[event.PlayerNumber][current_game][event.button] = true
	elseif event.type == "InputEventType_Release" then
		held[event.PlayerNumber][current_game][event.button] = false
	end
end

return Def.Actor{
	OnCommand=function(self) SCREENMAN:GetTopScreen():AddInputCallback( InputHandler ) end,
    JudgmentMessageCommand=function(self, params)
		if params.Player == player and params.Notes then
			for col,tapnote in pairs(params.Notes) do
				local tns = ToEnumShortString(params.TapNoteScore)
				judgments[col][tns] = judgments[col][tns] + 1

				if tns == "Miss" and held[params.Player][current_game][ buttons[current_game][col] ] then
					judgments[col].MissBecauseHeld = judgments[col].MissBecauseHeld + 1
				end
			end
		end
    end,
	OffCommand=function(self)
		local storage = SL[ToEnumShortString(player)].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1]
		storage.column_judgments = judgments
	end
}