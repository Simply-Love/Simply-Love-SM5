local args = ...
local af = args.af
local scrollers = args.Scrollers

local mpn = GAMESTATE:GetMasterPlayerNumber()

local Handle = {}

local TextEntrySettings = {
	-- ScreenMessage to send on pop (optional, "SM_None" if omitted)
	--SendOnPop = "",

	-- The question to display
	Question = "New Tag:",
	
	-- Initial answer text
	InitialAnswer = "",
	
	-- Maximum amount of characters
	MaxInputLength = 30,
	
	--Password = false,	
	
	-- Validation function; function(answer, errorOut), must return boolean, string.
	Validate = function(answer, errorOut)
		if FindInTable(answer,GetGroups("Tag")) then return false, "Tag names must be unique" end
		return true, answer
	end,
	
	-- On OK; function(answer)
	OnOK = function(answer)
		if answer == "" then MESSAGEMAN:Broadcast("FinishText") --if players who don't have a keyboard get here they can just hit enter to cancel out
		else
			AddTag(answer)
			local frame = af:GetChild(ToEnumShortString('PlayerNumber_P1') .. 'Frame')
			frame:GetChild('ScrollerFrame'):playcommand("SetTagWheel")
			scrollers[GAMESTATE:GetMasterPlayerNumber()]:scroll_by_amount(#GetGroups("Tag")-2)
			frame:playcommand("Set", {index=#GetGroups("Tag")-1})
		end
	end,
	
	-- On Cancel; function()
	OnCancel = function()
		--MESSAGEMAN:Broadcast("FinishText")
	end,
	
	-- Validate appending a character; function(answer,append), must return boolean
	ValidateAppend = nil,
	
	-- Format answer for display; function(answer), must return string
	FormatAnswerForDisplay = nil,
}

-- When the player hits start on the CustomSongMenu they want to either add or remove a song from a custom group.
Handle.Start = function(event)
	local topscreen = SCREENMAN:GetTopScreen()
	if GAMESTATE:IsHumanPlayer(event.PlayerNumber) then
		-- first figure out which group we're dealing with
		local info = scrollers[event.PlayerNumber]:get_info_at_focus_pos()
		local index = type(info)=="table" and info.index or 0
		if index == 0 then 
			SCREENMAN:AddNewScreenToTop("ScreenTextEntry")
			SCREENMAN:GetTopScreen():Load(TextEntrySettings)
		else
			local current_song = GAMESTATE:GetCurrentSong() or SL.Global.LastSeenSong
			local group = GetGroups("Tag")[index]
			-- figure out if the song is already in this group so we know whether to remove or add
			local inGroup = IsTaggedSong(current_song, group)
			local toAdd = GetGroups("Tag")[index].."\t"..current_song:GetMainTitle().."\t"..current_song:GetGroupName()
			if not inGroup then AddTaggedSong(toAdd, current_song) SM("Added ["..current_song:GetMainTitle().."] to "..group)
			else RemoveTaggedSong(toAdd, current_song) SM("Removed ["..current_song:GetMainTitle().."] from "..group)  end
			-- if we're currently sorting by Custom then this change will mess with groups. Redo all the groups so we're on the correct one again
			if SL.Global.GroupType == "Tag" then MESSAGEMAN:Broadcast("GroupTypeChanged") end
			-- update the frame showing a information about the custom groups
			local frame = af:GetChild(ToEnumShortString(event.PlayerNumber) .. 'Frame')
			frame:playcommand("Set", {index=index})
			MESSAGEMAN:Broadcast("UpdateTags")
			-- and queue the Finish for the menu
			topscreen:queuecommand("Finish"):sleep(0.4)
		end


	end
end

Handle.Center = Handle.Start


Handle.MenuLeft = function(event)
	if GAMESTATE:IsHumanPlayer(event.PlayerNumber) then
		local info = scrollers[event.PlayerNumber]:get_info_at_focus_pos()
		-- We add a bunch of empty rows to the table so that the first custom group is the default
		-- and it's centered on the screen. We don't want to be able to scroll to them however.
		-- To get around that, each actual group has an index parameter that we set to be non zero
		-- and then just don't scroll to 0 or lower
		local index = type(info)=="table" and info.index or 0
		if index - 1 >= 0 then
			MESSAGEMAN:Broadcast("DirectionButton")
			scrollers[event.PlayerNumber]:scroll_by_amount(-1)
			local frame = af:GetChild(ToEnumShortString(event.PlayerNumber) .. 'Frame')
			frame:playcommand("Set", {index=index-1})
		end
	end
end

Handle.MenuUp = Handle.MenuLeft
Handle.DownLeft = Handle.MenuLeft

Handle.MenuRight = function(event)
	if GAMESTATE:IsHumanPlayer(event.PlayerNumber) then
		local info = scrollers[event.PlayerNumber]:get_info_at_focus_pos()
		-- We add a bunch of empty rows to the table so that the first custom group is the default
		-- and it's centered on the screen. We don't want to be able to scroll to them however.
		-- To get around that, each actual group has an index parameter that we set to be non zero
		-- and then just don't scroll to 0 or lower
		local index = type(info)=="table" and info.index or 0
		if index + 1 < #GetGroups("Tag") then
			MESSAGEMAN:Broadcast("DirectionButton")
			scrollers[event.PlayerNumber]:scroll_by_amount(1)
			local frame = af:GetChild(ToEnumShortString(event.PlayerNumber) .. 'Frame')
			frame:playcommand("Set", {index=index+1})
		end
	end
end
Handle.MenuDown = Handle.MenuRight
Handle.DownRight = Handle.MenuRight

Handle.Back = function(event)
	local topscreen = SCREENMAN:GetTopScreen()

	if GAMESTATE:IsHumanPlayer(event.PlayerNumber) then
		MESSAGEMAN:Broadcast("BackButton")
		-- queue the Finish for the entire screen
		topscreen:queuecommand("Finish"):sleep(0.4)
	end
end


local InputHandler = function(event)
	if not event or not event.button then return false end
	if event.type ~= "InputEventType_Release" then
		if Handle[event.GameButton] then Handle[event.GameButton](event) end
	end
end

return InputHandler