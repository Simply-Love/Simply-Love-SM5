local t = Def.ActorFrame {};

t[#t+1] = Def.ActorFrame{

	Def.Quad{
		InitCommand=cmd(diffuse,color("0,0,0,1"); xy,SCREEN_CENTER_X, SCREEN_CENTER_Y;);
		OnCommand=cmd(zoomto,SCREEN_WIDTH,SCREEN_HEIGHT; accelerate,0.6; diffusealpha,0;);
	};
	
	LoadFont("_wendy small")..{
		InitCommand=cmd(shadowlength,1);
		OnCommand=function(self)
			self:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y);
						
			-- TODO: CourseMode
			
			if not PREFSMAN:GetPreference("EventMode") then
				local current_stg =	GAMESTATE:GetCurrentStage()
				local stg_number, text;

				if current_stg == "Stage_Final" then
					text = "FINAL ROUND";
				else
					stg_number = string.match(current_stg, "%d+");
					
					if stg_number then
						text = "ROUND " .. stg_number;
					else
						text = "WHAT'RE YOU TRYNA DO?!"
					end
				end
				
				self:settext(text);
				
			elseif PREFSMAN:GetPreference("EventMode") then
				self:settext("EVENT MODE");
			else
				self:setext("STEVEREEN!");
			end
			
			self:sleep(1);
			self:accelerate(0.33);
			self:zoom(0.4);
			self:y(SCREEN_HEIGHT-30);
		end;
	};
};




return t;