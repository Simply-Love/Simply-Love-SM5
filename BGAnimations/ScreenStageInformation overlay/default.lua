return Def.ActorFrame{
	
	-- I used to use GAMESTATE:ApplyGameCommand() to apply mini from
	-- ./Scripts/SL-PlayerOptions.lua in OptionRowPlayerMini() in SaveSelections()
	-- However, it seems that the SaveSelections function
	-- never gets called if the player(s) proceed onto ScreenPlayerOptions2.
	-- I'm not really sure where else might be a good place to make sure mini is applied.
	-- This seems as good a place as any?
	OnCommand=function(self)
		local Players = GAMESTATE:GetHumanPlayers();
		for pn in ivalues(Players) do
			local mini = getenv("Mini"..ToEnumShortString(pn))
			
			if mini == "Normal" then
				mini = "no mini";
			else
				mini = mini .. " mini";
			end
			
			GAMESTATE:ApplyGameCommand('mod,' ..  mini, pn)
		end
	end;
	
	
	Def.Quad{
		OnCommand=cmd(diffuse,color("0,0,0,1"); xy,SCREEN_CENTER_X, SCREEN_CENTER_Y;zoomto,SCREEN_WIDTH, SCREEN_HEIGHT;);
	};

	LoadActor("heartsplode")..{
		InitCommand=cmd(diffusealpha,0);
		OnCommand=cmd(sleep,0.4; diffuse, GetCurrentColor(); xy,SCREEN_CENTER_X, SCREEN_CENTER_Y; rotationz,10; diffusealpha,0; zoom,0; diffusealpha,0.9; linear,0.6; rotationz,0; zoom,1.1; diffusealpha,0;);
	};
	LoadActor("heartsplode")..{
		InitCommand=cmd(diffusealpha,0);
		OnCommand=cmd(sleep,0.4; diffuse, GetCurrentColor(); xy,SCREEN_CENTER_X, SCREEN_CENTER_Y; rotationy,180; rotationz,-10; diffusealpha,0; zoom,0.2; diffusealpha,0.8; decelerate,0.6; rotationz,0; zoom,1.3; diffusealpha,0;);
	};
	LoadActor("minisplode")..{
		InitCommand=cmd(diffusealpha,0);
		OnCommand=cmd(sleep,0.4; diffuse, GetCurrentColor(); xy,SCREEN_CENTER_X, SCREEN_CENTER_Y; rotationz,10; diffusealpha,0; zoom,0; diffusealpha,1; decelerate,0.8; rotationz,0; zoom,0.9; diffusealpha,0;)
	};
	LoadFont("_wendy small")..{
		InitCommand=cmd(diffusealpha,0);
		OnCommand=function(self)
			self:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y);
			self:accelerate(0.5);
			self:diffusealpha(1);
			
			
			-- TODO: CourseMode
			
			if not PREFSMAN:GetPreference("EventMode") then
				local current_stg =	GAMESTATE:GetCurrentStage()
				local stg_number, text;

				stg_number = string.match(current_stg, "%d+");
				
				
				
				if stg_number then
					if stg_number == tostring(PREFSMAN:GetPreference("SongsPerPlay")) then
						text = "FINAL ROUND";
					else
						text = "ROUND " .. stg_number;
					end
				else
					text = "WHAT'RE YOU TRYNA DO?!"
				end
				
				
				self:settext(text);
				
			elseif PREFSMAN:GetPreference("EventMode") then
				self:settext("EVENT MODE");
			else
				self:setext("STEVEREEN!");
			end

			self:sleep(1);
					
			if self:GetText() == "WHAT'RE YOU TRYNA DO?!" then
				self:accelerate(0.4);
				self:diffusealpha(0);
			end
		end;
	};
};