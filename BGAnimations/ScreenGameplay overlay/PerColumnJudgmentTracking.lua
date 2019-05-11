-- don't bother for Casual gamemode
if SL.Global.GameMode == "Casual" then return end

local player = ...
local track_missbcheld = SL[ToEnumShortString(player)].ActiveModifiers.MissBecauseHeld

local judgments = {}
for i=1,GAMESTATE:GetCurrentStyle():ColumnsPerPlayer() do
	judgments[#judgments+1] = { W1=0, W2=0, W3=0, W4=0, W5=0, Miss=0 }
end

local actor = Def.Actor{
	OffCommand=function(self)
		local storage = SL[ToEnumShortString(player)].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1]
		storage.column_judgments = judgments
	end
}

-- if the player doesn't care about MissBecauseHeld, keep it simple
if not track_missbcheld then
	actor.JudgmentMessageCommand=function(self, params)
		if params.Player == player and params.Notes then
			for col,tapnote in pairs(params.Notes) do
				local tns = ToEnumShortString(params.TapNoteScore)
				judgments[col][tns] = judgments[col][tns] + 1
			end
		end
	end

-- if the player wants to track MissBecauseHeld, we need to do a lot more work
else
	-- add MissBecauseHeld as a possible judgment for all columns
	for i,col_judgments in ipairs(judgments) do
		col_judgments.MissBecauseHeld=0
	end

	local buttons = {
		dance = { "Left", "Down", "Up", "Right" },
		pump = { "DownLeft", "UpLeft", "Center", "UpRight", "DownRight" },
		techno = { "DownLeft", "Left", "UpLeft", "Down", "Up", "UpRight", "Right", "DownRight" },
		para = { "Left", "UpLeft", "Up", "UpRight", "Right" },
		kb7 = { "Key1", "Key2", "Key3", "Key4", "Key5", "Key6", "Key7" },

		-- these games aren't supported by SL right now
		beat = { "Key1", "Key2", "Key3", "Key4", "Key5", "Key6", "Key7", "Scratch up", "Scratch down" },
		kickbox = { "Down Left Foot", "Up Left Foot", "Up Left Fist", "Down Left Fist", "Down Right Fist", "Up Right Fist", "Up Right Foot", "Down Right Foot" }
	}

	local current_game = GAMESTATE:GetCurrentGame():GetName()
	local held = {}

	-- initialize to handle both players, regardless of whether both are actually joined.
	-- the engine's InputCallback gives you ALL input, so even if only P1 is joined, the
	-- InputCallback will report someone spamming input on P2 as valid events, so we have
	-- to ensure that doesn't cause Lua errors here
	for player in ivalues({PLAYER_1, PLAYER_2}) do
		held[player] = {}

		-- initialize all buttons available to this game for this player to be "not held"
		for button in ivalues(buttons[current_game]) do
			held[player][button] = false
		end
	end



	local InputHandler = function(event)
		-- if any of these, don't attempt to handle input
		if not event.PlayerNumber or not event.button then return false end

		if event.type == "InputEventType_FirstPress" then
			held[event.PlayerNumber][event.button] = true
		elseif event.type == "InputEventType_Release" then
			held[event.PlayerNumber][event.button] = false
		end
	end

	actor.OnCommand=function(self) SCREENMAN:GetTopScreen():AddInputCallback( InputHandler ) end
	actor.JudgmentMessageCommand=function(self, params)
		if params.Player == player and params.Notes then
			for col,tapnote in pairs(params.Notes) do
				local tns = ToEnumShortString(params.TapNoteScore)
				judgments[col][tns] = judgments[col][tns] + 1

				if tns == "Miss" and held[params.Player][ buttons[current_game][col] ] then
					judgments[col].MissBecauseHeld = judgments[col].MissBecauseHeld + 1
				end
			end
		end
    end
end

return actor