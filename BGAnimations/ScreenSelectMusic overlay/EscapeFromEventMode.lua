local t = Def.Actor{ InitCommand=function(self) self:visible(false) end }

if PREFSMAN:GetPreference("EventMode") then
	t.CodeMessageCommand=function(self, params)
		if params.Name == "EscapeFromEventMode" then
			local topscreen = SCREENMAN:GetTopScreen()
			if topscreen then
				topscreen:SetNextScreenName( topscreen:GetPrevScreenName() ):StartTransitioningScreen("SM_GoToNextScreen")
			end
		end
	end
end

return t