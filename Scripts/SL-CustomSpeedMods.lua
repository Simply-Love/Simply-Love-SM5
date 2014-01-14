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
						
			-- local userSpeedType = GetUserPref("SpeedModType" .. ToEnumShortString(pn))
			local userSpeedType = getenv("SpeedModType" .. ToEnumShortString(pn))

			if userSpeedType then		
				for i=1, #modList do
					if userSpeedType == modList[i] then
						list[i] = true
					end
				end				
			else
				list[1] = true
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
			
			--local type = GetUserPref("SpeedModType"..ToEnumShortString(pn))
			local type = getenv("SpeedModType"..ToEnumShortString(pn))
			if not type then
				--SetUserPref("SpeedModType"..ToEnumShortString(pn), "x");
				setenv("SpeedModType"..ToEnumShortString(pn), "x")
			end
			
			-- local userSpeedMod = GetUserPref("SpeedMod"..ToEnumShortString(pn));
			local userSpeedMod = getenv("SpeedMod"..ToEnumShortString(pn));
			if not userSpeedMod then
				--SetUserPref("SpeedMod"..ToEnumShortString(pn),"1.5x")
				setenv("SpeedMod"..ToEnumShortString(pn),"1.5x")
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
			speed = tostring(tonumber(speed) + 0.1).."x"
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
			speed = tostring(tonumber(speed) - 0.1).."x"
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









-- -------------------------------------------------------------
-- Old, currently unused functions below
-- I'm keeping these here ... for whatever reason.
-- -------------------------------------------------------------

function SpeedModsBase()

	local modList = { "1x", "2x", "3x", "4x", "5x", "6x", "7x", "8x", "9x", "10x", "C1400", "C1300", "C1200", "C1100", "C1000", "C900", "C800", "C700", "C600", "C500", "C400" }
	local t = {
		Name = "Speed",
		LayoutType = "ShowOneInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = false,
		ExportOnChange = false,
		Choices = modList,
		LoadSelections = function(self, list, pn)
						
			local userSpeedBase = GetUserPref("SpeedModBase" .. ToEnumShortString(pn))
			
			if userSpeedBase then		
				for i=1, #modList do
					if userSpeedBase == modList[i] then
						list[i] = true
					end
				end				
			else
				list[1] = true
			end
		end,
		SaveSelections = function(self, list, pn)
			local bSave;
			
			for i=1, #list do
				if list[i] then
					bSave=modList[i]
				end
			end
			
			SetUserPref("SpeedModBase" .. ToEnumShortString(pn), bSave);
			ParseMultilineSpeedMod()
			MESSAGEMAN:Broadcast('SpeedModChanged')
		end
	}
	setmetatable(t, t)
	return t
end



function SpeedModsExtra()

	local modList = { "0", "+.25x", "+.50x", "+.75x", "+C90", "+C80", "+C70", "+C60", "+C50", "+C40", "+C30", "+C20", "+C10" }
	local t = {
		Name = "Extra Speed",
		LayoutType = "ShowOneInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = false,
		ExportOnChange = false,
		Choices = modList,
		LoadSelections = function(self, list, pn)
			local userSpeedBase = GetUserPref("SpeedModExtra" .. ToEnumShortString(pn))
			
			if userSpeedBase then		
				for i=1, #modList do
					if userSpeedBase == modList[i] then
						list[i] = true
					end
				end				
			else
				list[1] = true
			end
		end,
		SaveSelections = function(self, list, pn)
			local bSave;
			
			for i=1, #list do
				if list[i] then
					bSave=modList[i]
				end
			end
			
			SetUserPref("SpeedModExtra" .. ToEnumShortString(pn), bSave);
			
			GAMESTATE:ApplyGameCommand('mod,1x', pn)
			ParseMultilineSpeedMod()
			MESSAGEMAN:Broadcast('SpeedModChanged')
		end
	}
	setmetatable(t, t)
	return t
end





function ParseMultilineSpeedMod()
	for pn=1, 2 do
		if GAMESTATE:IsPlayerEnabled( "PlayerNumber_P"..pn ) then
			
			local base  = GetUserPref("SpeedModBaseP"..pn)
			local extra = GetUserPref("SpeedModExtraP"..pn)
			
			if base == nil then
				base = "1x"
				SetUserPref("SpeedModBaseP"..pn, base);
			end
			
			if extra == nil then
				extra = "0"
				SetUserPref("SpeedModExtraP"..pn, extra);
			end
			
			local baseType  = ""
			local speed = ""
			
			-- handle base speed mod
			-- strip out "+C" or "x" as needed
			-- and establish a speed variable
			if string.sub(base,1,1) == "C" then
				baseType = "C"
				speed = base
				
			elseif string.sub(base,-1) == "x" then
				baseType = "x"
				speed = string.gsub(base, "x", "")
			end
			
			
			-- handle extra speed mods
			-- after stripping out the "+C" or "x"
			-- concatenate what's left to the speed variable from above
			
			--there are five possible scenarios that need to be handled
			if baseType == "C" and string.sub(extra,1,2) == "+C" then
				
				speed = string.gsub(speed,"00","")
				speed = speed .. string.gsub(extra, "+C", "")
					
			elseif baseType == "C" and string.sub(extra,1,2) == "+." then
				
				speed = string.gsub(speed,"00","")
				extra = string.gsub(extra, "+.", "")
				speed = speed .. string.gsub(extra, "x", "")
				
			elseif baseType == "x" and string.sub(extra,1,2) == "+C" then
				
				extra = string.gsub(extra, "+C", "")
				extra = tonumber(extra)
				extra = round(extra/100,1)
				extra = string.gsub(extra, "0.", "")
				speed = speed .. "." .. extra .. "x"
				
			elseif baseType == "x" and string.sub(extra,1,2) == "+." then
				
				extra = string.gsub(extra, "+", "")
				extra = string.gsub(extra, "0", "")
				speed = speed .. extra
				
			elseif baseType =="x" and extra == "0" then
				speed = speed.."x"
				
			end
			
			SetUserPref("SpeedModP"..pn, speed)
			GAMESTATE:ApplyGameCommand('mod,' .. speed, "PlayerNumber_P"..pn)
		end
	end
end
