-- Song wheel tech analysis

local player = ...
local pn = ToEnumShortString(player)


-- TODO: 2 actors, one for each player. Could this be one actor that draws both players?
local af = Def.BitmapText {
	Font = "Common Normal",
	Text = "",
	InitCommand = function(self)
		-- TODO: is this a good position? wide screen should have space to make the music wheel wider
		-- position on right side of the song title, left of ITL EX
		-- fits the maximum 6 techs
		self:visible(false)
		self:horizalign(right)
		self:zoom(0.6)
		if DarkUI() then self:diffuse(0, 0, 0, 1) end
	end,
	-- Set is called by MusicWheelItem::HandleMessage. There are a bunch of messages that can trigger it.
	SetCommand = function(self, params)
		-- default to invisible, if we fail to process something, we just return immediately and stay hidden
		self:visible(false)

		-- params is null sometimes for some reason?
		-- this seems to happen when changing songs and the previous diff doesn't exist for the new one
		-- we eventually do seem to get valid params
		if not params or not params.Song then
			-- SM("Null params")
			return
		end

		-- song of _this_ actor (every song on the music wheel)
		local song = params.Song
		if song == nil then
			-- SM("Song is nil")
			return
		end

		-- TODO: is there a better way of laying this out?
		local x_offset = 10
		local musicWheelScore = ThemePrefs.Get("MusicWheelScore")
		-- If MusicWheelScore is No, there's a score displayed on the right side only if it's ITL
		-- If MusicWheelScore is Yes, there's a score displayed on the right side (regardless of ITL)
		-- If MusicWheelScore is ReplaceGrade, there's no score displayed on the right side (regardless of ITL)
		if (musicWheelScore == MusicWheelScore_No and IsItlSong(song, player)) or ThemePrefs.Get("MusicWheelScore") == MusicWheelScore_Yes then
			-- We have ITL_EXscore or Score on the rightmost side
			x_offset = 60
		end
		self:x(_screen.w / (WideScale(2.15, 2.14)) - x_offset)

		-- steps of _this_ actor
		local steps = SongUtil.GetPlayableSteps(song)

		-- visual vertical position depending on if 1 / 2 players are playing
		if GAMESTATE:GetNumSidesJoined() == 2 then
			if player == PLAYER_1 then
				self:y(-6)
			else
				self:y(6)
			end
		else
			self:y(0)
		end

		local currentSteps = GAMESTATE:GetCurrentSteps(player)
		if currentSteps == nil then
			-- SM("currentSteps nil")
			return
		end

		local currentDifficulty = currentSteps:GetDifficulty()

		-- Like grades, show tech that matches the currently selected difficulty.
		local stepsToCheck = nil
		if #steps == 1 then
			-- If there's only a single difficulty, don't try to match the difficulty. Just show the only one.
			stepsToCheck = steps[1]
		else
			-- TODO: Match the engine (or theme?) behaviour on which difficulty will be autoselected from this chart
			for k, v in ipairs(steps) do
				if v:GetDifficulty() == currentDifficulty then
					stepsToCheck = v
				end
			end
		end

		--- @type string
		local preferred_tech_style = ThemePrefs.Get("MusicWheelTechNotation")
		local text = SLTechNotation_Format(stepsToCheck, pn, preferred_tech_style)

		self:settext(text)
		self:visible(true)
	end,
}

return af