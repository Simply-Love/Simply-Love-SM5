local args = ...;
local Player = args[1];
local CanEnterName = args[2] or false;

local charWidth = 40.5;
local finished = false;

-- the highscore name
local playerName = "";

-- the character limit
local limit = tonumber(THEME:GetMetric("ScreenNameEntryTraditional", "MaxRankingNameLength"));


-- machineProfile contains the overall high scores per song
local machineProfile = PROFILEMAN:GetMachineProfile();

if PROFILEMAN:IsPersistentProfile(Player) then
	playerName = PROFILEMAN:GetProfile(Player):GetLastUsedHighScoreName();
	setenv("HighScoreName" .. ToEnumShortString(Player), playerName );
end


local IsEnteringName = CanEnterName;


local possibleCharacters = {
	"&BACK;", "&OK;",
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
	"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
	"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "?", "!"	
};

local FiveLetters = {
	--the index will potentially go negative or very large
	--the bind function will keep it in check
	--for now, initialize this to 3, which is "A"
	center = 3,
	
	--I don't even care that this function name is so long
	--it's perfectly descriptive
	GetIndexOfCharRelativeFromCenter = function(self, v)
		return self:bind(self.center + v)
	end,
	
	--internal logic
	bind = function(self, v)
		
		if v % #possibleCharacters == 0 then
			return #possibleCharacters;
		else
			return v % #possibleCharacters;
		end
	end
}; 


local Letters = Def.ActorFrame{
	Name="LetterAF";
	InitCommand=function(self)
		self:y(50);
		self:MaskDest();	
	end;
	OnCommand=function(self)
		self:visible( CanEnterName );
		
		-- if a name is available from a profile
		if playerName ~= "" then
			self:queuecommand("GoToOkay");
		end
	end;
	GoToOkayCommand=function(self)
		--the player just entered the maximum number of characters permitted
		--hide everything whereever in the alphabet we are
		for i=-3,3,1 do
			self:GetChild(tostring(FiveLetters:GetIndexOfCharRelativeFromCenter(i))):visible(false);
		end
		
		--manually set the alphabet center to be &OKAY;
		FiveLetters.center = 2;
		
		--and redraw/position everything
		for i=-3,3,1 do
			self:GetChild(tostring(FiveLetters:GetIndexOfCharRelativeFromCenter(i))):visible(true);
			self:GetChild(tostring(FiveLetters:GetIndexOfCharRelativeFromCenter(i))):queuecommand("Position");
		end
	end;
	
	MenuRightP1MessageCommand=function(self)		
		if Player == PLAYER_1 and IsEnteringName then
			self:queuecommand("MoveRight");
		end
	end;
	MenuLeftP1MessageCommand=function(self)	
		if Player == PLAYER_1 and IsEnteringName then
			self:queuecommand("MoveLeft");
		end
	end;
	MenuRightP2MessageCommand=function(self)
		if Player == PLAYER_2 and IsEnteringName then
			self:queuecommand("MoveRight");
		end
	end;
	MenuLeftP2MessageCommand=function(self)
		if Player == PLAYER_2 and IsEnteringName then
			self:queuecommand("MoveLeft");
		end
	end;
	
	MoveLeftCommand=function(self)
		
		-- hide the right-most character, decrement our center, and make the left-most char visible
		self:GetChild(tostring(FiveLetters:GetIndexOfCharRelativeFromCenter(2))):visible(false);
		FiveLetters.center = FiveLetters.center - 1;
		self:GetChild(tostring(FiveLetters:GetIndexOfCharRelativeFromCenter(2))):visible(true);
		self:GetChild(tostring(FiveLetters:GetIndexOfCharRelativeFromCenter(-2))):visible(true);

		--the Position command positions letters appropriately
		--even though only five are visible at any given moment
		--always have 1 extra on each side (-3 and 3) "in postion" 
		--this makes tweening in from the sides appear more natural
		for i=-3,3,1 do
			self:GetChild(tostring(FiveLetters:GetIndexOfCharRelativeFromCenter(i))):queuecommand("Position");
		end

		self:GetChild("move"):playforplayer(Player);

	end;
	MoveRightCommand=function(self)
		
		-- hide the left-most character, increment our center, and make the right-most char visible
		self:GetChild(tostring(FiveLetters:GetIndexOfCharRelativeFromCenter(-2))):visible(false);
		FiveLetters.center = FiveLetters.center + 1;
		self:GetChild(tostring(FiveLetters:GetIndexOfCharRelativeFromCenter(-2))):visible(true);
		self:GetChild(tostring(FiveLetters:GetIndexOfCharRelativeFromCenter(2))):visible(true);

		for i=-3,3,1 do
			self:GetChild(tostring(FiveLetters:GetIndexOfCharRelativeFromCenter(i))):queuecommand("Position");
		end
		
		self:GetChild("move"):playforplayer(Player);
		
	end;
	CodeMessageCommand=function(self, param)
		local pn = param.PlayerNumber;
	
		if pn == Player and CanEnterName and IsEnteringName then
			
			-- if the START button is pushed
			if param.Name == "Enter" then
				
				-- this "selectionText" var will grab whatever char is currently at relative index 0
				-- that is, the character in the middle of the cursor
				-- thus, selection can be A-Z, 0-9, ?, !, BACK, or OK
				local selectionText = self:GetChild(tostring(FiveLetters:GetIndexOfCharRelativeFromCenter(0))):GetText();
				
				--we can't do direct string comparison on these
				--so I opted to compare them to the text of dummy BitmapText entities
				local dummyOKtext = self:GetChild("DummyOK"):GetText();
				local dummyBACKtext = self:GetChild("DummyBACK"):GetText();
				
				if selectionText == dummyBACKtext then
					
					if string.len(playerName) > 0 then			
						playerName = string.sub(playerName,1,-2);
						setenv("HighScoreName" .. ToEnumShortString(Player), playerName );
						
						self:GetChild("delete"):playforplayer(Player);
						self:GetParent():GetChild("PlayerName"..ToEnumShortString(Player)):queuecommand("Set");
					else
						self:GetChild("invalid"):playforplayer(Player);
					end
				
				
				
				elseif selectionText == dummyOKtext then
					self:queuecommand("Finish");

				-- otherwise selectionText is any valid highscorename character: A-Z, 0-9, ?, or !
				else
					if string.len(playerName) < limit then
						
						playerName = playerName..selectionText;
						setenv("HighScoreName" .. ToEnumShortString(Player), playerName )
						
						self:GetChild("enter"):playforplayer(Player);
						self:GetParent():GetChild("PlayerName"..ToEnumShortString(Player)):queuecommand("Set");
						
						-- if this player has now reached the character limit
						if string.len(playerName) == limit then
							self:queuecommand("GoToOkay");
						end
					else
						self:GetChild("invalid"):playforplayer(Player);
					end
				
				end
			
			end
		
			-- if the SELECT button is pushed
			if param.Name == "Backspace" then
				if string.len(playerName) > 0 then
					playerName = string.sub(playerName,1,-2);
					setenv("HighScoreName" .. ToEnumShortString(Player), playerName )
					
					self:GetChild("delete"):playforplayer(Player);
					self:GetParent():GetChild("PlayerName"..ToEnumShortString(Player)):queuecommand("Set");
				else
					self:GetChild("invalid"):playforplayer(Player);
				end
			end
		end
	end;
	MenuTimerExpiredMessageCommand=function(self, param)
		self:queuecommand("Finish");
	end;
	FinishCommand=function(self)
		self:GetChild("enter"):playforplayer(Player);
		self:diffusealpha(0);
		self:GetParent():GetChild("Cursor"):diffusealpha(0);
		IsEnteringName = false;
		MESSAGEMAN:Broadcast("DoneEnteringName" .. ToEnumShortString(Player) );
	end
};


-- this is a generic variable we'll use to set the common attributes ALL letters
-- initially share in common
local letter = LoadFont("ScreenNameEntryTraditional entry")..{
	InitCommand=cmd(zoom,0.5; shadowlength,0; visible, false; );
};


-- run through all possible characters and add them to the Letters ActorFrame
-- the Name attribute of each BitmapText letter will be its index from
-- the possibleCharacters table; this is kind of hackish, but I don't know a better way
-- still, it allows automated math, and then we can stringify the results and lookup
-- specific BitmapText entities via GetChild("")
for k,l in ipairs(possibleCharacters) do
	
	Letters[#Letters+1] = letter..{
		Name = k;
		Text = l;
		OnCommand=function(self)
			
			self:queuecommand("Position");
			for i=-3,3,1 do
				self:GetParent():GetChild(FiveLetters:GetIndexOfCharRelativeFromCenter(i)):visible(true);
			end
		end;
		PositionCommand=function(self)
		
			for i=-3,3,1 do
				if self:GetName() == tostring(FiveLetters:GetIndexOfCharRelativeFromCenter(i)) then
					self:finishtweening();
					self:linear(0.075);
					self:x(charWidth * i);
				end
			end
			
		end;
	};

end;

-- sounds
Letters[#Letters+1] = LoadActor( THEME:GetPathS("", "_change value")	)..{Name="delete"; SupportPan = true; };
Letters[#Letters+1] = LoadActor( THEME:GetPathS("Common", "start")		)..{Name="enter"; SupportPan = true; };
Letters[#Letters+1] = LoadActor( THEME:GetPathS("MusicWheel", "change")	)..{Name="move"; SupportPan = true; };
Letters[#Letters+1] = LoadActor( THEME:GetPathS("common", "invalid")	)..{Name="invalid"; SupportPan = true; };

--This is pretty stupid but it's my fault for trying to
--perform string comparison on mapped characters
--anyway...
--we need these two dummy BitmapText entities for comparing
--when enter is pressed on either real one
Letters[#Letters+1] = LoadFont("ScreenNameEntryTraditional entry")..{
	Name="DummyOK";
	Text="&OK;";
	InitCommand=cmd(visible, false; );
};
Letters[#Letters+1] = LoadFont("ScreenNameEntryTraditional entry")..{
	Name="DummyBACK";
	Text="&BACK;";
	InitCommand=cmd(visible, false; );
};






local t = Def.ActorFrame{
	InitCommand=function(self)
		if Player == PLAYER_1 then
			self:x(_screen.cx-160);
		elseif Player == PLAYER_2 then
			self:x(_screen.cx+160);
		end
		self:y(_screen.cy-20);
	end;
	
	
	-- the quad behind the playerName	
	Def.Quad{
		InitCommand=cmd(diffuse,color("0,0,0,0.75"); zoomto, 300, _screen.h/7);
		OnCommand=cmd();
	};

	-- the quad behind the scrolling alphabet
	Def.Quad{
		InitCommand=cmd(diffuse,color("0,0,0,0.5"); zoomto, 300, _screen.h/10);
		OnCommand=cmd(y, 58);
	};
	
	-- the quad behind the highscore list
	Def.Quad{
		InitCommand=cmd(diffuse,color("0,0,0,0.25"); zoomto, 300, _screen.h/4);
		OnCommand=cmd(y,142);
	};
};


t[#t+1] = Letters;
t[#t+1] = LoadActor("Cursor.png")..{
	Name="Cursor";
	InitCommand=cmd(diffuse,PlayerColor(Player); zoom,0.5;);
	OnCommand=function(self)
		self:visible( CanEnterName );
		self:y(50);
	end;
};
t[#t+1] = LoadFont("ScreenNameEntryTraditional entry")..{
	Name="PlayerName"..ToEnumShortString(Player);
	InitCommand=cmd(zoom,0.75;halign,0; x,-80; y,-12;);
	OnCommand=function(self)
		self:visible( CanEnterName );
		self:settext(playerName);
	end;
	SetCommand=function(self)
		self:settext(playerName);
	end;
};
	
t[#t+1] = LoadFont("_wendy small")..{
	Text=THEME:GetString("ScreenNameEntryActual","OutOfRanking");
	InitCommand=cmd(zoom,0.7; diffuse,PlayerColor(Player); y, 58);
	OnCommand=function(self)
		self:visible(not CanEnterName);
	end;
};


return t;