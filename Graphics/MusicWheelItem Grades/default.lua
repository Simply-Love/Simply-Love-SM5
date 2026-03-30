-- if we're in CourseMode, return a blank Actor now
if GAMESTATE:IsCourseMode() then return NullActor end

local player = nil
local pn = nil

local AwardMap = {
	["StageAward_FullComboW1"] = 1,
	["StageAward_FullComboW2"] = 2,
	["StageAward_SingleDigitW2"] = 2,
	["StageAward_OneW2"] = 2,
	["StageAward_FullComboW3"] = 3,
	["StageAward_SingleDigitW3"] = 3,
	["StageAward_OneW3"] = 3,
	["StageAward_100PercentW3"] = 3,
	-- FullComboW4 technically doesn't exist, but we create it on the fly below.
	["StageAward_FullComboW4"] = 4,
}

local ClearLamp = { color("#0000CC"), color("#990000") }

local function GetLamp(song)
	if player == nil then return nil end
	if not song then return nil end
	
	if not GAMESTATE:GetCurrentSteps(pn) then return nil end
	
	local diff = GAMESTATE:GetCurrentSteps(pn):GetDifficulty()
	
	local stepsList = song:GetAllSteps()
	local steps = nil
	
	for check in ivalues(stepsList) do
		if check:GetDifficulty() == diff and check:GetStepsType() == GAMESTATE:GetCurrentStyle():GetStepsType() then
			steps = check
			break
		end
	end
	
	if steps == nil then return nil end
	
	-- Check ITL File
	local itl_lamp = nil
	local song_dir = song:GetSongDir()
	if song_dir ~= nil and #song_dir ~= 0 then
		if SL[pn].ITLData["pathMap"][song_dir] ~= nil then
			local hash = SL[pn].ITLData["pathMap"][song_dir]
			if SL[pn].ITLData["hashMap"][hash] ~= nil then
				if SL[pn].ITLData["hashMap"][hash]["clearType"] == 5 then
					return 0
				end
			end
		end
	end
	
	local profile = PROFILEMAN:GetProfile(player)
	local high_score_list = profile:GetHighScoreListIfExists(song, steps)
			
	-- If no scores then just return.
	if high_score_list == nil or #high_score_list:GetHighScores() == 0 then
		return nil
	end

	local best_lamp = nil

	for score in ivalues(high_score_list:GetHighScores()) do
		local award = score:GetStageAward()
		
		if award and AwardMap[award] ~= nil then
			best_lamp = math.min(best_lamp and best_lamp or 999, AwardMap[award])
		end
		
		if AwardMap[award] == best_lamp and best_lamp == 1 and score:GetScore() == 0 then
			best_lamp = 0
		elseif best_lamp == nil then
			if score:GetGrade() == "Grade_Failed" then best_lamp = 52
			else best_lamp = 51 end
		end
	end

	return best_lamp
end


-- how many GradeTiers are defined in Metrics.ini?
local num_tiers = THEME:GetMetric("PlayerStageStats", "NumGradeTiersUsed")

-- make a grades table, and dynamically fill it with key/value pairs that we'll use in the
-- Def.Sprite below to set the Sprite to the appropriate state on the spritesheet of grades provided
--
-- keys will be in the format of "Grade_Tier01", "Grade_Tier02", "Grade_Tier03", etc.
-- values will start at 0 and go to (num_tiers-1)
local grades = {
 	["Grade_Tier00"] = 0  -- Manually add a key for Quints
 }
for i=1,num_tiers do
	grades[ ("Grade_Tier%02d"):format(i) ] = i
end
-- assign the "Grade_Failed" key a value equal to num_tiers
grades["Grade_Failed"] = num_tiers + 1

-- This is a quick way to check if a score is a quint.
 -- Technically a hack until we actually get engine support for quints/tracking
 -- W0 but this is good enough for now.
 -- We do this by checking if:
 --  1. Any score exists that has a percentDP of 1.0 (they've quadded)
 --  2. The high score tracked whites (by determining if score < #Fantastics)
 --  3. The number of whites is actually 0
 local function IsQuint(hsl)
 	if hsl == nil then return false end
 
 	for hs in ivalues(hsl:GetHighScores()) do
 		if (hs:GetPercentDP() == 1.0 and
 					hs:GetScore() < hs:GetTapNoteScore("TapNoteScore_W1")
 					and hs:GetScore() == 0) then
 			return true
 		end
 	end
 
 	return false
 end

return Def.ActorFrame{
	LoadActor("GetLamp.lua"),
	
	Def.Sprite{
		Name="Grades",
		Texture=THEME:GetPathG("MusicWheelItem","Grades/grades 1x19.png"),
		InitCommand=function(self) self:zoom( SL_WideScale(0.18, 0.3) ):animate(false) end,

		-- "SetGrade" is broadcast by the engine in MusicWheelItem.cpp.
		-- It will be passed a table with, at minimum, one parameter:
		--     PlayerNumber (PlayerNumber enum as string)
		--
	   -- and potentially three more if the current song/course and steps/trail have a non-null HighScoreList
		--     Grade (GradeTier as number)
		--     NumTimesPlayed (number)
		--     HighScoreList (as of ITGmania 1.0.1 -- NOTE: can be removed in a future version)
		SetGradeCommand=function(self, params)
			if not params.Grade then
				self:visible(false)
				return
			end
	 
			local grade = params.Grade
			if IsQuint(params.HighScoreList) then
				grade = "Grade_Tier00"
			end
	 
			local state = grades[grade]
			if not state then
				self:visible(false)
				return
			end
			
			self:visible(true):setstate(state)
		end,
		
		
	}
}
