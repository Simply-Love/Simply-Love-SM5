return Def.ActorFrame{
	CodeMessageCommand=function(self, params)
		if params.Name == "Restart" then
			SCREENMAN:SetNewScreen("ScreenGameplay")
		end
	end
}
