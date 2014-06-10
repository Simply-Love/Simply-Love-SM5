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

-- Let's pretend I understand why this is necessary
Branch.AfterScreenSelectPlayMode = function()
	local gameName = GAMESTATE:GetCurrentGame():GetName();
	if gameName=="techno" then
		return "ScreenSelectStyleTechno"
	else
		return "ScreenSelectStyle"
	end
end



Branch.PlayerOptions = function()
	if SCREENMAN:GetTopScreen():GetGoToOptions() then
		return "ScreenPlayerOptions"
	else
		return "ScreenGameplay"
	end
end
	
Branch.AfterScreenPlayerOptions = function()
	return getenv("ScreenPlayerOptions") or Branch.GameplayScreen();
end

Branch.AfterScreenPlayerOptions2 = function()
	return getenv("ScreenPlayerOptions2") or Branch.GameplayScreen();
end

Branch.SSMCancel = function()

	if GAMESTATE:GetCurrentStageIndex() > 0 then
		return "ScreenEvaluationSummary"
	end

	return Branch.TitleMenu();
end