local t = Def.ActorFrame{
	Def.Quad{
		InitCommand=cmd(FullScreen;diffuse,color("#fffffb00"));
		OnCommand=function(self)
			self:decelerate(1);
			-- well, debug mode doesn't exist anymore, right?
			if not getenv("Debug") then
				self:diffuse(color("#ffffffFF"));
			else
				self:diffuse(color("#000000FF"));
			end;
		end;
	};
};

return t;