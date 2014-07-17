local t = Def.ActorFrame{};
local game = GAMESTATE:GetCurrentGame():GetName();


--PLAYER_1
t[#t+1] = Def.ActorFrame{
	Name="Player1Buttons";
	InitCommand=cmd(diffusealpha,0);
	OnCommand=cmd(linear,0.3;diffusealpha,1);
	OffCommand=cmd(linear,0.2;diffusealpha,0);
	
	LoadFont("_wendy small")..{
		Text="PLAYER 1";
		InitCommand=cmd(xy,_screen.cx-150,30;zoom,0.7)
	};
	
	LoadActor(game..".png")..{
		InitCommand=cmd(xy,_screen.cx-150,_screen.cy-80; zoom,0.8);
	};
	LoadActor("buttons.png")..{
		InitCommand=cmd(xy,_screen.cx-150,_screen.cy+80; zoom,0.5);
	};
	
	
	
	--menuleft highlight
	LoadActor("highlightarrow.png")..{
		InitCommand=cmd(xy,_screen.cx-187,_screen.cy+80; rotationz,180; zoom, 0.5;);
		Player1MenuLeftOnMessageCommand=cmd(diffusealpha,1;);
		Player1MenuLeftOffMessageCommand=cmd(diffusealpha,0);
	};
	--menuright highlight
	LoadActor("highlightarrow.png")..{
		InitCommand=cmd(xy,_screen.cx-113,_screen.cy+80; zoom, 0.5;);
		Player1MenuRightOnMessageCommand=cmd(diffusealpha,1;);
		Player1MenuRightOffMessageCommand=cmd(diffusealpha,0);
	};
	--start highlight
	LoadActor("highlightgreen.png")..{
		InitCommand=cmd(xy,_screen.cx-150,_screen.cy+66; zoom, 0.5;);
		Player1StartOnMessageCommand=cmd(diffusealpha,1;);
		Player1StartOffMessageCommand=cmd(diffusealpha,0);
	};
	--select highlight
	LoadActor("highlightred.png")..{
		InitCommand=cmd(xy,_screen.cx-150,_screen.cy+94.5;rotationz,180; zoom, 0.5;);
		Player1SelectOnMessageCommand=cmd(diffusealpha,1;);
		Player1SelectOffMessageCommand=cmd(diffusealpha,0);
	};

	
	
	
	--upleft highlight
	LoadActor("highlight.png")..{
		InitCommand=cmd(xy,_screen.cx-217,_screen.cy-148; zoom, 0.8; );
		Player1UpLeftOnMessageCommand=cmd(diffusealpha,1;);
		Player1UpLeftOffMessageCommand=cmd(diffusealpha,0);
	};
	--up highlight
	LoadActor("highlight.png")..{
		InitCommand=cmd(xy,_screen.cx-150,_screen.cy-148; zoom, 0.8; );
		Player1UpOnMessageCommand=cmd(diffusealpha,1;);
		Player1UpOffMessageCommand=cmd(diffusealpha,0);
	};
	--upright highlight
	LoadActor("highlight.png")..{
		InitCommand=cmd(xy,_screen.cx-83,_screen.cy-148; zoom, 0.8; );
		Player1UpRightOnMessageCommand=cmd(diffusealpha,1;);
		Player1UpRightOffMessageCommand=cmd(diffusealpha,0);
	};
	
	

	--left highlight
	LoadActor("highlight.png")..{
		InitCommand=cmd(xy,_screen.cx-217,_screen.cy-80; zoom, 0.8; );
		Player1LeftOnMessageCommand=cmd(diffusealpha,1);
		Player1LeftOffMessageCommand=cmd(diffusealpha,0);
	};
	--center highlight
	LoadActor("highlight.png")..{
		InitCommand=cmd(xy,_screen.cx-150,_screen.cy-80; zoom, 0.8; );
		Player1CenterOnMessageCommand=cmd(diffusealpha,1);
		Player1CenterOffMessageCommand=cmd(diffusealpha,0);
	};
	--right highlight
	LoadActor("highlight.png")..{
		InitCommand=cmd(xy,_screen.cx-83,_screen.cy-80; zoom, 0.8; );
		Player1RightOnMessageCommand=cmd(diffusealpha,1);
		Player1RightOffMessageCommand=cmd(diffusealpha,0);
	};



	-- downleft highlight
	LoadActor("highlight.png")..{
		InitCommand=cmd(xy,_screen.cx-217,_screen.cy-12; zoom, 0.8; );
		Player1DownLeftOnMessageCommand=cmd(diffusealpha,1);
		Player1DownLeftOffMessageCommand=cmd(diffusealpha,0);
	};
	-- down highlight
	LoadActor("highlight.png")..{
		InitCommand=cmd(xy,_screen.cx-150,_screen.cy-12; zoom, 0.8; );
		Player1DownOnMessageCommand=cmd(diffusealpha,1);
		Player1DownOffMessageCommand=cmd(diffusealpha,0);
	};
	-- downright highlight
	LoadActor("highlight.png")..{
		InitCommand=cmd(xy,_screen.cx-83,_screen.cy-12; zoom, 0.8; );
		Player1DownRightOnMessageCommand=cmd(diffusealpha,1);
		Player1DownRightOffMessageCommand=cmd(diffusealpha,0);
	};

};









--PLAYER_2
t[#t+1] = Def.ActorFrame{
	Name="Player2Buttons";
	InitCommand=cmd(diffusealpha,0);
	OnCommand=cmd(linear,0.3;diffusealpha,1);
	OffCommand=cmd(linear,0.2;diffusealpha,0);
		
	LoadFont("_wendy small")..{
		Text="PLAYER 2";
		InitCommand=cmd(xy,_screen.cx+150,30;zoom,0.7)
	};
	
	LoadActor(game..".png")..{
		InitCommand=cmd(xy,_screen.cx+150,_screen.cy-80; zoom,0.8);
	};
	LoadActor("buttons.png")..{
		InitCommand=cmd(xy,_screen.cx+150,_screen.cy+80; zoom,0.5);
	};
	
	
	
	--menuleft highlight
	LoadActor("highlightarrow.png")..{
		InitCommand=cmd(xy,_screen.cx+113,_screen.cy+80;rotationz,180; zoom, 0.5);
		Player2MenuLeftOnMessageCommand=cmd(diffusealpha,1;);
		Player2MenuLeftOffMessageCommand=cmd(diffusealpha,0);
	};
	--menuright highlight
	LoadActor("highlightarrow.png")..{
		InitCommand=cmd(xy,_screen.cx+187,_screen.cy+80; zoom, 0.5);
		Player2MenuRightOnMessageCommand=cmd(diffusealpha,1;);
		Player2MenuRightOffMessageCommand=cmd(diffusealpha,0);
	};
	--start highlight
	LoadActor("highlightgreen.png")..{
		InitCommand=cmd(xy,_screen.cx+150,_screen.cy+66; zoom, 0.5);
		Player2StartOnMessageCommand=cmd(diffusealpha,1;);
		Player2StartOffMessageCommand=cmd(diffusealpha,0);
	};
	--select highlight
	LoadActor("highlightred.png")..{
		InitCommand=cmd(xy,_screen.cx+150,_screen.cy+94.5; zoom, 0.5);
		Player2SelectOnMessageCommand=cmd(diffusealpha,1;);
		Player2SelectOffMessageCommand=cmd(diffusealpha,0);
	};
	
	
	--upleft highlight
	LoadActor("highlight.png")..{
		InitCommand=cmd(xy,_screen.cx+83,_screen.cy-148; zoom,0.8; );
		Player2UpLeftOnMessageCommand=cmd(diffusealpha,1;);
		Player2UpLeftOffMessageCommand=cmd(diffusealpha,0);
	};
	--up highlight
	LoadActor("highlight.png")..{
		InitCommand=cmd(xy,_screen.cx+150,_screen.cy-148; zoom,0.8; );
		Player2UpOnMessageCommand=cmd(diffusealpha,1;);
		Player2UpOffMessageCommand=cmd(diffusealpha,0);
	};
	--upright highlight
	LoadActor("highlight.png")..{
		InitCommand=cmd(xy,_screen.cx+217,_screen.cy-148; zoom,0.8; );
		Player2UpRightOnMessageCommand=cmd(diffusealpha,1;);
		Player2UpRightOffMessageCommand=cmd(diffusealpha,0);
	};
	
	
	
	--left highlight
	LoadActor("highlight.png")..{
		InitCommand=cmd(xy,_screen.cx+83,_screen.cy-80; zoom,0.8; );
		Player2LeftOnMessageCommand=cmd(diffusealpha,1;);
		Player2LeftOffMessageCommand=cmd(diffusealpha,0);
	};
	--center highlight
	LoadActor("highlight.png")..{
		InitCommand=cmd(xy,_screen.cx+150,_screen.cy-80; zoom,0.8; );
		Player2CenterOnMessageCommand=cmd(diffusealpha,1;);
		Player2CenterOffMessageCommand=cmd(diffusealpha,0);
	};
	--right highlight
	LoadActor("highlight.png")..{
		InitCommand=cmd(xy,_screen.cx+217,_screen.cy-80; zoom,0.8; );
		Player2RightOnMessageCommand=cmd(diffusealpha,1;);
		Player2RightOffMessageCommand=cmd(diffusealpha,0);
	};
	
	
	
	--down highlight
	LoadActor("highlight.png")..{
		InitCommand=cmd(xy,_screen.cx+83,_screen.cy-12; zoom,0.8; );
		Player2DownLeftOnMessageCommand=cmd(diffusealpha,1;);
		Player2DownLeftOffMessageCommand=cmd(diffusealpha,0);
	};
	--down highlight
	LoadActor("highlight.png")..{
		InitCommand=cmd(xy,_screen.cx+150,_screen.cy-12; zoom,0.8; );
		Player2DownOnMessageCommand=cmd(diffusealpha,1;);
		Player2DownOffMessageCommand=cmd(diffusealpha,0);
	};
	--downright highlight
	LoadActor("highlight.png")..{
		InitCommand=cmd(xy,_screen.cx+217,_screen.cy-12; zoom,0.8; );
		Player2DownRightOnMessageCommand=cmd(diffusealpha,1;);
		Player2DownRightOffMessageCommand=cmd(diffusealpha,0);
	};
};

return t;