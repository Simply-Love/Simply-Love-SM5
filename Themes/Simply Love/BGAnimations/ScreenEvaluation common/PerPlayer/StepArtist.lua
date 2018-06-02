local player = ...
local stepartist = ""

if GAMESTATE:IsCourseMode() then
	local course = GAMESTATE:GetCurrentCourse()
	if course then
		stepartist = course:GetScripter()
	end
else
	local CurrentSteps = GAMESTATE:GetCurrentSteps(player)
	if CurrentSteps then
		stepartist = CurrentSteps:GetAuthorCredit()
	end
end


return LoadFont("_miso")..{
	Text=stepartist,
	InitCommand=cmd(zoom, 0.7; xy, 115,_screen.cy-80 ),
	OnCommand=function(self)
		if player == PLAYER_1 then
			self:x( self:GetX() * -1 )
			self:horizalign(left)
		else
			self:horizalign(right)
		end
	end
}