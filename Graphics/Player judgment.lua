local player = Var "Player"
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers
local sprite

-- helper function for returning the player AF
-- works as expected in ScreenGameplay
--     arguments:  pn is short string PlayerNumber like "P1" or "P2"
--     returns:    the "PlayerP1" or "PlayerP2" ActorFrame in ScreenGameplay
--                 or, the unnamed equivalent in ScrenEdit
local GetPlayerAF = function(pn)
	local topscreen = SCREENMAN:GetTopScreen()
	if not topscreen then
		lua.ReportScriptError("GetPlayerAF() failed to find the player ActorFrame because there is no Screen yet.")
		return nil
	end

	local playerAF = nil

	-- Get the player ActorFrame on ScreenGameplay
	-- It's a direct child of the screen and named "PlayerP1" for P1
	-- and "PlayerP2" for P2.
	-- This naming convention is hardcoded in the SM5 engine.
	--
	-- ScreenEdit does not name its player ActorFrame, but we can still find it.

	-- find the player ActorFrame in edit mode
	if (THEME:GetMetric(topscreen:GetName(), "Class") == "ScreenEdit") then
		-- loop through all nameless children of topscreen
		-- and find the one that contains the NoteField
		-- which is thankfully still named "NoteField"
		for _,nameless_child in ipairs(topscreen:GetChild("")) do
			if nameless_child:GetChild("NoteField") then
				playerAF = nameless_child
				break
			end
		end

	-- find the player ActorFrame in gameplay
	else
		local player_af = topscreen:GetChild("Player"..pn)
		if player_af then
			playerAF = player_af
		end
	end

	return playerAF
end
------------------------------------------------------------
-- A profile might ask for a judgment graphic that doesn't exist
-- If so, use the first available Judgment graphic
-- If that fails too, fail gracefully and do nothing
local available_judgments = GetJudgmentGraphics()

local file_to_load = (FindInTable(mods.JudgmentGraphic, available_judgments) ~= nil and mods.JudgmentGraphic or available_judgments[1]) or "None"

if file_to_load == "None" then
	return Def.Actor{
		InitCommand=function(self) self:visible(false) end,
		JudgmentMessageCommand=function(self,param)
			if param.Player ~= player then return end

			if ToEnumShortString(param.TapNoteScore) == "W1" and mods.ShowFaPlusWindow then
				if not IsW0Judgment(param, player) and not IsAutoplay(player) then
					frame = 1
					
					for col,tapnote in pairs(param.Notes) do
						local tnt = ToEnumShortString(tapnote:GetTapNoteType())
						if tnt == "Tap" or tnt == "HoldHead" or tnt == "Lift" then
							GetPlayerAF(pn):GetChild("NoteField"):did_tap_note(col, "TapNoteScore_W1", --[[bright]] true)
						end
					end
				end
			end
	  end,
		EarlyHitMessageCommand=function(self, param)
			if param.Player ~= player then return end
	
			if not mods.HideEarlyDecentWayOffFlash then
				GetPlayerAF(pn):GetChild("NoteField"):did_tap_note(param.Column + 1, param.TapNoteScore, --[[bright]] false)
			end
		end
	}
end

------------------------------------------------------------

local TNSFrames = {
	TapNoteScore_W1 = 0,
	TapNoteScore_W2 = 1,
	TapNoteScore_W3 = 2,
	TapNoteScore_W4 = 3,
	TapNoteScore_W5 = 4,
	TapNoteScore_Miss = 5
}

return Def.ActorFrame{
	Name="Player Judgment",
	InitCommand=function(self)
		local kids = self:GetChildren()
		sprite = kids.JudgmentWithOffsets
	end,
	EarlyHitMessageCommand=function(self, param)
		if param.Player ~= player then return end

		local frame = TNSFrames[ param.TapNoteScore ]
		if not frame then return end

		if not mods.HideEarlyDecentWayOffFlash then
			GetPlayerAF(pn):GetChild("NoteField"):did_tap_note(param.Column + 1, param.TapNoteScore, --[[bright]] false)
		end

		if not mods.HideEarlyDecentWayOffJudgments then
			-- If the judgment font contains a graphic for the additional white fantastic window...
			if sprite:GetNumStates() == 7 or sprite:GetNumStates() == 14 then
				if ToEnumShortString(param.TapNoteScore) == "W1" then
					if mods.ShowFaPlusWindow then
						-- If this W1 judgment fell outside of the FA+ window, show the white window
						--
						-- Treat Autoplay specially. The TNS might be out of the range, but
						-- it's a nicer experience to always just display the top window graphic regardless.
						-- This technically causes a discrepency on the histogram, but it's likely okay.
						if not IsW0Judgment(param, player) and not IsAutoplay(player) then
							frame = 1
						end
					end
					-- We don't need to adjust the top window otherwise.
				else
					-- Everything outside of W1 needs to be shifted down a row if not in FA+ mode.
					-- Some people might be using 2x7s in FA+ mode (by copying ITG graphics to FA+).
					-- Don't need to shift in that case.
					if SL.Global.GameMode ~= "FA+" then
						frame = frame + 1
					end
				end
			end

			self:playcommand("Reset")

			-- most judgment sprite sheets have 12 or 14 frames; 6/7 for early judgments, 6/7 for late judgments
			-- some (the original 3.9 judgment sprite sheet for example) do not visibly distinguish
			-- early/late judgments, and thus only have 6/7 frames
			if sprite:GetNumStates() == 12 or sprite:GetNumStates() == 14 then
				frame = frame * 2
			end

			sprite:visible(true):setstate(frame)

			if SL[ToEnumShortString(player)].ActiveModifiers.JudgmentTilt then
				-- How much to rotate.
				-- We cap it at 50ms (15px) since anything after likely to be too distracting.
				local offset = math.min(math.abs(param.TapNoteOffset), 0.050) * 300
				-- Which direction to rotate.
				local direction = param.TapNoteOffset < 0 and -1 or 1
				sprite:rotationz(direction * offset)
			end
			-- this should match the custom JudgmentTween() from SL for 3.95
			sprite:zoom(0.8):decelerate(0.1):zoom(0.75):sleep(0.6):accelerate(0.2):zoom(0)
		end
	end,
	JudgmentMessageCommand=function(self, param)
		if param.Player ~= player then return end
		if not param.TapNoteScore then return end
		if param.HoldNoteScore then return end

		local tns = ToEnumShortString(param.TapNoteScore)
		if param.EarlyTapNoteScore ~= nil then
			local earlyTns = ToEnumShortString(param.EarlyTapNoteScore)

			if earlyTns ~= "None" then
				if SL.Global.GameMode == "FA+" then
					if tns == "W5" then
						return
					end
				else
					if tns == "W4" or tns == "W5" then
						return
					end
				end
			end
		end

		-- "frame" is the number we'll use to display the proper portion of the judgment sprite sheet
		-- Sprite actors expect frames to be 0-indexed when using setstate() (not 1-indexed as is more common in Lua)
		-- an early W1 judgment would be frame 0, a late W2 judgment would be frame 3, and so on
		local frame = TNSFrames[ param.TapNoteScore ]
		if not frame then return end

		-- If the judgment font contains a graphic for the additional white fantastic window...
		if sprite:GetNumStates() == 7 or sprite:GetNumStates() == 14 then
			if tns == "W1" then
				if mods.ShowFaPlusWindow then
					-- If this W1 judgment fell outside of the FA+ window, show the white window
					--
					-- Treat Autoplay specially. The TNS might be out of the range, but
					-- it's a nicer experience to always just display the top window graphic regardless.
					-- This technically causes a discrepency on the histogram, but it's likely okay.
					if not IsW0Judgment(param, player) and not IsAutoplay(player) then
						frame = 1
						
						for col,tapnote in pairs(param.Notes) do
							local tnt = ToEnumShortString(tapnote:GetTapNoteType())
							if tnt == "Tap" or tnt == "HoldHead" or tnt == "Lift" then
								GetPlayerAF(pn):GetChild("NoteField"):did_tap_note(col, "TapNoteScore_W1", --[[bright]] true)
							end
						end
					end
				end
				-- We don't need to adjust the top window otherwise.
			else
				-- Everything outside of W1 needs to be shifted down a row if not in FA+ mode.
				-- Some people might be using 2x7s in FA+ mode (by copying ITG graphics to FA+).
				-- In that case, we need to shift the Way Off down to a Miss
				if SL.Global.GameMode ~= "FA+" or tns == "Miss" then
					frame = frame + 1
				end
			end
		end


		-- most judgment sprite sheets have 12 or 14 frames; 6/7 for early judgments, 6/7 for late judgments
		-- some (the original 3.9 judgment sprite sheet for example) do not visibly distinguish
		-- early/late judgments, and thus only have 6/7 frames
		if sprite:GetNumStates() == 12 or sprite:GetNumStates() == 14 then
			frame = frame * 2
			if not param.Early then frame = frame + 1 end
		end

		self:playcommand("Reset")

		sprite:visible(true):setstate(frame)

		if mods.JudgmentTilt then
			if tns ~= "Miss" then
				-- How much to rotate.
				-- We cap it at 50ms (15px) since anything after likely to be too distracting.
				local offset = math.min(math.abs(param.TapNoteOffset), 0.050) * 300
				-- Which direction to rotate.
				local direction = param.TapNoteOffset < 0 and -1 or 1
				sprite:rotationz(direction * offset)
			else
				-- Reset rotations on misses so it doesn't use the previous note's offset.
				sprite:rotationz(0)
			end
		end
		-- this should match the custom JudgmentTween() from SL for 3.95
		sprite:zoom(0.8):decelerate(0.1):zoom(0.75):sleep(0.6):accelerate(0.2):zoom(0)
	end,

	Def.Sprite{
		Name="JudgmentWithOffsets",
		InitCommand=function(self)
			-- animate(false) is needed so that this Sprite does not automatically
			-- animate its way through all available frames; we want to control which
			-- frame displays based on what judgment the player earns
			self:animate(false):visible(false)
			
			-- if we are on ScreenEdit, judgment graphic is always "Love"
			-- because ScreenEdit is a mess and not worth bothering with.
			if string.match(tostring(SCREENMAN:GetTopScreen()), "ScreenEdit") then
				self:Load( THEME:GetPathG("", "_judgments/Love") )

			else
				self:Load( THEME:GetPathG("", "_judgments/" .. file_to_load) )
			end
		end,
		ResetCommand=function(self) self:finishtweening():stopeffect():visible(false) end
	}
}
