local Players = GAMESTATE:GetHumanPlayers()
local IsUltraWide = (GetScreenAspectRatio() > 21/9)

local ShouldDisplayStatsForPlayer = function(player)
    local pn = ToEnumShortString(player)
    if SL[pn].ActiveModifiers.DataVisualizations == "Step Statistics" or ThemePrefs.Get("TournamentMode") ~= "Off" then         
    return true else return false end
end

local ShouldDisplayStats = function()
    -- Ultrawide versus is already supported natively.
    if IsUltraWide then return false end

    -- Only use this in Versus + Widescreen.
    if GAMESTATE:GetCurrentStyle():GetName() ~= "versus" or not IsUsingWideScreen() then
        return false
    end

    local shouldDisplay = false
    for player in ivalues(Players) do
        if ShouldDisplayStatsForPlayer(player) then
            shouldDisplay = true
        end
    end
    return shouldDisplay
end

if not ShouldDisplayStats() then
    return
end

local af = Def.ActorFrame{
    InitCommand=function(self)
		self:Center()
    end
}

for player in ivalues(Players) do
    if ShouldDisplayStatsForPlayer(player) and #Players > 1 then
	
		local pn = tonumber(player:sub(-1))
	
        af[#af+1] = Def.Quad{
            InitCommand=function(self)
                self:diffuse(Color.Black)
				self:zoomto(150, SCREEN_HEIGHT)
            end,
        }
        
    end
end

for player in ivalues(Players) do
    if ShouldDisplayStatsForPlayer(player) and #Players > 1 then
        -- No need to reimplement the wheel here. Just use the existing actor and modify it for our use case.
        local judgments = LoadActor("../PerPlayer/StepStatistics/TapNoteJudgments.lua", {player, false})
        judgments.InitCommand = function(self)    
            local StepsOrTrail = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)
            local total_tapnotes = StepsOrTrail:GetRadarValues(player):GetValue( "RadarCategory_Notes" )
    
            -- determine how many digits are needed to express the number of notes in base-10
            local digits = (math.floor(math.log10(total_tapnotes)) + 1)
            -- display a minimum 4 digits for aesthetic reasons
            digits = math.max(4, digits)

            self:zoom(0.8)
            self:y(100)
            self:x(65 * (player==PLAYER_1 and -1 or 1) + 1)

            if digits > 4 then
                -- This works okay enough for 5 and 6 digits.
                self:zoomx(self:GetZoomX() - 0.12 * (digits-4))
            end
        end

        af[#af+1] = judgments

        -- Add a score to Step Stats if it's hidden by the NPS graph.
        if SL[ToEnumShortString(player)].ActiveModifiers.NPSGraphAtTop or ThemePrefs.Get("TournamentMode") ~= "Off" then
            local pn = ToEnumShortString(player)
            local IsEX = SL[pn].ActiveModifiers.ShowEXScore
            if ThemePrefs.Get("TournamentMode") ~= "Off" then IsEX = ThemePrefs.Get("TournamentMode") == "EX" and true or false end

            af[#af+1] = LoadFont(ThemePrefs.Get("ThemeFont") .. " numbers")..{
                Text="0.00",
                InitCommand=function(self)
                    self:valign(1):horizalign(right)
                    self:zoom(0.25)
                    if player == PLAYER_1 then
                        self:xy(-7, -150)
                    else
                        self:xy(65, -150)
                    end

                    if IsEX then
                        -- If EX Score, let's diffuse it to be the same as the FA+ top window.
                        -- This will make it consistent with the EX Score Pane.
                        self:diffuse(SL.JudgmentColors["FA+"][1])
                    end
                end,
                JudgmentMessageCommand=function(self, params)
                    if params.Player ~= player then return end
                    self:queuecommand("RedrawScore")
                end,
                RedrawScoreCommand=function(self)
                    if not IsEX then
                        local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
                        local dance_points = pss:GetPercentDancePoints()
                        local percent = FormatPercentScore( dance_points ):sub(1,-2)
                        self:settext(percent)
                    end
                end,
                ExCountsChangedMessageCommand=function(self, params)
                    if params.Player ~= player then return end
            
                    if IsEX then
                        self:settext(("%.02f"):format(params.ExScore))
                    end
                end,
            }
        end
    end
end

af[#af+1] = Def.Banner{
    CurrentSongChangedMessageCommand=function(self)
		self:LoadFromSong( GAMESTATE:GetCurrentSong() )
		self:setsize(418,164):zoom(0.3):addy(70)
    end
}
af[#af+1] = Def.Banner{
    CurrentSongChangedMessageCommand=function(self)
		if GAMESTATE:IsCourseMode() then
			self:LoadFromCourse( GAMESTATE:GetCurrentCourse() )
		else
			self:LoadFromSongGroup( GAMESTATE:GetCurrentSong():GetGroupName() )
		end
		self:setsize(418,164):zoom(0.25):addy(125)
    end
}

return af