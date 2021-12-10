local Players = GAMESTATE:GetHumanPlayers()
local IsUltraWide = (GetScreenAspectRatio() > 21/9)

local ShouldDisplayStatsForPlayer = function(player)
    local pn = ToEnumShortString(player)
    return SL[pn].ActiveModifiers.DataVisualizations == "Step Statistics"
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
        if SL[ToEnumShortString(player)].ActiveModifiers.NPSGraphAtTop then
            af[#af+1] = LoadFont("Wendy/_wendy monospace numbers")..{
                Text="0.00",
                InitCommand=function(self)
                    self:valign(1):horizalign(right)
                    self:zoom(0.25)
                    if player == PLAYER_1 then
                        self:xy(-7, -150)
                    else
                        self:xy(65, -150)
                    end
                end,
                JudgmentMessageCommand=function(self, params)
                    if params.Player ~= player then return end

                    local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
                    dance_points = pss:GetPercentDancePoints()
                    percent = FormatPercentScore( dance_points ):sub(1,-2)
                    self:settext(percent)
                end
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

return af