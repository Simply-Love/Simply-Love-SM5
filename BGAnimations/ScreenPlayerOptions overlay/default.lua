------------------------------------------------------------
-- functions local to this file

-- this prepares and returns a string to be used by the helper BitmapText
-- at the top of the screen (one for each player)
local GetSpeedModHelperText = function(player)
	local bpm
	local text = ""
	local mods = SL[ToEnumShortString(player)].ActiveModifiers
	local speed = mods.SpeedMod

	if GAMESTATE:IsCourseMode() then
		bpm = GetCourseModeBPMs() or GetTrailBPMs(player)
	else
		bpm = GAMESTATE:GetCurrentSong():GetDisplayBpms()
		-- handle DisplayBPMs that are <= 0
		if bpm[1] <= 0 or bpm[2] <= 0 then
			bpm = GAMESTATE:GetCurrentSong():GetTimingData():GetActualBPM()
		end
	end

	-- if using an XMod
	if mods.SpeedModType == "x" then
		local musicrate = SL.Global.ActiveModifiers.MusicRate

		--if a single bpm suffices
		if bpm[1] == bpm[2] then
			text = string.format("%.2f", speed) .. "x (" .. round(speed * bpm[1] * musicrate) .. ")"

		-- if we have a range of bpms
		else
			text = string.format("%.2f", speed) .. "x (" .. round(speed * bpm[1] * musicrate) .. " - " .. round(speed * bpm[2] * musicrate) .. ")"
		end

	-- elseif using a CMod or an MMod
	elseif mods.SpeedModType == "C" or mods.SpeedModType == "M" then
		text = mods.SpeedModType .. tostring(speed)
	end

	return text
end

local increments = {
	x = 0.05,
	C = 5,
	M = 5
}

local bounds = {
	x = { upper=20, lower=0.05 },
	C = { upper=2000, lower=5 },
	M = { upper=2000, lower=5 }
}

--- this manipulates the SpeedMod numbers set in the global SL table
local ChangeSpeedMod = function(pn, direction)
	local mods = SL[pn].ActiveModifiers

	if mods.SpeedMod + (increments[mods.SpeedModType] * direction) > bounds[mods.SpeedModType].upper then
		mods.SpeedMod = bounds[mods.SpeedModType].lower

	elseif mods.SpeedMod + (increments[mods.SpeedModType] * direction) < bounds[mods.SpeedModType].lower then
		mods.SpeedMod = bounds[mods.SpeedModType].upper

	else
		mods.SpeedMod = mods.SpeedMod + (increments[mods.SpeedModType] * direction)
	end
end

local FindOptionRowIndex = function(ScreenOptions, Name)
	if not ScreenOptions then return end

	local num_rows = ScreenOptions:GetNumRows()

	-- OptionRows on ScreenOptions are 0-indexed, so start counting from 0
	for i=0,num_rows-1 do
		if ScreenOptions:GetOptionRow(i):GetName() == Name then
			return i
		end
	end
end

------------------------------------------------------------


local Players = GAMESTATE:GetHumanPlayers()

-- SpeedModItems is a table that will contain the BitmapText actors for the SpeedMod OptionRow for both P1 and P2
local SpeedModItems = {}

local t = Def.ActorFrame{
	InitCommand=cmd(xy,_screen.cx,0),
	OnCommand=cmd(diffusealpha,0; linear,0.2;diffusealpha,1; queuecommand,"Capture"),
	OffCommand=cmd(linear,0.2; diffusealpha,0),
	CaptureCommand=function(self)

		local ScreenOptions = SCREENMAN:GetTopScreen()

		for player in ivalues( GAMESTATE:GetHumanPlayers() ) do
			local pn = ToEnumShortString(player)
			local SpeedModRowIndex = FindOptionRowIndex(ScreenOptions,"SpeedMod")

			if SpeedModRowIndex then
				-- The BitmapText actors for P1 and P2 speedmod are both named "Item", so we need to provide a 1 or 2 to index
				SpeedModItems[pn] = ScreenOptions:GetOptionRow(SpeedModRowIndex):GetChild(""):GetChild("Item")[ PlayerNumber:Reverse()[player]+1 ]
				self:playcommand("Set"..pn)
			end
		end
	end,
	MusicRateChangedMessageCommand=function(self)
		-- variables to be used for setting the text in the "Speed Mod" OptionRow title
		local ScreenOptions = SCREENMAN:GetTopScreen()
		local SpeedModRowIndex = FindOptionRowIndex(ScreenOptions, "SpeedMod")

		-- the speedmod row doesn't exist for ScreenAttackMenu, and SpeedModRowIndex will be nil
		if SpeedModRowIndex then

			local musicrate = SL.Global.ActiveModifiers.MusicRate

			-- update SpeedModHelper text to refelct the new music rate
			for player in ivalues(GAMESTATE:GetHumanPlayers()) do
				self:GetChild(ToEnumShortString(player) .. "SpeedModHelper"):settext( GetSpeedModHelperText(player) )
			end

			local SpeedModTitle = ScreenOptions:GetOptionRow(SpeedModRowIndex):GetChild(""):GetChild("Title")
			local bpms = GetDisplayBPMs()
			SpeedModTitle:settext( THEME:GetString("OptionTitles", "SpeedMod") .. " (" .. bpms .. ")" )
		end
	end
}

-- attach NoteSkin actors and Judgment graphic sprites and Combo bitmaptexts to
-- this overlay ActorFrame; they'll each be hidden immediately via visible(false)
-- and referred to as needed via ActorProxy in ./Graphics/OptionRow Frame.lua
LoadActor("./NoteSkinPreviews.lua", t)
LoadActor("./JudgmentGraphicPreviews.lua", t)
LoadActor("./ComboFontPreviews.lua", t)

-- some functionality needed in both PlayerOptions and PlayerOptions2
t[#t+1] = LoadActor(THEME:GetPathB("ScreenPlayerOptions", "common"))


for player in ivalues(Players) do
	local pn = ToEnumShortString(player)

	t[#t+1] = Def.Actor{

		-- Commands for player speedmod
		["SpeedModType" .. pn .. "SetMessageCommand"]=function(self,params)

			local oldtype = SL[pn].ActiveModifiers.SpeedModType
			local newtype = params.SpeedModType
			local song = GAMESTATE:GetCurrentSong()

			if oldtype ~= newtype then
				local bpm
				local oldspeed = SL[pn].ActiveModifiers.SpeedMod

				if GAMESTATE:IsCourseMode() then
					bpm = GetCourseModeBPMs() or GetTrailBPMs(player)

				else
					bpm = song:GetDisplayBpms()
					if bpm[1] <= 0 or bpm[2] <= 0 then
						bpm = song:GetTimingData():GetActualBPM()
					end
				end

				-- round to the nearest speed increment in the new mode

				-- if we have an active rate mod, then we have to undo/redo
				-- our automatic rate mod compensation

				if oldtype == "x" and (newtype == "C" or newtype == "M") then
					-- apply rate compensation now
					oldspeed = oldspeed * SL.Global.ActiveModifiers.MusicRate

					SL[pn].ActiveModifiers.SpeedMod = (round((oldspeed * bpm[2]) / increments[newtype])) * increments[newtype]
				elseif newtype == "x" then
					-- revert rate compensation since its handled for XMod
					oldspeed = oldspeed / SL.Global.ActiveModifiers.MusicRate

					SL[pn].ActiveModifiers.SpeedMod = (round(oldspeed / bpm[2] / increments[newtype])) * increments[newtype]
				end

				SL[pn].ActiveModifiers.SpeedModType = newtype

				self:queuecommand("Set" .. pn)
			end
		end,

		["Set" .. pn .. "Command"]=function(self)
			local text = ""

			if  SL[pn].ActiveModifiers.SpeedModType == "x" then
				text = string.format("%.2f" , SL[pn].ActiveModifiers.SpeedMod ) .. "x"

			elseif  SL[pn].ActiveModifiers.SpeedModType == "C" then
				text = "C" .. tostring(SL[pn].ActiveModifiers.SpeedMod)

			elseif  SL[pn].ActiveModifiers.SpeedModType == "M" then
				text = "M" .. tostring(SL[pn].ActiveModifiers.SpeedMod)
			end

			SpeedModItems[pn]:settext( text )
			self:GetParent():GetChild(pn .. "SpeedModHelper"):settext( GetSpeedModHelperText(player) )
		end,

		["MenuLeft" .. pn .. "MessageCommand"]=function(self)
			local topscreen = SCREENMAN:GetTopScreen()
			local row_index = topscreen:GetCurrentRowIndex(player)

			if row_index == FindOptionRowIndex(SCREENMAN:GetTopScreen(), "SpeedMod") then
				ChangeSpeedMod( pn, -1 )
				self:queuecommand("Set"..pn)
			end
		end,
		["MenuRight" .. pn .. "MessageCommand"]=function(self)
			local topscreen = SCREENMAN:GetTopScreen()
			local row_index = topscreen:GetCurrentRowIndex(player)

			if row_index == FindOptionRowIndex(SCREENMAN:GetTopScreen(), "SpeedMod") then
				ChangeSpeedMod( pn, 1 )
				self:queuecommand("Set"..pn)
			end
		end
	}

	-- the large block text at the top that shows each player their current scroll speed
	t[#t+1] = LoadFont("_wendy small")..{
		Name=pn.."SpeedModHelper",
		Text="",
		InitCommand=function(self)
			self:diffuse(PlayerColor(player)):diffusealpha(0)
			self:zoom(0.5):y(48)
			self:x(player==PLAYER_1 and -100 or 150)
			self:shadowlength(0.55)
		end,
		OnCommand=cmd(linear,0.4;diffusealpha,1)
	}
end

return t
