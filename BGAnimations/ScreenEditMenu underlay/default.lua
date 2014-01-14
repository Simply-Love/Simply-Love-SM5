-- down lower in this file, we loop seven times to create seven "rows" of grey quads
-- one for each: group, song, type, steps, fill type, fill steps, action
-- in that loop, rowYvalues will be filled with each row's Y value (defined in metrics)
local rowYvalues = {};


local t = Def.ActorFrame{
	OnCommand=cmd(queuecommand, "Hax");
	--playcommand seems more responsive than queuecommand, so use it here
	--or else we see a frame or two where the cursor color hasn't been applied yet (HAX)
	EditMenuChangeMessageCommand=cmd(playcommand, "Hax");
	HaxCommand=function(self)
		
		local topscreen = SCREENMAN:GetTopScreen();
		
		if topscreen then
			
			local editMenu = topscreen:GetChild("EditMenu");	
			local cursor = editMenu:GetChild("");
			local songTextBanner = editMenu:GetChild("SongTextBanner");
			
			
			if cursor then
				local cursorY = cursor:GetY();
				
				for i=1,#rowYvalues do
					if cursorY == rowYvalues[i] then
						editMenu:GetChild("Label"..i):diffuse(color("#000000"));
						editMenu:GetChild("Label"..i):shadowlength(0);
						
						if cursorY == rowYvalues[2] then
							songTextBanner:GetChild("Title"):diffuse(color("#000000"));
							songTextBanner:GetChild("Title"):shadowlength(0);
							songTextBanner:GetChild("Subtitle"):diffuse(color("#000000"));
							songTextBanner:GetChild("Subtitle"):shadowlength(0);
						else
							editMenu:GetChild("Value"..i):diffuse(color("#000000"));
							editMenu:GetChild("Value"..i):shadowlength(0);
						end
					else
						editMenu:GetChild("Label"..i):diffuse(color("#FFFFFF"));
						editMenu:GetChild("Value"..i):diffuse(color("#FFFFFF"));
						editMenu:GetChild("Label"..i):shadowlength(1);
						editMenu:GetChild("Value"..i):shadowlength(1);
						
						if cursorY ~= rowYvalues[2] then
							songTextBanner:GetChild("Title"):diffuse(color("#FFFFFF"));
							songTextBanner:GetChild("Title"):shadowlength(1);
							songTextBanner:GetChild("Subtitle"):diffuse(color("#FFFFFF"));
							songTextBanner:GetChild("Subtitle"):shadowlength(1);
						end
					end
				end

				
				if cursor:GetY() == rowYvalues[7] then
					cursor:diffuse(PlayerColor(PLAYER_2))
				else
					cursor:diffuse(GetCurrentColor())
				end
				cursor:zoom(1);
				cursor:x(SCREEN_CENTER_X);
				cursor:setsize(SCREEN_WIDTH*0.9 - 4,SCREEN_HEIGHT*0.1);
			end
		end
	end;
};


-- the overall BG
t[#t+1] = Def.Quad {
	InitCommand = cmd(Center;zoomto,SCREEN_WIDTH*0.9,SCREEN_HEIGHT*0.75;diffuse,color("#000000")),
}


-- loop seven times to create seven dark-grey rows
for i=1,7 do
	-- a row
	t[#t+1] = Def.Quad {
		InitCommand=cmd(Center;zoomto,SCREEN_WIDTH*0.9,SCREEN_HEIGHT*0.09;diffuse,color("#071016"));
		OnCommand=cmd(y,40+ (i*45));
	};
	
	-- fill our table with each row's Y value from the Metrics
	rowYvalues[#rowYvalues+1] = THEME:GetMetric("EditMenu", "Row"..i.."Y");
	
end

-- the grey BG for row labels
t[#t+1] = Def.Quad {
	InitCommand = cmd(Center;zoomto,SCREEN_WIDTH*0.15,SCREEN_HEIGHT*0.75;diffuse,color("#212831"); x, SCREEN_CENTER_X-WideScale(240,320)),
}

-- the grey BG for the instructions at the bottom
t[#t+1] = Def.Quad {
	InitCommand=cmd(zoomto,SCREEN_WIDTH*0.9 - SCREEN_WIDTH*0.15 - 2,SCREEN_HEIGHT*0.09;diffuse,color("#212831"););
	OnCommand=function(self)
		self:xy(SCREEN_CENTER_X + WideScale(49,65), 400)
	end
}


-- white border
t[#t+1] = Border(SCREEN_WIDTH*0.9, SCREEN_HEIGHT*0.75, 2) .. {
	InitCommand = cmd(Center),
}

return t;