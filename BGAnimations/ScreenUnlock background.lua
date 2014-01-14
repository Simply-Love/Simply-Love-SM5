local function UnlockSomeStuff(text)
	
	-- how many unlocks are there? Get the number.
	local howMany = UNLOCKMAN:GetNumUnlocks();
	
	if howMany > 0 then
		
		--this returns a table whether it finds anything or not...
		local unlockSongs = UNLOCKMAN:GetSongsUnlockedByEntryID(text);
		
		-- so check the size of that table
		if #unlockSongs > 0 then
			
			local group = unlockSongs[1]:GetGroupName();
			local title = unlockSongs[1]:GetDisplayFullTitle();
			local path = group.."/"..title;
					
			-- this env variable is used to tell us what the next screen will be
			setenv("ScreenUnlock", "ScreenUnlockSuccess")
			setenv("NewlyUnlockedSong", path)
			
			--unlock it!
			UNLOCKMAN:UnlockEntryID(text);
		else
			
			setenv("ScreenUnlock", "ScreenUnlockFailure")
			setenv("NewlyUnlockedSong", nil)
		end
	
	end
end



local textEntrySettings = {
	-- ScreenMessage to send on pop (optional, "SM_None" if omitted)
	--SendOnPop = "",

	-- The question to display
	Question = "Enter your unlock code:",
	
	-- Initial answer text
	InitialAnswer = "",
	
	-- Maximum amount of characters
	MaxInputLength = 30,
	
	--Password = false,	
	
	-- Validation function; function(answer, errorOut), must return boolean, string.
	Validate = nil,
	
	-- On OK; function(answer)
	OnOK = function(answer)
		UnlockSomeStuff(answer)
	end,
	
	-- On Cancel; function()
	OnCancel = nil,
	
	-- Validate appending a character; function(answer,append), must return boolean
	ValidateAppend = nil,
	
	-- Format answer for display; function(answer), must return string
	FormatAnswerForDisplay = nil,
};




local t =  Def.ActorFrame{
	
	OnCommand=function(self)
		SCREENMAN:GetTopScreen():Load(textEntrySettings);
	end;
};

t[#t+1] = LoadActor( THEME:GetPathB("ScreenWithMenuElements","background") );

return t;