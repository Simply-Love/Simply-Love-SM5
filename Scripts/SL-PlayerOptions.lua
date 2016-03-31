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
-- Define what custom OptionRows there are, and override the
-- generic OptionRow (defined later, below) for each as necessary.

local Overrides = {

	-------------------------------------------------------------------------
	SpeedModType = {
		Choices = function() return { "x", "C", "M" } end,
		ExportOnChange = true,
		LayoutType = "ShowOneInRow",
		SaveSelections = function(self, list, pn)
			for i=1,#list do
				if list[i] then
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
		Choices = function()

			local all = NOTESKIN:GetNoteSkinNames()

			if ThemePrefs.Get("HideStockNoteSkins") then

				-- Apologies, midiman. :(
				local stock = {
					"default", "delta", "easyv2", "exactv2", "midi-note",
					"midi-note-3d", "midi-routine-p1", "midi-routine-p2",
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
		LoadSelections = function(self, list, pn)
			local mods, playeroptions = GetModsAndPlayerOptions(pn)
			local choice = mods.NoteSkin or playeroptions:NoteSkin() or "default"
			local i = FindInTable(choice, self.Choices) or 1
			list[i] = true
		end,
		SaveSelections = function(self, list, pn)
			local mods, playeroptions = GetModsAndPlayerOptions(pn)

			for i=1,#list do
				if list[i] then
					mods.NoteSkin = self.Choices[i]
				end
			end

			playeroptions:NoteSkin( mods.NoteSkin )
		end
	},
	-------------------------------------------------------------------------
	JudgmentGraphic = {
		Choices = function()

			-- Allow users to artbitrarily add new judgment graphics to /Graphics/_judgments/
			-- without needing to modify this script;
			-- instead of hardcoding a list of judgment fonts, get directory listing via FILEMAN.
			local path = THEME:GetPathG("","_judgments")
			local files = FILEMAN:GetDirListing(path.."/")
			local judgmentGraphics = {}

			for k,filename in ipairs(files) do

				-- A user might put something that isn't a suitable judgment graphic
				-- into /Graphics/_judgments/ (also sometimes hidden files like .DS_Store show up here).
				-- Do our best to filter out such files now.
				if string.match(filename, " %dx%d") then
					-- use regexp to get only the name of the graphic, stripping out the extension
					local name = filename:gsub(" %dx%d", ""):gsub(" %(doubleres%)", ""):gsub(".png", "")

					-- The 3_9 graphic is a special case;
					-- we want it to appear in the options with a period (3.9 not 3_9).
					if name == "3_9" then name = "3.9" end

					-- Dynamically fill the table.
					-- Love is a special case; it should always be first.
					if name == "Love" then
						table.insert(judgmentGraphics, 1, name)
					else
						judgmentGraphics[#judgmentGraphics+1] = name
					end
				end
			end

			-- always have "None" appear last
			judgmentGraphics[#judgmentGraphics+1] = "None"

			return judgmentGraphics
		end
	},
	-------------------------------------------------------------------------
	BackgroundFilter = {
		Choices = function() return { 'Off','Dark','Darker','Darkest' } end,
		LoadSelections = function(self, list, pn)
			local mods, playeroptions = GetModsAndPlayerOptions(pn)
			local choice = mods.BackgroundFilter or "Off"
			local i = FindInTable(choice, self.Choices) or 1
			list[i] = true
		end,
	},
	-------------------------------------------------------------------------
	Mini = {
		Choices = function()

			local first	= -100
			local last 	= 150
			local step 	= 5

			local rates = stringify( range(first, last, step), "%g%%")
			return rates
		end,
		LoadSelections = function(self, list, pn)
			local mods, playeroptions = GetModsAndPlayerOptions(pn)
			local choice = mods.Mini or playeroptions:Mini() or "0%"
			local i = FindInTable(choice, self.Choices) or 1
			list[i] = true
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
			local step 	= 0.05

			return stringify( range(first, last, step), "%g")
		end,
		ExportOnChange = true,
		OneChoiceForAllPlayers = true,
		LoadSelections = function(self, list, pn)
			local rate = ("%g"):format( SL.Global.ActiveModifiers.MusicRate )
			local i = FindInTable(rate, self.Choices) or 1
			list[i] = true
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
		Choices = function() return { "Targets", "Background", "Combo", "Life", "Score" } end,
		LoadSelections = function(self, list, pn)
			local mods = SL[ToEnumShortString(pn)].ActiveModifiers
			list[1] = mods.HideTargets 	or false
			list[2] = mods.HideSongBG 	or false
			list[3] = mods.HideCombo 	or false
			list[4] = mods.HideLifebar 	or false
			list[5] = mods.HideScore 	or false
		end,
		SaveSelections = function(self, list, pn)
			local mods, playeroptions = GetModsAndPlayerOptions(pn)
			mods.HideTargets= list[1]
			mods.HideSongBG = list[2]
			mods.HideCombo	= list[3]
			mods.HideLifebar= list[4]
			mods.HideScore	= list[5]

			-- ApplyHide(pn)
			playeroptions:Dark(mods.HideTargets and 1 or 0)
			playeroptions:Cover(mods.HideSongBG and 1 or 0)
		end,
	},
	-------------------------------------------------------------------------
	GameplayExtras = {
		SelectType = "SelectMultiple",
		Choices = function() return { "Flash Column for Miss", "Subtractive Scoring"} end,
		LoadSelections = function(self, list, pn)
			local mods = SL[ToEnumShortString(pn)].ActiveModifiers
			list[1] = mods.ColumnFlashOnMiss	or false
			list[2] = mods.SubtractiveScoring 	or false
		end,
		SaveSelections = function(self, list, pn)
			local mods = SL[ToEnumShortString(pn)].ActiveModifiers
			mods.ColumnFlashOnMiss	= list[1]
			mods.SubtractiveScoring	= list[2]
		end
	},
	-------------------------------------------------------------------------
	MeasureCounter = {
		Choices = function() return { "None", "8th", "12th", "16th", "24th", "32nd" } end,
		LoadSelections = function(self, list, pn)
			local choice = SL[ToEnumShortString(pn)].ActiveModifiers.MeasureCounter or "None"
			local i = FindInTable(choice, self.Choices) or 1
			list[i] = true
		end,
		SaveSelections = function(self, list, pn)
			local mods, playeroptions = GetModsAndPlayerOptions(pn)

			for i=1,#list do
				if list[i] then
					mods.MeasureCounter = self.Choices[i]
				end
			end
		end
	},
	-------------------------------------------------------------------------
	Vocalize = {
		Choices = function()
			-- Allow users to artbitrarily add new vocalizations to ./Simply Love/Other/Vocalize/
			-- and have those vocalizations be automatically detected
			local files = FILEMAN:GetDirListing(GetVocalizeDir() , true, false)
			local vocalizations = { "None" }

			for k,dir in ipairs(files) do
				-- Dynamically fill the table.
				vocalizations[#vocalizations+1] = dir
			end

			if #vocalizations > 1 then
				vocalizations[#vocalizations+1] = "Random"
				vocalizations[#vocalizations+1] = "Blender"
			end
			return vocalizations
		end
	},
	-------------------------------------------------------------------------
	-- It is potentially dangerous to be modifying global StepMania preferences via the PlayerOptions menu
	-- Unless you, the themer, explicitly reset TimingWindowScale back to 1.0 after each game cycle
	-- It will REMAIN changed between games, between reboots of StepMania, and between Themes.
	-- After all, it's a global preference and not the sort of thing that was never intended to be
	-- modified on-the-fly like this.
	--
	-- Because of this, I am disabling this this OptionRow by default.
	-- It can be enabled in Metrics.ini under [ScreenPlayerOptions2] at the discretion of the user.

	-- TimingWindowScale = {
	-- 	Choices = function()
	-- 		return { "Normal", "90%", "80%", "70%", "60%", "50%", "40%", "30%", "20%", "10%" }
	-- 	end,
	-- 	OneChoiceForAllPlayers = true,
	-- 	LoadSelections = function(self, list, pn)
	-- 		local Values = { 1, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1 }
	-- 		local i = FindInTable( PREFSMAN:GetPreference("TimingWindowScale"), Values) or 1
	-- 		list[i] = true
	-- 	end,
	-- 	SaveSelections = function(self, list, pn)
	-- 		local Values = { 1, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1 }
	-- 		for i=1,#list do
	-- 			if list[i] then
	-- 				PREFSMAN:SetPreference("TimingWindowScale", Values[i] or 1)
	-- 			end
	-- 		end
	-- 	end
	-- },
	-------------------------------------------------------------------------
	ScreenAfterPlayerOptions = {
		Choices = function() return { 'Gameplay', 'Select Music', 'Extra Modifiers' } end,
		OneChoiceForAllPlayers = true,
		LoadSelections = function(self, list, pn) list[1] = true end,
		SaveSelections = function(self, list, pn)
			if list[1] then SL.Global.ScreenAfter.PlayerOptions = Branch.GameplayScreen() end
			if list[2] then SL.Global.ScreenAfter.PlayerOptions = SelectMusicOrCourse() end
			if list[3] then SL.Global.ScreenAfter.PlayerOptions = "ScreenPlayerOptions2" end
		end
	},
	-------------------------------------------------------------------------
	ScreenAfterPlayerOptions2 = {
		Choices = function() return { 'Gameplay', 'Select Music', 'Normal Modifiers' } end,
		OneChoiceForAllPlayers = true,
		LoadSelections = function(self, list, pn) list[1] = true end,
		SaveSelections = function(self, list, pn)
			if list[1] then SL.Global.ScreenAfter.PlayerOptions2 = Branch.GameplayScreen() end
			if list[2] then SL.Global.ScreenAfter.PlayerOptions2 = SelectMusicOrCourse() end
			if list[3] then SL.Global.ScreenAfter.PlayerOptions2 = "ScreenPlayerOptions" end
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
			self.Choices = Overrides[name]:Choices()

			-- define fallback values to use here if an override isn't specified
			self.LayoutType = Overrides[name].LayoutType or "ShowAllInRow"
			self.SelectType = Overrides[name].SelectType or "SelectOne"
			self.OneChoiceForAllPlayers = Overrides[name].OneChoiceForAllPlayers or false
			self.ExportOnChange = Overrides[name].ExportOnChange or false
			self.ReloadRowMessages = Overrides[name].ReloadRowMessages or {}

			self.LoadSelections = Overrides[name].LoadSelections or function(subself, list, pn)
				local choice = SL[ToEnumShortString(pn)].ActiveModifiers[name]
				local i = FindInTable(choice, self.Choices) or 1
				list[i] = true
			end

			self.SaveSelections = Overrides[name].SaveSelections or function(subself, list, pn)
				local mods, playeroptions = GetModsAndPlayerOptions(pn)

				for i=1,#list do
					if list[i] then
						mods[name] = Overrides[name]:Choices()[i]
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
-- which we can call from the OnCommand of
-- /BGAnimations/ScreenSelectMusic overlay/playerModifiers.lua

function ApplyMods(player)
	for name,value in pairs(Overrides) do
		OptRow = CustomOptionRow( name )
		OptRow:LoadSelections( OptRow.Choices, player )
		-- OptRow:SaveSelections( OptRow.Choices, player )
	end
end
