if not Branch then Branch = {}; end;



function SelectMusicOrCourse()
	local pm = GAMESTATE:GetPlayMode()
	if pm == "PlayMode_Nonstop"	then
		return "ScreenSelectCourseNonstop"
	else
		return "ScreenSelectMusic"
	end
end


Branch.AfterGameplay = function()
	local pm = GAMESTATE:GetPlayMode()
	if( pm == "PlayMode_Regular" )	then return "ScreenEvaluationStage" end
	if( pm == "PlayMode_Nonstop" )	then return "ScreenEvaluationNonstop" end
end

Branch.AfterInit = function()
	if GAMESTATE:GetCoinMode() == 'CoinMode_Home' then
		return Branch.TitleMenu()
	else
		return "ScreenSimplyLove"
	end
end

-- Let's pretend I understand why this is necessary
Branch.AfterScreenSelectPlayMode = function()
	local gameName = GAMESTATE:GetCurrentGame():GetName();
	if gameName=="techno" then
		return "ScreenSelectStyleTechno"
	else
		return "ScreenSelectStyle"
	end
end



Branch.AfterScreenPlayerOptions = function()
	local nextscreen = getenv("ScreenPlayerOptions")
	
	if nextscreen then
		return nextscreen		
	else
		return "ScreenStageInformation"
	end	
end

Branch.AfterScreenPlayerOptions2 = function()
	local nextscreen = getenv("ScreenPlayerOptions2")
	
	if nextscreen then
		return nextscreen		
	else
		return "ScreenStageInformation"
	end	
end

Branch.SSMCancel = function()

	if GAMESTATE:GetCurrentStageIndex() > 0 then
		return "ScreenEvaluationSummary"
	end

	return Branch.TitleMenu();
end