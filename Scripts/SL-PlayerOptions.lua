------------------------------------------------------------
-- Helper Functions for PlayerOptions
------------------------------------------------------------

local function GetModsAndPlayerOptions(player)
	local mods = SL[ToEnumShortString(player)].ActiveModifiers
	local topscreen = SCREENMAN:GetTopScreen():GetName()
	local modslevel = topscreen  == "ScreenEditOptions" and "ModsLevel_Stage" or "ModsLevel_Preferred"
	local playeroptions = GAMESTATE:GetPlayerState(player):GetPlayerOptions(modslevel)

	return mods, playeroptions
end

------------------------------------------------------------
-- when to use Choices() vs. Values()
--
-- Each OptionRow needs stringified choices to present to the player.  Sometimes using hardcoded strings
-- is okay. For example, SpeedModType choices (x, C, M) are the same in English as in French.
--
-- Other times, we need to be able to localize the choices presented to the player but also
-- maintain an internal value that code within the theme can rely on regardless of language.
--
-- For each of the subtables in Overrides, you must specify a 'Choices' function and/or a 'Values' function
-- that returns a table of strings of valid choices.
--
-- If you specify only 'Choices', the engine presents the strings exactly as-is and also uses those
-- same strings internally.
--
-- If you specify only 'Values', the engine will use those raw strings internally but localize them
-- using the corresponding display strings in en.ini (or es.ini, fr.ini, etc.) for the user.
--
-- If you specify both, then the strings in 'Choices' are presented as-is,
-- but the strings in 'Values' are what the theme stores into the ActiveModifiers table.

------------------------------------------------------------

-- Define SL's custom OptionRows that appear in ScreenPlayerOptions as subtables within Overrides.
-- As an OptionRow, each subtable is expected to have specific key/value pairs:
--
-- ExportOnChange (boolean)
-- 		false if unspecified; if true, calls SaveSelections() whenever the current choice changes
-- LayoutType (string)
--		"ShowAllInRow" if unspecified; you can set it to "ShowOneInRow" if needed
-- OneChoiceForAllPlayers (boolean)
-- 		false if unspecified
-- SelectType (string)
-- 		"SelectOne" if unspecified; you can set it to "SelectMultiple" if needed
-- LoadSelections (function)
-- 		normally (in other themes) called when the PlayerOption screen initializes
--		read the notes surrounding ApplyMods() for further discussion of additional work SL does
-- SaveSelections (function)
-- 		this is where you should do whatever work is needed to ensure that the player's choice
--		persists beyond the PlayerOptions screen; normally called around the time of ScreenPlayerOption's
--		OffCommand; can also be called because ExportOnChange=true


-- It's not necessary to define each possible key for each OptionRow.  Anything you don't specifiy
-- will use fallback values in OptionRowDefault (defined later, below).

local Overrides = {

	-------------------------------------------------------------------------
	SpeedModType = {
		Choices = function() return { "x", "C", "M" } end,
		ExportOnChange = true,
		LayoutType = "ShowOneInRow",
		SaveSelections = function(self, list, pn)
			for i=1,#list do
				if list[i] then
					-- Broadcast a message that ./BGAnimations/ScreenPlayerOptions overlay.lua will be listening for
					-- so it can hackishly modify the single BitmapText actor used in the SpeedMod optionrow
					MESSAGEMAN:Broadcast('SpeedModType'..ToEnumShortString(pn)..'Set', {SpeedModType=self.Choices[i]})
				end
			end
		end
	},
	-------------------------------------------------------------------------
	SpeedMod = {
		Choices = function() return { "       " } end,
		ExportOnChange = true,
		LayoutType = "ShowOneInRow",
		LoadSelections = function(self, list, pn)
			list[1] = true
		end,
		SaveSelections = function(self, list, pn)
			local mods, playeroptions = GetModsAndPlayerOptions(pn)
			local type 	= mods.SpeedModType or "x"
			local speed = mods.SpeedMod or 1.00

			-- it's necessary to manually apply a speedmod of 1x first, otherwise speedmods stack?
			playeroptions:XMod(1.00)

			if type == "x" then
				playeroptions:XMod(speed)
			elseif type == "C" then
				playeroptions:CMod(speed)
			elseif type == "M" then
				playeroptions:MMod(speed)
			end

		end
	},
	-------------------------------------------------------------------------
	NoteSkin = {
		ExportOnChange = true,
		LayoutType = "ShowOneInRow",
		Choices = function()

			local all = NOTESKIN:GetNoteSkinNames()

			if ThemePrefs.Get("HideStockNoteSkins") then

				-- Apologies, midiman. :(
				local stock = {
					"default", "delta", "easyv2", "exactv2", "lambda", "midi-note",
					"midi-note-3d", "midi-rainbow", "midi-routine-p1", "midi-routine-p2",
					"midi-solo", "midi-vivid", "midi-vivid-3d", "retro",
					"retrobar", "retrobar-splithand_whiteblue"
				}

				for stock_noteskin in ivalues(stock) do
					for i=1,#all do
						if stock_noteskin == all[i] then
							table.remove(all, i)
							break
						end
					end
				end
			end

			-- It's possible a user might want to hide stock notesksins
			-- but only have stock noteskins.  If so, just return all noteskins.
			if #all == 0 then all = NOTESKIN:GetNoteSkinNames() end

			return all
		end,
		SaveSelections = function(self, list, pn)
			local mods, playeroptions = GetModsAndPlayerOptions(pn)
			for i, val in ipairs(self.Choices) do
				if list[i] then mods.NoteSkin = val; break end
			end
			-- Broadcast a message that ./Graphics/OptionRow Frame.lua will be listening for so it can change the NoteSkin preview
			MESSAGEMAN:Broadcast('NoteSkinChanged', {Player=pn, NoteSkin=mods.NoteSkin})
			playeroptions:NoteSkin( mods.NoteSkin )
		end
	},
	-------------------------------------------------------------------------
	JudgmentGraphic = {
		LayoutType = "ShowOneInRow",
		ExportOnChange = true,
		Choices = function() return map(StripSpriteHints, GetJudgmentGraphics(SL.Global.GameMode)) end,
		Values = function() return GetJudgmentGraphics(SL.Global.GameMode) end,
		SaveSelections = function(self, list, pn)
			local mods = SL[ToEnumShortString(pn)].ActiveModifiers
			for i, val in ipairs(self.Values) do
				if list[i] then mods.JudgmentGraphic = val; break end
			end
			-- Broadcast a message that ./Graphics/OptionRow Frame.lua will be listening for so it can change the Judgment preview
			MESSAGEMAN:Broadcast("JudgmentGraphicChanged", {Player=pn, JudgmentGraphic=StripSpriteHints(mods.JudgmentGraphic)})
		end
	},
	-------------------------------------------------------------------------
	BackgroundFilter = {
		Values = function() return { 'Off','Dark','Darker','Darkest' } end,
	},
	-------------------------------------------------------------------------
	Mini = {
		Choices = function()
			local first	= -100
			local last 	= 150
			local step 	= 5

			return stringify( range(first, last, step), "%g%%")
		end,
		SaveSelections = function(self, list, pn)
			local mods, playeroptions = GetModsAndPlayerOptions(pn)

			for i=1,#self.Choices do
				if list[i] then
					mods.Mini = self.Choices[i]
				end
			end

			-- to make the arrows smaller, pass Mini() a value between 0 and 1
			-- (to make the arrows bigger, pass Mini() a value larger than 1)
			playeroptions:Mini( mods.Mini:gsub("%%","")/100 )
		end
	},
	-------------------------------------------------------------------------
	MusicRate = {
		Choices = function()
			local first	= 0.05
			local last 	= 2
			local step 	= 0.01

			return stringify( range(first, last, step), "%g")
		end,
		ExportOnChange = true,
		OneChoiceForAllPlayers = true,
		LoadSelections = function(self, list, pn)
			local rate = ("%g"):format( SL.Global.ActiveModifiers.MusicRate )
			local i = FindInTable(rate, self.Choices) or 1
			list[i] = true
			return list
		end,
		SaveSelections = function(self, list, pn)

			local mods = SL.Global.ActiveModifiers

			for i=1,#self.Choices do
				if list[i] then
					mods.MusicRate = tonumber( self.Choices[i] )
				end
			end

			local topscreen = SCREENMAN:GetTopScreen():GetName()

			-- Use the older GameCommand interface for applying rate mods in Edit Mode;
			-- it seems to be the only way (probably due to how broken Edit Mode is, in general).
			-- As an unintentional side-effect of setting musicrate mods this way, they STAY set
			-- (between songs, between screens, etc.) until you manually change them.  This is (probably)
			-- not the desired behavior in EditMode, so when users change between different songs in EditMode,
			-- always reset the musicrate mod.  See: ./BGAnimations/ScreenEditMeny underlay.lua
			if topscreen == "ScreenEditOptions" then
				GAMESTATE:ApplyGameCommand("mod," .. mods.MusicRate .."xmusic")
			else
				GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):MusicRate( mods.MusicRate )
			end

			MESSAGEMAN:Broadcast("MusicRateChanged")
		end
	},
	-------------------------------------------------------------------------
	Hide = {
		SelectType = "SelectMultiple",
		Values = function() return { "Targets", "SongBG", "Combo", "Lifebar", "Score", "Danger", "ComboExplosions" } end,
		LoadSelections = function(self, list, pn)
			local mods = SL[ToEnumShortString(pn)].ActiveModifiers
			list[1] = mods.HideTargets 	or false
			list[2] = mods.HideSongBG 	or false
			list[3] = mods.HideCombo 	or false
			list[4] = mods.HideLifebar 	or false
			list[5] = mods.HideScore 	or false
			list[6] = mods.HideDanger	or false
			list[7] = mods.HideComboExplosions or false
			return list
		end,
		SaveSelections = function(self, list, pn)
			local mods, playeroptions = GetModsAndPlayerOptions(pn)
			mods.HideTargets= list[1]
			mods.HideSongBG = list[2]
			mods.HideCombo	= list[3]
			mods.HideLifebar= list[4]
			mods.HideScore	= list[5]
			mods.HideDanger = list[6]
			mods.HideComboExplosions = list[7]

			playeroptions:Dark(mods.HideTargets and 1 or 0)
			playeroptions:Cover(mods.HideSongBG and 1 or 0)
		end,
	},
	-------------------------------------------------------------------------
	DataVisualizations = {
		Values = function()
			local choices = { "Disabled", "Target Score Graph", "Step Statistics" }

			-- Disabled and Target Score Graph should always be available to players
			-- but Step Statistics needs a lot of space and isn't always possible
			-- remove it as an available option if we aren't in single or if the current
			-- notefield width already uses more than half the screen width

			if GAMESTATE:GetCurrentStyle():GetName() ~= "single"
			or GetNotefieldWidth( GAMESTATE:GetMasterPlayerNumber() ) > _screen.w/2 then
				table.remove(choices, 3)
			end

			return choices
		end,
	},
	-------------------------------------------------------------------------
	TargetScore = {
		Values = function()
			return { 'C-', 'C', 'C+', 'B-', 'B', 'B+', 'A-', 'A', 'A+', 'S-', 'S', 'S+', '☆', '☆☆', '☆☆☆', '☆☆☆☆', 'Machine best', 'Personal best' }
		end,
		LoadSelections = function(self, list, pn)
			local i = tonumber(SL[ToEnumShortString(pn)].ActiveModifiers.TargetScore) or 11
			list[i] = true
			return list
		end,
		SaveSelections = function(self, list, pn)
			for i,v in ipairs(self.Values) do
				if list[i] then SL[ToEnumShortString(pn)].ActiveModifiers.TargetScore = i; break end
			end
		end
	},
	-------------------------------------------------------------------------
	ActionOnMissedTarget = {
		Values = function() return { "Nothing", "Fail", "Restart" } end,
	},
	-------------------------------------------------------------------------
	GameplayExtras = {
		SelectType = "SelectMultiple",
		Values = function()
			local vals = { "ColumnFlashOnMiss", "SubtractiveScoring", "Pacemaker", "MissBecauseHeld", "NPSGraphAtTop" }
			if SL.Global.GameMode == "StomperZ" then table.remove(vals, 5) end
			return vals
		end,
	},
	-------------------------------------------------------------------------
	MeasureCounter = {
		Values = function() return { "None", "8th", "12th", "16th", "24th", "32nd" } end,
	},
	-------------------------------------------------------------------------
	MeasureCounterOptions = {
		SelectType = "SelectMultiple",
		Values = function() return { "MeasureCounterLeft", "MeasureCounterUp", "HideRestCounts" } end,
	},
	-------------------------------------------------------------------------
	WorstTimingWindow = {
		Choices = function()
			local tns = "TapNoteScore" .. (SL.Global.GameMode=="Competitive" and "" or SL.Global.GameMode)
			local t = {THEME:GetString("SLPlayerOptions","None")}
			-- assume pluralization via terminal s
			t[2] = THEME:GetString(tns,"W5").."s"
			t[3] = THEME:GetString(tns,"W4").."s + "..t[2]
			t[4] = THEME:GetString("SLPlayerOptions","All")
			return t
		end,
		OneChoiceForAllPlayers = true,
		LoadSelections = function(self, list, pn)
			local worst = SL.Global.ActiveModifiers.WorstTimingWindow
			if 	worst==5 then list[1] = true
			elseif 	worst==4 then list[2] = true
			elseif 	worst==3 then list[3] = true
			elseif 	worst==0 then list[4] = true
			end
			return list
		end,
		SaveSelections = function(self, list, pn)
			local gmods = SL.Global.ActiveModifiers

			if 	list[1] then gmods.WorstTimingWindow=5
			elseif 	list[2] then gmods.WorstTimingWindow=4
			elseif 	list[3] then gmods.WorstTimingWindow=3
			elseif 	list[4] then gmods.WorstTimingWindow=0
			end

			-- loop 5 times to set the 5 TimingWindows appropriately
			for i=1,5 do
				if i <= gmods.WorstTimingWindow then
					PREFSMAN:SetPreference("TimingWindowSecondsW"..i, SL.Preferences[SL.Global.GameMode]["TimingWindowSecondsW"..i])
				else
					if PREFSMAN:PreferenceExists("TimingWindowSecondsW"..gmods.WorstTimingWindow) then
						PREFSMAN:SetPreference("TimingWindowSecondsW"..i, SL.Preferences[SL.Global.GameMode]["TimingWindowSecondsW"..gmods.WorstTimingWindow])
					else
						PREFSMAN:SetPreference("TimingWindowSecondsW"..i, 0)
					end
				end
			end
		end
	},
	-------------------------------------------------------------------------
	Vocalization = {
		Choices = function()
			-- Allow users to artbitrarily add new vocalizations to ./Simply Love/Other/Vocalize/
			-- and have those vocalizations be automatically detected
			local vocalizations = FILEMAN:GetDirListing(GetVocalizeDir() , true, false)
			table.insert(vocalizations, 1, "None")

			if #vocalizations > 1 then
				vocalizations[#vocalizations+1] = "Random"
				vocalizations[#vocalizations+1] = "Blender"
			end
			return vocalizations
		end
	},
	-------------------------------------------------------------------------
	ReceptorArrowsPosition = {
		Choices = function() return { "StomperZ", "ITG" } end,
	},
	-------------------------------------------------------------------------
	LifeMeterType = {
		Values = function() return { "Standard", "Surround", "Vertical" } end,
	},
	-------------------------------------------------------------------------
	ScreenAfterPlayerOptions = {
		Values = function()
			if SL.Global.MenuTimer.ScreenSelectMusic > 1 then
				return { 'Gameplay', 'Select Music', 'Extra Modifiers' }
			else
				return { 'Gameplay', 'Extra Modifiers' }
			end
		end,
		OneChoiceForAllPlayers = true,
		LoadSelections = function(self, list, pn)
			list[1] = true
			return list
		end,
		SaveSelections = function(self, list, pn)
			if SL.Global.MenuTimer.ScreenSelectMusic > 1 then
				if list[1] then SL.Global.ScreenAfter.PlayerOptions = Branch.GameplayScreen() end
				if list[2] then SL.Global.ScreenAfter.PlayerOptions = SelectMusicOrCourse() end
				if list[3] then SL.Global.ScreenAfter.PlayerOptions = "ScreenPlayerOptions2" end
			else
				if list[1] then SL.Global.ScreenAfter.PlayerOptions = Branch.GameplayScreen() end
				if list[2] then SL.Global.ScreenAfter.PlayerOptions = "ScreenPlayerOptions2" end
			end
		end
	},
	-------------------------------------------------------------------------
	ScreenAfterPlayerOptions2 = {
		Values = function()
			if SL.Global.MenuTimer.ScreenSelectMusic > 1 then
				return { 'Gameplay', 'Select Music', 'Normal Modifiers' }
			else
				return { 'Gameplay', 'Normal Modifiers' }
			end
		end,
		OneChoiceForAllPlayers = true,
		LoadSelections = function(self, list, pn)
			list[1] = true
			return list
		end,
		SaveSelections = function(self, list, pn)
			if SL.Global.MenuTimer.ScreenSelectMusic > 1 then
				if list[1] then SL.Global.ScreenAfter.PlayerOptions2 = Branch.GameplayScreen() end
				if list[2] then SL.Global.ScreenAfter.PlayerOptions2 = SelectMusicOrCourse() end
				if list[3] then SL.Global.ScreenAfter.PlayerOptions2 = "ScreenPlayerOptions" end
			else
				if list[1] then SL.Global.ScreenAfter.PlayerOptions2 = Branch.GameplayScreen() end
				if list[2] then SL.Global.ScreenAfter.PlayerOptions2 = "ScreenPlayerOptions" end
			end
		end
	}
	-------------------------------------------------------------------------
}


------------------------------------------------------------
-- Generic OptionRow Definition
------------------------------------------------------------
local OptionRowDefault = {
	-- the __index metatable will serve to define a completely generic OptionRow
	__index = {
		initialize = function(self, name)

			self.Name = name

			if Overrides[name].Values then
				if Overrides[name].Choices then
					self.Choices = Overrides[name].Choices()
				else
					self.Choices = {}
					for i, v in ipairs( Overrides[name].Values() ) do
						self.Choices[i] = THEME:GetString("SLPlayerOptions", v)
					end
				end
				self.Values = Overrides[name].Values()
			else
				self.Choices = Overrides[name].Choices()
			end

			-- define fallback values to use here if an override isn't specified
			self.LayoutType = Overrides[name].LayoutType or "ShowAllInRow"
			self.SelectType = Overrides[name].SelectType or "SelectOne"
			self.OneChoiceForAllPlayers = Overrides[name].OneChoiceForAllPlayers or false
			self.ExportOnChange = Overrides[name].ExportOnChange or false


			if self.SelectType == "SelectOne" then

				self.LoadSelections = Overrides[name].LoadSelections or function(subself, list, pn)
					local mods, playeroptions = GetModsAndPlayerOptions(pn)
					local choice = mods[name] or (playeroptions[name] ~= nil and playeroptions[name](playeroptions)) or self.Choices[1]
					local i = FindInTable(choice, (self.Values or self.Choices)) or 1
					list[i] = true
					return list
				end
				self.SaveSelections = Overrides[name].SaveSelections or function(subself, list, pn)
					local mods = SL[ToEnumShortString(pn)].ActiveModifiers
					local vals = self.Values or self.Choices
					for i, val in ipairs(vals) do
						if list[i] then mods[name] = val; break end
					end
				end

			else
				-- "SelectMultiple" typically means a collection of theme-defined flags in a single OptionRow
				-- most of these behave the same and can fall back on this generic definition; a notable exception is "Hide"
				self.LoadSelections = Overrides[name].LoadSelections or function(subself, list, pn)
					local mods = SL[ToEnumShortString(pn)].ActiveModifiers
					local vals = self.Values or self.Choices
					for i, mod in ipairs(vals) do
						list[i] = mods[mod] or false
					end
					return list
				end
				self.SaveSelections = Overrides[name].SaveSelections or function(subself, list, pn)
					local mods = SL[ToEnumShortString(pn)].ActiveModifiers
					local vals = self.Values or self.Choices
					for i, mod in ipairs(vals) do
						mods[mod] = list[i]
					end
				end
			end

			return self
		end
	}
}


function CustomOptionRow( name )
	-- assign the properties of the generic OptionRowDefault to OptRow
	local OptRow = setmetatable( {}, OptionRowDefault )

	-- now that OptRow has the method available, run its initialize() method
	return OptRow:initialize( name )
end


-- Mods are applied in their respective SaveSelections() functions when
-- ScreenPlayerOptions receives its OffCommand(), but what happens
-- if a player expects mods to have been set via a profile,
-- and thus never visits ScreenPlayerOptions?
--
-- Thus, we have this global function, ApplyMods()
-- which we can call from
-- ./BGAnimations/ScreenProfileLoad overlay.lua
-- as well as the the PlayerJoinedMessageCommand of
-- /BGAnimations/ScreenSelectMusic overlay/PlayerModifiers.lua
-- the former handles "normally" joined players, and the latter handles latejoin

function ApplyMods(player)
	for name,value in pairs(Overrides) do
		OptRow = CustomOptionRow( name )

		-- LoadSelections() and SaveSelections() expect two arguments in addtion to self (the OptionRow)
		-- first, a table of true/false values corresponding to the OptionRow's Choices table
		-- second, the player that this applies to
		--
		-- LoadSelections() receives a table of all false values, one for each entry in this OptionRow's Choices table
		-- LoadSelections() will process that table, and set the appropriate entries to true using the SL[pn].ActiveModifiers table
		-- when done setting one or more entries to true, LoadSelections() will return that table of true/false values
		--
		-- SaveSelections() expects the same sort of arguments, but it expects the true/false table to be already set appropriately
		-- thus, we pass in the list that was returned from LoadSelections()
		local list = {}
		for i=1, #OptRow.Choices do
			list[i] = false
		end
		list = OptRow:LoadSelections( list, player )
		OptRow:SaveSelections( list, player )
	end
end
