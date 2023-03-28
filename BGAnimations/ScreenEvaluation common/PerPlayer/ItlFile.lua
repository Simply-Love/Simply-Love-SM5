local player = ...

if (SL.Global.GameMode == "Casual" or
		GAMESTATE:IsCourseMode() or
		not IsItlActive() or
		not IsItlSong(player) or
		GAMESTATE:GetCurrentGame():GetName() ~= "dance") then
	return
end

local t = Def.ActorFrame {
	OnCommand=function(self)
		UpdateItlData(player)
		-- This doesn't need to be a global message
		if SCREENMAN:GetTopScreen():GetName() == "ScreenEvaluationStage" then MESSAGEMAN:Broadcast("ItlDataReady") end
	end
}

return t