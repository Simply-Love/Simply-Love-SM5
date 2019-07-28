-- assume that all human players failed
local img = "failed text.png"

-- loop through all available human players
for player in ivalues(GAMESTATE:GetHumanPlayers()) do
	-- if any of them passed, we want to display the "cleared" graphic
	if not STATSMAN:GetCurStageStats():GetPlayerStageStats(player):GetFailed() then
		img = "cleared text.png"
	end
end

return Def.ActorFrame {
	Def.Quad{
		InitCommand=cmd(FullScreen; diffuse, Color.Black),
		OnCommand=cmd(sleep,0.2; linear,0.5; diffusealpha,0),
	},

	LoadActor(img)..{
		InitCommand=cmd(Center; zoom,0.8; diffusealpha,0),
		OnCommand=cmd(accelerate,0.4; diffusealpha,1; sleep,0.6; decelerate,0.4; diffusealpha,0)
	}
}