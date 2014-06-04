local Players = GAMESTATE:GetHumanPlayers();

local t = Def.ActorFrame{};

t[#t+1] = Def.Actor {
	BeginCommand=function(self)
		if SCREENMAN:GetTopScreen():HaveProfileToSave() then
			
			for pn in ivalues(Players) do
				PROFILEMAN:SaveProfile(pn);
			end
		end;
		
		self:queuecommand("Load");
	end;
	LoadCommand=function()
		SCREENMAN:GetTopScreen():Continue();
	end;
};

return t;