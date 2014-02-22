local index = Var("GameCommand"):GetIndex();


local function Regenbogen( s )
	local constantWait = 0.04;
	local currentIteration  = tonumber(string.sub(s:GetName(),7));
	local currentMiddleItem = SCREENMAN:GetTopScreen():GetChild("Scroller"):GetCurrentItem();
							
	if currentIteration == (currentMiddleItem-4)%12 then
		s:sleep(constantWait*1);
	elseif currentIteration == (currentMiddleItem-3)%12 then
		s:sleep(constantWait*2);
	elseif currentIteration == (currentMiddleItem-2)%12 then
		s:sleep(constantWait*3);
	elseif currentIteration == (currentMiddleItem-1)%12 then
		s:sleep(constantWait*4);
	elseif currentIteration == (currentMiddleItem)%12 then
		s:sleep(constantWait*5);
	elseif currentIteration == (currentMiddleItem+1)%12 then
		s:sleep(constantWait*6);
	elseif currentIteration == (currentMiddleItem+2)%12 then
		s:sleep(constantWait*7);
	elseif currentIteration == (currentMiddleItem+3)%12 then
		s:sleep(constantWait*8);
	elseif currentIteration == (currentMiddleItem+4)%12 then
		s:sleep(constantWait*9);
	end
end


local t = Def.ActorFrame {
			
	LoadActor("heart.png") .. {
		Name="Choice"..index;
		InitCommand=cmd(diffusealpha,0;);
		OnCommand=function(self)
			Regenbogen(self);
			self:linear(0.2)
			self:diffusealpha(1);
		end;
		OffCommand=function(self)
			Regenbogen(self)
			self:linear(0.2);
			self:diffusealpha(0);
		end;
		GainFocusCommand=function(self)
		end;
		LoseFocusCommand=function(self)
		end;
	};
};

return t;