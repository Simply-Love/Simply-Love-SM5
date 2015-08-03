-- Define what custom OptionRows there are, and override the
-- generic OptionRow (defined later, below) for each as necessary.
local Overrides = {

	-------------------------------------------------------------------------
	SpeedModType = {
		Choices = function() return { "x", "C", "M" } end,
		ExportOnChange = true,
		LayoutType = "ShowOneInRow",
		SaveSelections = function(self, list, pn)
			local choice
			for i=1,#list do
				if list[i] then choice=self.Choices[i] end
			end
			MESSAGEMAN:Broadcast('SpeedModType'..ToEnumShortString(pn)..'Set', {SpeedModType=choice})
		end
	},
	-------------------------------------------------------------------------
	SpeedMod = {
		Choices = function() return { "       " } end,
		LayoutType = "ShowOneInRow",
		LoadSelections = function(self, list, pn)
			list[1] = true
		end,
		SaveSelections = function(self, list, pn)
			ApplySpeedMod(pn)
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
				if string.match(filename, " %dx%d.png") then
					-- use regexp to get only the name of the graphic, stripping out the extension
					local name = filename:gsub(" %dx%d.png", "")

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
		Choices = function() return { 'Off','Dark','Darker','Darkest' } end
	},
	-------------------------------------------------------------------------
	Mini = {
		Choices = function()

			local first	= 0
			local last 	= 150
			local step 	= 5

			local rates = stringify( range(first, last, step), "%g%%")
			rates[1] = "Normal"
			return rates
		end,
		SaveSelections = function(self, list, pn)
			local sSave

			for i=1,#self.Choices do
				if list[i] then
					sSave = self.Choices[i]
				end
			end

			SL[ToEnumShortString(pn)].ActiveModifiers.Mini = sSave
			ApplyMini(pn)
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
			local rate = ("%.2g"):format( SL.Global.ActiveModifiers.MusicRate )
			local i = FindInTable(rate, self.Choices) or 1
			list[i] = true
		end,
		SaveSelections = function(self, list, pn)
			local sSave

			for i=1,#self.Choices do
				if list[i] then
					sSave = self.Choices[i]
				end
			end

			SL.Global.ActiveModifiers.MusicRate = tonumber(sSave)
			local topscreen = SCREENMAN:GetTopScreen():GetName()

			-- Use the older GameCommand interface for applying rate mods in Edit Mode;
			-- it seems to be the only way (probably due to how broken Edit Mode is, in general).
			-- As an unintentional side-effect of setting musicrate mods this way, they STAY set
			-- (between songs, between screens, etc.) until you manually change them.  This is (probably)
			-- not the desired behavior in EditMode, so when users change between different songs in EditMode,
			-- always reset the musicrate mod.  See: ./BGAnimations/ScreenEditMeny underlay.lua
			if topscreen == "ScreenEditOptions" then
				GAMESTATE:ApplyGameCommand("mod," .. sSave .."xmusic")
			else
				GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):MusicRate(tonumber(sSave))
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
			local mods = SL[ToEnumShortString(pn)].ActiveModifiers
			mods.HideTargets= list[1]
			mods.HideSongBG = list[2]
			mods.HideCombo	= list[3]
			mods.HideLifebar= list[4]
			mods.HideScore	= list[5]
			ApplyHide(pn)
		end,
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
	TimingWindowScale = {
		-- values is non-standard and I should probably have a better way of handling
		-- data like this that I don't want to duplicate within multiple sub-functions
		Values = { 1, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1 },
		Choices = function()
			return { "Normal", "90%", "80%", "70%", "60%", "50%", "40%", "30%", "20%", "10%" }
		end,
		OneChoiceForAllPlayers = true,
		LoadSelections = function(self, list, pn)
			local i = FindInTable( PREFSMAN:GetPreference("TimingWindowScale"), self.Values) or 1
			list[i] = true
		end,
		SaveSelections = function(self, list, pn)
			for i=1,#list do
				if list[i] then
					PREFSMAN:SetPreference("TimingWindowScale", self.Values[i])
				end
			end
		end
	},
	-------------------------------------------------------------------------
	ScreenAfterPlayerOptions = {
		Choices = function() return { 'Gameplay', 'Select Music', 'Extra Modifiers' } end,
		OneChoiceForAllPlayers = true,
		LoadSelections = function(self, list, pn) list[1] = true end,
		SaveSelections = function(self, list, pn)
			if list[1] then SL.Global.ScreenAfter.PlayerOptions = Branch.GameplayScreen() end
			if list[2] then SL.Global.ScreenAfter.PlayerOptions = "ScreenSelectMusic" end
			if list[3] then SL.Global.ScreenAfter.PlayerOptions = "ScreenPlayerOptions2" end
		end
	},
	-------------------------------------------------------------------------
	ScreenAfterPlayerOptions2 = {
		Choices = function() return { 'Gameplay', 'Select Music', 'Normal Modifiers' } end,
		OneChoiceForAllPlayers = true,
		LoadSelections = function(self, list, pn) list[1] = true end,
		SaveSelections = function(self, list, pn)
			if list[1] then SL.Global.ScreenAfter.PlayerOptions = Branch.GameplayScreen() end
			if list[2] then SL.Global.ScreenAfter.PlayerOptions = "ScreenSelectMusic" end
			if list[3] then SL.Global.ScreenAfter.PlayerOptions = "ScreenPlayerOptions" end
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

			-- if an override isn't specified define fallback values to use here
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
				local choice
				for i=1,#list do
					if list[i] then choice=self.Choices[i] end
				end

				SL[ToEnumShortString(pn)].ActiveModifiers[name] = choice
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


------------------------------------------------------------
-- Helper Functions for PlayerOptions
------------------------------------------------------------
-- ApplyMini() is called above, from CustomOptionRow('Mini')
-- but also, and less obviously, from
-- /BGAnimations/ScreenSelectMusic overlay/playerModifiers.lua, and
-- /BGAnimations/ScreenPlayerOptions overlay.lua
function ApplyMini(pn)
	local mini = SL[ToEnumShortString(pn)].ActiveModifiers.Mini or "Normal"

	if mini == "Normal" then
		mini = 0
	else
		mini = mini:gsub("%%","")/100
	end

	local topscreen = SCREENMAN:GetTopScreen():GetName()
	local modslevel = topscreen  == "ScreenEditOptions" and "ModsLevel_Stage" or "ModsLevel_Preferred"

	-- to make the arrows smaller, pass Mini() a value between 0 and 1
	-- (to make the arrows bigger, pass Mini() a value larger than 1)
	GAMESTATE:GetPlayerState(pn):GetPlayerOptions(modslevel):Mini(mini)
end


function ApplySpeedMod(player)
	local type 	= SL[ToEnumShortString(player)].ActiveModifiers.SpeedModType or "x"
	local speed = SL[ToEnumShortString(player)].ActiveModifiers.SpeedMod or 1.00
	local topscreen = SCREENMAN:GetTopScreen():GetName()
	local modslevel = topscreen  == "ScreenEditOptions" and "ModsLevel_Stage" or "ModsLevel_Preferred"

	local playeroptions = GAMESTATE:GetPlayerState(player):GetPlayerOptions(modslevel)

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

function ApplyHide(pn)
	local mods = SL[ToEnumShortString(pn)].ActiveModifiers

	local topscreen = SCREENMAN:GetTopScreen():GetName()
	local modslevel = (topscreen == "ScreenEditOptions") and "ModsLevel_Stage" or "ModsLevel_Preferred"

	local opts = GAMESTATE:GetPlayerState(pn):GetPlayerOptions(modslevel)
	opts:Dark(mods.HideTargets and 1 or 0)
	opts:Cover(mods.HideSongBG and 1 or 0)
end