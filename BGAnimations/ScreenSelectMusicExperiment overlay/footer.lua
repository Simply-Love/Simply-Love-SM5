local af = Def.ActorFrame {

	Def.Quad{
		Name="Footer",
		InitCommand=function(self)
			self:zoomto(_screen.w, 32):vertalign(bottom):halign(0):y(_screen.h)
			self:diffuse({0.65,0.65,0.65,1})
		end,
	},
	
}
for player in ivalues({PLAYER_1, PLAYER_2}) do
	af[#af+1] = LoadActor("./PerPlayer/FooterHelpText.lua", player)
end

return af