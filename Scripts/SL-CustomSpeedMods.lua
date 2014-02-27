function SpeedModsType()
	local modList = { "x", "C" };
	local t = {
		Name = "SpeedType",
		LayoutType = "ShowOneInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = false,
		ExportOnChange = true,
		Choices = modList,
		LoadSelections = function(self, list, pn)
						
			local userSpeedType = getenv("SpeedModType" .. ToEnumShortString(pn))
			list[1] = true
			
			if userSpeedType then		
				for i=1, #modList do
					if userSpeedType == modList[i] then
						list[1] = nil
						list[i] = true
					end
				end				
			end
		end,
		SaveSelections = function(self, list, pn)
			local bSave;
			
			for i=1, #list do
				if list[i] then
					bSave=modList[i]
				end
			end
			
			MESSAGEMAN:Broadcast('SpeedModType'..ToEnumShortString(pn)..'Set',{Type=bSave});
		end
	}
	setmetatable(t, t)
	return t
end


function SpeedModsNew()
	
	local blank = {"       "};

	local t = {
		Name = "SpeedNew",
		LayoutType = "ShowOneInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = false,
		ExportOnChange = false,
		Choices = blank,
		LoadSelections = function(self, list, pn)
			
			
			local type = getenv("SpeedModType"..ToEnumShortString(pn))
			if not type then
				setenv("SpeedModType"..ToEnumShortString(pn), "x")
			end
			
			
			local userSpeedMod = getenv("SpeedMod"..ToEnumShortString(pn));
			if not userSpeedMod then	
				setenv("SpeedMod"..ToEnumShortString(pn),"1x")
			end

			list[1] = true	
		end,
		SaveSelections = function(self, list, pn)
			--with ExportOnChange set to false
			--SaveSelections gets called twice:
				-- once when the ScreenPlayerOptions loads
				-- and once when ScreenPlayerOptions exits
			MESSAGEMAN:Broadcast('SpeedMod'..ToEnumShortString(pn)..'Set');
		end	
	}
	setmetatable(t, t)
	return t
end





function increment(speed)
	-- if using an x-mod
	if string.sub(speed,-1) == "x" then
		speed = string.gsub(speed,"x","");
		
		if tonumber(speed)+0.1 >= 20 then
			speed = "0.1x"
		else
			speed = string.format("%.1fx", tonumber(speed) + 0.1)
		end
	-- elseif using a C-mod
	elseif string.sub(speed,1,1) == "C" then
		speed = string.gsub(speed,"C","");
		
		if tonumber(speed)+10 >= 2000 then
			speed = "C10"
		else
			speed = "C"..tostring(tonumber(speed) + 10)
		end
	end	
	
	return speed;
end;

function decrement(speed)
	-- if using an x-mod
	if string.sub(speed,-1) == "x" then
		speed = string.gsub(speed,"x","");
		
		if tonumber(speed)-0.1 <= 0 then
			speed = "20x"
		else
			speed = string.format("%.1fx", tonumber(speed) - 0.1)
		end
	-- elseif using a C-mod
	elseif string.sub(speed,1,1) == "C" then
		speed = string.gsub(speed,"C","");
		if tonumber(speed)-10 <= 0 then
			speed = "C2000"
		else
			speed = "C"..tostring(tonumber(speed) - 10)
		end
	end	
	
	return speed;
end;






function ApplySpeedMod(pn)
	-- local speed = GetUserPref("SpeedMod" .. pn)
	local speed = getenv("SpeedMod" .. pn)
	GAMESTATE:ApplyGameCommand('mod,' .. speed, "PlayerNumber_"..pn)
end


function DisplaySpeedMod(speed)
	local bpm = GAMESTATE:GetCurrentSong():GetDisplayBpms();
	local display;
		
	-- if using an x-mod
	if string.sub(speed,-1) == "x" then
		speed = string.gsub(speed,"x","");
		
		--if a single bpm suffices
		if bpm[1] == bpm[2] then
			display = speed.."x (" .. round(tonumber(speed) * tonumber(bpm[1])) .. ")";
			
		-- if we have a range of bpms
		else
			display = speed.."x (" .. round(tonumber(speed) * tonumber(bpm[1])) .. " - " .. round(tonumber(speed) * tonumber(bpm[2])) .. ")";
		end
	
	-- elseif using a C-mod
	elseif string.sub(speed,1,1) == "C" then
		display = speed;
	end

	return display;
end