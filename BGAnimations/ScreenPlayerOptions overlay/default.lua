-- SL's "dynamic" speedmod system is a horrible hack that works around the limitations of
-- the engine's OptionRows which don't offer any means of presenting different sets of
-- choices to each player within a single OptionRow.  We need this functionality when, for
-- example, P1 wants an xmod and P2 wants a Cmod; the choices presented in the SpeedMod
-- OptionRow present and behave differently for each player.
--
-- So, we do a lot of hackish work locally (here in ScreenPlayerOptions overlay/default.lua)
-- to manipulate the text being presented by the single BitmapText actor present in each
-- SpeedMod OptionRow.  This is not how any other OptionRow operates, and it is neither
-- flexible nor forward-thinking.

local speedmod_def = {
	X = { upper=20,   increment=0.05 },
	C = { upper=2000, increment=5 },
	M = { upper=2000, increment=5 }
}

local song = GAMESTATE:GetCurrentSong()

------------------------------------------------------------
-- functions local to this file

-- this prepares and returns a string to be used by the helper BitmapText
-- that shows players their effective scrollspeed

local CalculateScrollSpeed = function(player)
	player   = player or GAMESTATE:GetMasterPlayerNumber()
	local pn = ToEnumShortString(player)

	local StepsOrTrail = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)
	local MusicRate    = SL.Global.ActiveModifiers.MusicRate or 1

	local SpeedModType = SL[pn].ActiveModifiers.SpeedModType
	local SpeedMod     = SL[pn].ActiveModifiers.SpeedMod

	local bpms = GetDisplayBPMs(player, StepsOrTrail, MusicRate)
	if not (bpms and bpms[1] and bpms[2]) then return "" end

	if SpeedModType=="X" then
		bpms[1] = bpms[1] * SpeedMod
		bpms[2] = bpms[2] * SpeedMod

	elseif SpeedModType=="M" then
		bpms[1] = bpms[1] * (SpeedMod/bpms[2])
		bpms[2] = SpeedMod

	elseif SpeedModType=="C" then
		bpms[1] = SpeedMod
		bpms[2] = SpeedMod
	end

	-- format as strings
	bpms[1] = ("%.0f"):format(bpms[1])
	bpms[2] = ("%.0f"):format(bpms[2])

	if bpms[1] == bpms[2] then
		return bpms[1]
	end

	return ("%s-%s"):format(bpms[1], bpms[2])
end

-- use this to directly manipulate the SpeedMod numbers in the global SL table
--    first argument is either "P1" or "P2"
--    second argument is either -1 (MenuLeft was pressed) or 1 (MenuRight was pressed)
local ChangeSpeedMod = function(pn, direction)
	local mods = SL[pn].ActiveModifiers
	local speedmod = mods.SpeedMod
	local increment   = speedmod_def[mods.SpeedModType].increment
	local upper_bound = speedmod_def[mods.SpeedModType].upper

	-- increment/decrement and apply modulo to wrap around if we exceed the upper_bound or hit 0
	speedmod = ((speedmod+(increment*direction))-increment) % upper_bound + increment
	-- round the newly changed SpeedMod to the nearest appropriate increment
	speedmod = increment * math.floor(speedmod/increment + 0.5)

	mods.SpeedMod = speedmod
end


-- Use this function to find an OptionRow by name so that you can manipulate its text as needed.
--     first argument is a screen object provided by SCREENMAN:GetTopScreen()
--     second argument is a string that might match the name of an OptionRow somewhere on this screen
--
--     returns the 0-based index of that OptionRow within this screen

local FindOptionRowIndex = function(ScreenOptions, Name)
	if not ScreenOptions or not ScreenOptions.GetNumRows then return end

	local num_rows = ScreenOptions:GetNumRows()

	-- OptionRows on ScreenOptions are 0-indexed, so start counting from 0
	for i=0,num_rows-1 do
		if ScreenOptions:GetOptionRow(i):GetName() == Name then
			return i
		end
	end
end



local CalculatePerspectiveSpeed = function(player)
	player   = player or GAMESTATE:GetMasterPlayerNumber()
	local pn = ToEnumShortString(player)

	local StepsOrTrail = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)
	local MusicRate    = SL.Global.ActiveModifiers.MusicRate or 1

	local SpeedModType = SL[pn].ActiveModifiers.SpeedModType
	local SpeedMod     = SL[pn].ActiveModifiers.SpeedMod
	
	local ScreenOptions = SCREENMAN:GetTopScreen()
	local MiniModRowIndex = FindOptionRowIndex(ScreenOptions,"Mini")
	local Mini            = SL[pn].ActiveModifiers.Mini:gsub("%%","")

	if MiniModRowIndex then
		-- The BitmapText actors for P1 and P2 speedmod are both named "Item", so we need to provide a 1 or 2 to index
		Mini = ScreenOptions:GetOptionRow(MiniModRowIndex):GetChild(""):GetChild("Item")[ PlayerNumber:Reverse()[player]+1 ]:GetText():gsub("%%","")
	end

	local bpms = GetDisplayBPMs(player, StepsOrTrail, MusicRate)
	if not (bpms and bpms[1] and bpms[2]) then return "" end

	if SpeedModType=="X" then
		bpms[1] = bpms[1] * SpeedMod
		bpms[2] = bpms[2] * SpeedMod

	elseif SpeedModType=="M" then
		bpms[1] = bpms[1] * (SpeedMod/bpms[2])
		bpms[2] = SpeedMod

	elseif SpeedModType=="C" then
		bpms[1] = SpeedMod
		bpms[2] = SpeedMod
	end
	
	bpms[1] = bpms[1] * (200 - Mini) / 200
	bpms[2] = bpms[2] * (200 - Mini) / 200

	-- format as strings
	bpms[1] = ("%.0f"):format(bpms[1])
	bpms[2] = ("%.0f"):format(bpms[2])

	if bpms[1] == bpms[2] then
		return bpms[1]
	end

	return ("%s-%s"):format(bpms[1], bpms[2])
end

------------------------------------------------------------

-- SpeedModBMTs is a table that will contain the BitmapText actors within the SpeedMod OptionRow for available players
local SpeedModBMTs = {}

local t = Def.ActorFrame{
	InitCommand=function(self) self:xy(_screen.cx,0) end,
	OnCommand=function(self)
		-- players can repeatedly visit the options screen while in Edit Mode
		-- so ensure that this ActorFrame can be seen each time OnCommand() is called
		self:diffusealpha(1)
		self:queuecommand("Capture")
	end,
	OffCommand=function(self) self:linear(0.2):diffusealpha(0) end,
	CaptureCommand=function(self)
		local ScreenOptions = SCREENMAN:GetTopScreen()

		for player in ivalues( GAMESTATE:GetHumanPlayers() ) do
			local pn = ToEnumShortString(player)
			local SpeedModRowIndex = FindOptionRowIndex(ScreenOptions,"SpeedMod")

			if SpeedModRowIndex then
				-- The BitmapText actors for P1 and P2 speedmod are both named "Item", so we need to provide a 1 or 2 to index
				SpeedModBMTs[pn] = ScreenOptions:GetOptionRow(SpeedModRowIndex):GetChild(""):GetChild("Item")[ PlayerNumber:Reverse()[player]+1 ]
				self:playcommand("Set"..pn)
			end
		end
	end,
	MusicRateChangedMessageCommand=function(self)
		-- ScreenAttackMenu is both minimal (not many OptionRows) and buggy
		-- so if we're there, bail now
		if SCREENMAN:GetTopScreen():GetName() == "ScreenAttackMenu" then return end

		-- update SpeedModHelper text to reflect the new music rate
		self:queuecommand("Refresh")
	end,
	RefreshCommand=function(self)
		local screen = SCREENMAN:GetTopScreen()
		-- find the index of the OptionRow for MusicRate so we can update
		-- the text of its title BitmapText as the MusicRate changes
		local MusicRateRowIndex = FindOptionRowIndex(screen, "MusicRate")

		if MusicRateRowIndex then
			local title_bmt = screen:GetOptionRow(MusicRateRowIndex):GetChild(""):GetChild("Title")
			local bpms = {}

			for player in ivalues(GAMESTATE:GetHumanPlayers()) do
				table.insert(bpms, StringifyDisplayBPMs(player))
			end

			local text = StringifyDisplayBPMs()
			if #bpms == 2 then
				if bpms[1] == bpms[2] then
					text = bpms[1]
				else
					text = THEME:GetString("ScreenPlayerOptions", "SplitBPMs")
				end
				MESSAGEMAN:Broadcast("RefreshBPMRange", bpms)
			end

			title_bmt:settext( ("%s\nbpm: %s"):format(THEME:GetString("OptionTitles", "MusicRate"), text) )
		end
	end
}

-- attach NoteSkin actors and Judgment graphic sprites and Combo bitmaptexts to
-- this overlay ActorFrame; they'll each be hidden immediately via visible(false)
-- and referred to as needed via ActorProxy in ./Graphics/OptionRow Frame.lua
LoadActor("./OptionRowPreviews/NoteSkin.lua", t)
LoadActor("./OptionRowPreviews/JudgmentGraphic.lua", t)
LoadActor("./OptionRowPreviews/ComboFont.lua", t)
LoadActor("./OptionRowPreviews/HoldJudgment.lua", t)
LoadActor("./OptionRowPreviews/MusicRate.lua", t)

-- some functionality needed in both PlayerOptions, PlayerOptions2, and PlayerOptions3
t[#t+1] = LoadActor(THEME:GetPathB("ScreenPlayerOptions", "common"))


for player in ivalues(GAMESTATE:GetHumanPlayers()) do
	local pn = ToEnumShortString(player)
	local song = GAMESTATE:GetCurrentSong()

	t[#t+1] = Def.Actor{

		-- this is called from ./Scripts/SL-PlayerOptions.lua when the player changes their SpeedModType (X, M, C)
		["SpeedModType" .. pn .. "SetMessageCommand"]=function(self,params)
			if params.Player ~= player then return end

			local oldtype = SL[pn].ActiveModifiers.SpeedModType
			local newtype = params.SpeedModType

			-- this should never happen, but hey, might as well check
			if oldtype == newtype then return end

			local bpms = GetDisplayBPMs(player)
			local speedmod = SL[pn].ActiveModifiers.SpeedMod
			local increment = speedmod_def[newtype].increment

			-- round to the nearest speed increment in the new mode
			-- if we have an active rate mod, then we have to undo/redo
			-- our automatic rate mod compensation

			if oldtype == "X" then
				speedmod = (round((speedmod * bpms[2]) / increment)) * increment

			elseif newtype == "X" then
				speedmod = (round(speedmod / bpms[2] / increment)) * increment
			end

			-- it's possible for the procedure above to cause the player's speedmod to exceed
			-- the upper bound of the new Mmod or Cmod; clamp to prevent that
			speedmod = clamp(speedmod, increment, speedmod_def[newtype].upper)

			SL[pn].ActiveModifiers.SpeedMod     = speedmod
			SL[pn].ActiveModifiers.SpeedModType = newtype

			self:queuecommand("Set" .. pn)
		end,

		["Set" .. pn .. "Command"]=function(self)
			local text = ""

			if  SL[pn].ActiveModifiers.SpeedModType == "X" then
				text = string.format("%.2f" , SL[pn].ActiveModifiers.SpeedMod ) .. "x"

			elseif  SL[pn].ActiveModifiers.SpeedModType == "C" then
				text = "C" .. tostring(SL[pn].ActiveModifiers.SpeedMod)

			elseif  SL[pn].ActiveModifiers.SpeedModType == "M" then
				text = "M" .. tostring(SL[pn].ActiveModifiers.SpeedMod)
			end

			SpeedModBMTs[pn]:settext( text )
			self:GetParent():queuecommand("Refresh")
		end,

		["CurrentSteps" .. pn .. "ChangedMessageCommand"]=function(self) self:queuecommand("Set"..pn) end,
		["CurrentTrail" .. pn .. "ChangedMessageCommand"]=function(self) self:queuecommand("Set"..pn) end,

		["MenuLeft" .. pn .. "MessageCommand"]=function(self)
			local topscreen = SCREENMAN:GetTopScreen()
			local row_index = topscreen:GetCurrentRowIndex(player)

			if row_index == FindOptionRowIndex(topscreen, "SpeedMod") then
				ChangeSpeedMod( pn, -1 )
				self:queuecommand("Set"..pn)
			elseif row_index == FindOptionRowIndex(topscreen, "Mini") then
				self:queuecommand("Set"..pn)
			end
		end,
		["MenuRight" .. pn .. "MessageCommand"]=function(self)
			local topscreen = SCREENMAN:GetTopScreen()
			local row_index = topscreen:GetCurrentRowIndex(player)

			if row_index == FindOptionRowIndex(topscreen, "SpeedMod") then
				ChangeSpeedMod( pn, 1 )
				self:queuecommand("Set"..pn)
			elseif row_index == FindOptionRowIndex(topscreen, "Mini") then
				self:queuecommand("Set"..pn)
			end
		end
	}

	-- the large block text at the top that shows each player their current scroll speed
	t[#t+1] = LoadFont(ThemePrefs.Get("ThemeFont") .. " Bold")..{
		Name=pn.."SpeedModHelper",
		Text="",
		InitCommand=function(self)
			self:diffuse(PlayerColor(player)):diffusealpha(0)
			self:zoom(0.5):y(48)
			self:x(player==PLAYER_1 and WideScale(-77, -100) or WideScale(140,154))
			self:shadowlength(0.55)
		end,
		OnCommand=function(self) self:linear(0.4):diffusealpha(1) end,
		RefreshCommand=function(self)
			self:settext( ("%s%s"):format(SL[pn].ActiveModifiers.SpeedModType, CalculateScrollSpeed(player)) )
		end
	}
	
	t[#t+1] = LoadFont(ThemePrefs.Get("ThemeFont") .. " Bold")..{
		Name=pn.."SpeedModHelperEn",
		Text="",
		InitCommand=function(self)
			self:diffuse(PlayerColor(player)):diffusealpha(0)
			self:zoom(0.3):y(52)
			self:x(player==PLAYER_1 and WideScale(-77, -100) or WideScale(140,154))
			self:shadowlength(0.55)
		end,
		OnCommand=function(self) self:linear(0.4):diffusealpha(0) end,
		RefreshCommand=function(self)
			local w = self:GetParent():GetChild(pn.."SpeedModHelper"):GetWidth()
			local scroll = CalculateScrollSpeed(player)
			local pScroll = CalculatePerspectiveSpeed(player)
			if scroll == pScroll then self:finishtweening():linear(0.5):diffusealpha(0) else self:finishtweening():linear(0.5):diffusealpha(0.8) end
			self:x(player==PLAYER_1 and WideScale(-77 + (w * 0.4), -100 + (w * 0.4)) or WideScale(140 + (w * 0.4),154 + (w * 0.4)))
			self:settext( ("%s%s"):format(SL[pn].ActiveModifiers.SpeedModType, pScroll) )
		end
	}
end

return t
