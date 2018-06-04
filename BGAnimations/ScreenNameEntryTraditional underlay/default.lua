local AlphabetWheels = {}
local Players = GAMESTATE:GetHumanPlayers()

---------------------------------------------------------------------------
-- The number of stages that were played this game cycle
local NumStages = SL.Global.Stages.PlayedThisGame
-- The duration (in seconds) each stage should display onscreen before cycling to the next
local DurationPerStage = 4
---------------------------------------------------------------------------
for player in ivalues(Players) do
	if SL[ToEnumShortString(player)].HighScores.EnteringName then
		-- Add one AlphabetWheel per human player
		AlphabetWheels[ToEnumShortString(player)] = setmetatable({}, sick_wheel_mt)
	end
end
---------------------------------------------------------------------------
-- Add the reusable metatable for a generic alphabet character
local alphabet_character_mt = LoadActor("./AlphabetCharacterMT.lua")

---------------------------------------------------------------------------
-- Alphanumeric Characters available to our players for highscore name use
local PossibleCharacters = {
	"&BACK;", "&OK;",
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
	"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
	"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "?", "!"
}
---------------------------------------------------------------------------
-- Primary ActorFrame
local t = Def.ActorFrame {
	InitCommand=function(self)
		self:queuecommand("CaptureInput")
	end,
	CaptureInputCommand=function(self)
		local topscreen = SCREENMAN:GetTopScreen()

		for player in ivalues(Players) do
			local wheel = AlphabetWheels[ToEnumShortString(player)]

			if wheel then
				local profile = PROFILEMAN:GetProfile(player)
				-- if a profile is in use and has a HighScoreName, make the starting index 2 ("ok"); otherwise, 3 ("A")
				local StartingCharIndex = (profile and (profile:GetLastUsedHighScoreName() ~= "") and 2) or 3

				-- set_info_set() takes two arguments:
				--		a table of meaningful data to divvy up to wheel items
				--		the index of which wheel item we want to initially give focus to
				-- here, we are passing it all the possible characters,
				-- and either 2 ("ok") or 3 ("A") as the starting index
				AlphabetWheels[ToEnumShortString(player)]:set_info_set(PossibleCharacters, StartingCharIndex)
			end
		end

		-- actually attach the InputHandler function to our screen
		topscreen:AddInputCallback( LoadActor("InputHandler.lua", {self, AlphabetWheels}) )
	end,
	AttemptToFinishCommand=function(self)
		if not SL.P1.HighScores.EnteringName and not SL.P2.HighScores.EnteringName then
			self:playcommand("Finish")
		end
	end,
	MenuTimerExpiredCommand=function(self, param)

		-- if the timer runs out, check if either player hasn't finished entering his/her name
		-- if so, fade out that player's cursor and alphabetwheel and play the "start" sound
		for player in ivalues(Players) do
			local pn = ToEnumShortString(player)
			if SL[pn].HighScores.EnteringName then
				-- hide this player's cursor
				self:GetChild("PlayerNameAndDecorations_"..pn):GetChild("Cursor"):queuecommand("Hide")
				-- hide this player's AlphabetWheel
				self:GetChild("AlphabetWheel_"..pn):queuecommand("Hide")
				-- play the "enter" sound
				self:GetChild("enter"):playforplayer(player)
			end
		end

		self:playcommand("Finish")
	end,
	FinishCommand=function(self)
		-- store the highscore name for this game
		for player in ivalues(Players) do
			GAMESTATE:StoreRankingName(player, SL[ToEnumShortString(player)].HighScores.Name)

			-- if a profile is in use
			if PROFILEMAN:IsPersistentProfile(player) then
				-- update that profile's LastUsedHighScoreName attribute
				PROFILEMAN:GetProfile(player):SetLastUsedHighScoreName( SL[ToEnumShortString(player)].HighScores.Name )
			end
		end

		-- manually transition to the next screen (defined in Metrics)
		SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
	end
}

local banner_directory = { Hearts="Hearts", Arrows="Arrows" }
-- Things that are constantly on the screen (fallback banner + masks)
t[#t+1] = Def.ActorFrame {

	--fallback banner
	LoadActor( THEME:GetPathB("ScreenSelectMusic", "overlay/colored_banners/".. (banner_directory[ThemePrefs.Get("VisualTheme")] or "Hearts") .."/banner"..SL.Global.ActiveColorIndex.." (doubleres).png"))..{
		OnCommand=cmd(xy, _screen.cx, 121.5; zoom, 0.7)
	},

	Def.Quad{
		Name="LeftMask";
		InitCommand=cmd(halign,0),
		OnCommand=cmd(xy, 0, _screen.cy; zoomto, _screen.cx-272, _screen.h; MaskSource)
	},

	Def.Quad{
		Name="CenterMask",
		OnCommand=cmd(Center; zoomto, 110, _screen.h; MaskSource)
	},

	Def.Quad{
		Name="RightMask",
		InitCommand=cmd(halign,1),
		OnCommand=cmd(xy, _screen.w, _screen.cy; zoomto, _screen.cx-272, _screen.h; MaskSource)
	}
}

-- Banner(s) and Title(s)
for i=1,NumStages do

	local SongOrCourse = SL.Global.Stages.Stats[i].song

	-- Create an ActorFrame for each (Name + Banner) pair
	-- so that we can display/hide all children simultaneously.
	local SongNameAndBanner = Def.ActorFrame{
		InitCommand=function(self) self:visible(false) end,
		OnCommand=function(self)
			self:sleep(DurationPerStage * (i-1) );
			self:queuecommand("Display")
		end,
		DisplayCommand=function(self)
			self:visible(true)
			self:sleep(DurationPerStage)
			self:queuecommand("Wait")
		end,
		WaitCommand=function(self)
			self:visible(false)
			self:sleep(DurationPerStage * (NumStages-1))
			self:queuecommand("Display")
		end
	}

	-- song name
	SongNameAndBanner[#SongNameAndBanner+1] = LoadFont("_miso")..{
		Name="SongName"..i,
		InitCommand=cmd(xy, _screen.cx, 54; maxwidth, 294),
		OnCommand=function(self)
			if SongOrCourse then
				self:settext( GAMESTATE:IsCourseMode() and SongOrCourse:GetDisplayFullTitle() or SongOrCourse:GetDisplayMainTitle() )
			end
		end
	}

	-- song banner
	SongNameAndBanner[#SongNameAndBanner+1] = Def.Banner{
		Name="SongBanner"..i,
		InitCommand=cmd(xy, _screen.cx, 121.5),
		OnCommand=function(self)
			if SongOrCourse then
				if GAMESTATE:IsCourseMode() then
					self:LoadFromCourse(SongOrCourse)
				else
					self:LoadFromSong(SongOrCourse)
				end
				self:setsize(418,164):zoom(0.7)
			end
		end
	}

	-- add each SongNameAndBanner ActorFrame to the primary ActorFrame
	t[#t+1] = SongNameAndBanner
end


for player in ivalues(Players) do
	local pn = ToEnumShortString(player)
	local x_offset = (player == PLAYER_1 and -120) or 200

	t[#t+1] = LoadActor("PlayerNameAndDecorations.lua", player)
	t[#t+1] = LoadActor("./HighScores.lua", player)

	-- this returns an ActorFrame ( see: ./Scripts/Consensual-sick_wheel.lua )
	-- create_actors() takes five arguments
	--		a name
	--		the number of wheel actors to actually create onscreen
	--			note that this is NOT equal to how many items you want to be able to scroll through
	--			it is how many you want visually onscreen at a given moment
	--		a metatable defining a generic item in the wheel
	--		x position
	--		y position
	if SL[pn].HighScores.EnteringName then
		t[#t+1] = AlphabetWheels[pn]:create_actors( "AlphabetWheel_"..pn, 7, alphabet_character_mt, _screen.cx + x_offset, _screen.cy+38)
	end
end

-- ActorSounds
t[#t+1] = LoadActor( THEME:GetPathS("", "_change value"))..{ Name="delete", SupportPan = true }
t[#t+1] = LoadActor( THEME:GetPathS("Common", "start"))..{ Name="enter", SupportPan = true }
t[#t+1] = LoadActor( THEME:GetPathS("MusicWheel", "change"))..{ Name="move", SupportPan = true }
t[#t+1] = LoadActor( THEME:GetPathS("common", "invalid"))..{ Name="invalid", SupportPan = true }

--
return t
