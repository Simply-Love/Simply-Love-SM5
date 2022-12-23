-- Retrieve ThemePref values and attempt to set the EditMenu
-- to the "last seen" song and stepchart for quicker navigation.
-- This can be handy when a player is working on the same stepchart
-- over the course of multiple days/SM5 restarts.
--
-- The 1st half of this (retreiving strings from ThemePrefs and setting GAMESTATE)
-- can be performed immediately when this file is loaded.  None of it requires
-- Actors.
--
-- The 2nd half of this (writing the LastSeen string values to ThemePrefs)
-- is handled lower in this file, and hooks into the screen's OffCommand.
-- It will be run when the player chooses a song and stepchart and successfully
-- proceeds to ScreenEdit, but not when the player backs out of ScreenEditMenu
-- (Escape key or mapped BACK button).
-- ----------------------------------------------------------------

local song_str      = ThemePrefs.Get("EditModeLastSeenSong")
local diff_str      = ThemePrefs.Get("EditModeLastSeenDifficulty")
local stepstype_str = ThemePrefs.Get("EditModeLastSeenStepsType")
local styletype_str = ThemePrefs.Get("EditModeLastSeenStyleType")

if song_str ~= "" then
	local song = SONGMAN:FindSong( song_str )

	if song then
		-- If a song was saved in ThemePrefs, set GAMESTATE's CurrentSong now
		-- during Init.  In the engine's code, EditMenu::RefreshAll() is called
		-- once at the end of EditMode::Load(), and uses GAMESTATE's current song.
		GAMESTATE:SetCurrentSong( song )

		-- The current song can be set indepenently from stepchart.
		-- It's possible there could be invalid strings for
		-- difficulty, stepstype, or styletype, but a valid song string.

		-- don't both with empty strings
		if stepstype_str ~= "" and diff_str ~= "" and styletype_str ~= "" then

			-- transform a StepsType string like "StepsType_Dance_Single" into "single"
			local style = stepstype_str:gsub("%w+_%w+_", ""):lower()
			-- ensure string values retrieved from ThemePrefs are valid
			for _style in ivalues(GAMEMAN:GetStylesForGame(GAMESTATE:GetCurrentGame():GetName())) do
				-- style corresponds to an C++ object; ensure its name matches that of a valid style for this game
				if  style == _style:GetName():lower()
				-- difficulty, stepstype, and styletype are C++ enums; ensure the string values we retrieved are valid
				and Difficulty:Reverse()[diff_str]     ~= nil
				and StepsType:Reverse()[stepstype_str] ~= nil
				and StyleType:Reverse()[styletype_str] ~= nil
				then

					-- ensure the correct number of players is joined for this StyleType
					----------------------------------------------------------------------
					-- unjoin any human players
					for player in ivalues(GAMESTATE:GetHumanPlayers()) do GAMESTATE:UnjoinPlayer(player) end

					-- most styles require that only one player be joined
					-- and ScreenEditMenu.cpp is currently hardcoded to use PLAYER_1 for those
					GAMESTATE:JoinPlayer(PLAYER_1)

					-- but some styles (couple, routine) need both players joined
					if style == "couple" or style == "routine" then
						GAMESTATE:JoinPlayer(PLAYER_2)
					end
					----------------------------------------------------------------------

					-- style MUST be set before setting steps or SM will crash
					GAMESTATE:SetCurrentStyle( style )

					-- ensure style has really been set
					if GAMESTATE:GetCurrentStyle() ~= nil then
						-- set steps
						local steps = song:GetOneSteps(stepstype_str, diff_str)
						GAMESTATE:SetCurrentSteps(PLAYER_1, steps)
						break
					end
				end
			end
		end
	end
end

-- -----------------------------------------------------------------------

return Def.Actor{
	OffCommand=function()
		local song = GAMESTATE:GetCurrentSong()

		if song then
			-- the string returned by song:GetSongDir() isn't usable by SONGMAN:FindSong()
			-- so build a string like "/Group Name/Song Name"
			local songpath = ("/%s/%s"):format(song:GetGroupName(), Basename(song:GetSongDir()))

			local steps = GAMESTATE:GetCurrentSteps(PLAYER_1)
			if steps then
				local difficulty = steps:GetDifficulty()
				local stepstype  = steps:GetStepsType()
				local styletype  = GAMESTATE:GetCurrentStyle():GetStyleType()

				if difficulty and stepstype and styletype then
					ThemePrefs.Set("EditModeLastSeenSong",       songpath)
					ThemePrefs.Set("EditModeLastSeenStepsType",  stepstype)
					ThemePrefs.Set("EditModeLastSeenStyleType",  styletype)
					ThemePrefs.Set("EditModeLastSeenDifficulty", difficulty)
					ThemePrefs.Save()
				end
			end
		end
	end
}