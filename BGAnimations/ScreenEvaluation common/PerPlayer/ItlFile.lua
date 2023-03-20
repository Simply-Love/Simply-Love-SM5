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
	end
}

return t