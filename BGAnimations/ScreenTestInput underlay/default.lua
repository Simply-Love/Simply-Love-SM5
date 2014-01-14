local GameButtons = {
	"Left", "Right", "Up", "Down",
	"UpRight", "UpLeft", "DownRight", "DownLeft", "Center",
	"Start", "Select", "MenuRight", "MenuLeft",
};



local function ProcessInputs(inputList)
	local state = {{},{}};
	
	-- initialize state to be full of "Off" values
	for i=1,2 do
		for k,panel in ipairs(GameButtons) do
			state[i][panel] =  "Off";
		end
	end
				
				
	-- 	loop through our list of input strings			
	-- 	setting the corresponding state value to "On"
	for i,v in ipairs(inputList) do
		
		local temp = {};
	
		-- break each input string into three parts
		-- ["Controller"] [pn] [button]
		for input in string.gmatch(inputList[i], "[^- ]+") do
			temp[#temp+1] = input;
	    end
		
		local pn = tonumber(temp[2]);
		local activeButton = tostring(temp[3]);
				
		-- an example here might be
		--state[1]["Right"] = "On"
		state[pn][activeButton] = "On";
	end


	-- broadcast EVERYTHING, whether it is On or Off
	-- an example Message to be interpretted by ./visuals/default.lua might look like...
	-- Player2CenterOffMessageCommand
	for i=1,2 do		
		for k,button in ipairs(GameButtons) do
			MESSAGEMAN:Broadcast("Player"..i..button..state[i][button]);
		end
	end
	
end




return Def.ActorFrame {
	
	-- We use this to grab input strings from
	Def.InputList {
		Name="InputList";
		Font="_misoreg hires";
		-- but it's distracting, so hide it
		InitCommand=cmd(diffusealpha,0);
		OnCommand=cmd(queuecommand,"Update");
		UpdateCommand=function(self)
			local inputList = {};
			
			local text = self:GetText();
			
			-- match for the pattern we are looking for
			-- Controller [pn] [button]
			-- and insert them all into a table
			for input in string.gmatch(text, "Controller %d %w+") do
				inputList[#inputList+1] = input;
		    end

			ProcessInputs(inputList);
			
			self:sleep(1/30);
			self:queuecommand("Update");
		end;
	};
	
	Def.DeviceList {
		Font="_misoreg hires";
		InitCommand=cmd(xy,SCREEN_CENTER_X,SCREEN_HEIGHT-60; zoom,0.8; NoStroke);	
	};
		
	LoadActor("visuals");
};