if GAMESTATE:IsCourseMode() then return end

local player = ...
local pn = ToEnumShortString(player)
local p = PlayerNumber:Reverse()[player]
local show = false
local nsj = GAMESTATE:GetNumSidesJoined()

local function getInputHandler(actor)
    return (function (event)
	if event.GameButton == "MenuLeft" and event.PlayerNumber == player and GAMESTATE:IsHumanPlayer(event.PlayerNumber) and nsj == 1 then
        if event.type == "InputEventType_FirstPress" then
                show = false
                actor:queuecommand("UpdateGraphState")
		elseif event.type == "InputEventType_Release" or not GAMESTATE:IsHumanPlayer(event.PlayerNumber) then
                show = true
                actor:queuecommand("UpdateGraphState")
		end
	end
	if event.GameButton == "MenuRight" and event.PlayerNumber == player and GAMESTATE:IsHumanPlayer(event.PlayerNumber) and nsj == 1 then
        if event.type == "InputEventType_FirstPress" then
                show = false
                actor:queuecommand("UpdateGraphState")
		elseif event.type == "InputEventType_Release" or not GAMESTATE:IsHumanPlayer(event.PlayerNumber) then
                show = true
                actor:queuecommand("UpdateGraphState")
		end
	end
	if event.GameButton == "MenuLeft" and nsj == 2 then
        if event.type == "InputEventType_FirstPress" then
                show = false
                actor:queuecommand("UpdateGraphState")
		elseif event.type == "InputEventType_Release" then
                show = true
                actor:queuecommand("UpdateGraphState")
		end
	end
	if event.GameButton == "MenuRight" and nsj == 2 then
        if event.type == "InputEventType_FirstPress" then
                show = false
                actor:queuecommand("UpdateGraphState")
		elseif event.type == "InputEventType_Release" then
                show = true
                actor:queuecommand("UpdateGraphState")
		end
	end

        return false
    end)
end

local bannerWidth = IsUsingWideScreen() and WideScale(180,290) or 334
local bannerHeight = IsUsingWideScreen() and 160 or 148
local padding = 12

return Def.ActorFrame {
    -- song and course changes
    OnCommand=cmd(queuecommand, "StepsHaveChanged"),
    CurrentSongChangedMessageCommand=cmd(queuecommand, "StepsHaveChanged"),
    CurrentCourseChangedMessageCommand=cmd(queuecommand, "StepsHaveChanged"),
	CurrentStepsP1ChangedMessageCommand = cmd(queuecommand, "StepsHaveChanged"),
	CurrentStepsP2ChangedMessageCommand = cmd(queuecommand, "StepsHaveChanged"),

    InitCommand=function(self)
        local zoom, xPos

        if IsUsingWideScreen() then
            xPos = WideScale(1,0)
        else
            xPos = 0
        end
		
        self:x(xPos)
		self:y(IsUsingWideScreen() and 272 or 355)

        if (player == PLAYER_1 and GAMESTATE:IsHumanPlayer(PLAYER_1)) then
            show = true
			if IsUsingWideScreen() then
			elseif nsj == 1 then
				self:addy(-82)
			end
        end

        if (player == PLAYER_2 and GAMESTATE:IsHumanPlayer(PLAYER_2)) then
            show = true
            if IsUsingWideScreen() then
				self:addx(WideScale(482,587))
			else
				self:addy(-82)
			end
        end

        self:diffusealpha(0)
        self:queuecommand("Capture")
    end,

    CaptureCommand=function(self)
        SCREENMAN:GetTopScreen():AddInputCallback(getInputHandler(self))
    end,
    
    StepsHaveChangedCommand=function(self, params)
        if show then
            self:queuecommand("UpdateGraphState")
        end
    end,

    

    UpdateGraphStateCommand=function(self, params)
        if show and not GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentSong() then
            local song = GAMESTATE:GetCurrentSong()
            local steps = GAMESTATE:GetCurrentSteps(player)
            self:playcommand("ChangeSteps", {song=song, steps=steps})
            self:stoptweening()
            self:linear(0.1):diffusealpha(0.9)
        else
            self:stoptweening()
            self:linear(0.1):diffusealpha(0)
        end
    end,
	
--- The backgound for the density graph since apparently the one in the NPSHistogram doesn't wanna show up ?
	Def.Quad {
        InitCommand=function(self)
            self:zoomtowidth(IsUsingWideScreen() and WideScale(bannerWidth/1.12,bannerWidth/1.09) or bannerWidth/1.079)
			:zoomtoheight(IsUsingWideScreen() and bannerHeight/2.58 or bannerHeight/2.65)
                :align(0,1)
                :diffuse(color("#4D6677"))
        end
    },

--- Here be thee density graph generation wowie
    NPS_Histogram(player,bannerWidth - (padding * 2), bannerHeight / 2 - (padding * 1.5)),

--- This is the background for the breakdown text to make it legible.
   Def.Quad {
        InitCommand=function(self)
            self:zoomto(bannerWidth - (padding * 2)+1, 20)
                :diffuse(color("#000000"))
                :diffusealpha(0.8)
                :align(0, 0)
				:x(IsUsingWideScreen() and 0 or -1.4)
                :y(IsUsingWideScreen() and bannerHeight / 2 - (padding * 1.5) - 82 or bannerHeight / 2 - (padding * 1.5) - 76)
        end,
    },
	
    --- Breakdown text
    Def.BitmapText{
        Font="Miso/_miso",
        InitCommand=function(self)
            self:diffuse(color("#ffffff"))
                :horizalign("left")
                :y(IsUsingWideScreen() and bannerHeight / 2 - (padding * 1.5) - 80 or bannerHeight / 2 - (padding * 1.5) - 74)
                :x(5)
                :maxwidth(bannerWidth - (padding * 2) - 10)
                :align(0, 0)
                :Stroke(color("#000000"))
        end,

        StepsHaveChangedCommand=function(self, params)
            if show then
                self:queuecommand("UpdateGraphState")
            end
        end,

        UpdateGraphStateCommand=function(self)
            if show and not GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentSong() then
				local SongDir = GAMESTATE:GetCurrentSong():GetSongDir()
                local Steps = GAMESTATE:GetCurrentSteps(player)
				
				local StepsType = ToEnumShortString( Steps:GetStepsType() ):gsub("_", "-"):lower()
                local Difficulty = ToEnumShortString( Steps:GetDifficulty() )
				-- This displays the breakdown of the chart, but this shit is so fucking broken lol
                local breakdown = GetBreakdown(Steps,SongDir, StepsType, Difficulty)
                
                if breakdown == "" or breakdown == nil then
                    self:settext("No streams!")
                else
                    self:settext("Streams: " .. breakdown)
                end 
                return true
            end
        end
    }
}