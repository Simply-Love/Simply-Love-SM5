local game = GAMESTATE:GetCurrentGame():GetName()

local af = Def.ActorFrame {
	OffCommand=function(self) self:sleep(0.4) end
}

-- for these specific games
if (game=="dance" or game=="pump" or game=="techno") then
	local testLights = LoadActor(THEME:GetPathB("", "_modules/TestLights"))

	af[#af+1] = testLights
end

return af