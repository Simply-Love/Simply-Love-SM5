local player = ...
local pn = ToEnumShortString(player)
local p = PlayerNumber:Reverse()[player]

local height = 64
local width = IsUsingWideScreen() and 286 or 276

-- Max height at 280 BPM 16ths. Anything faster will just scale the graph. 
local maxNps = 280/60 * 4

local af = Def.ActorFrame{
    InitCommand=function(self)
        self:visible( GAMESTATE:IsHumanPlayer(player) )
        self:xy(_screen.cx-182, _screen.cy+23)

        if player == PLAYER_2 then
            self:addy(height+24)
        end

        if IsUsingWideScreen() then
            self:addx(-5)
        end
    end,
    PlayerJoinedMessageCommand=function(self, params)
		if params.Player == player then
            self:visible(true)
        end
	end,
	PlayerUnjoinedMessageCommand=function(self, params)
		if params.Player == player then
            self:visible(false)
        end
	end,

    CurrentSongChangedMessageCommand=function(self) self:queuecommand("UpdateGraph") end,
    CurrentCourseChangedMessageCommand=function(self) self:queuecommand("UpdateGraph") end,
	CurrentStepsP1ChangedMessageCommand=function(self) self:queuecommand("UpdateGraph") end,
	CurrentStepsP2ChangedMessageCommand=function(self) self:queuecommand("UpdateGraph") end,

    UpdateGraphCommand=function(self)
        if not GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentSong() then
            self:GetChild("Breakdown"):visible(true)
            self:GetChild("Histogram"):visible(true)
            self:GetChild("NPS"):visible(false)
        else
            self:GetChild("Breakdown"):visible(false)
            self:GetChild("Histogram"):visible(false)
            self:GetChild("NPS"):settext("Peak NPS: ")
            self:GetChild("NPS"):visible(false)
        end
    end,
}

-- Background quad for the density graph
af[#af+1] = Def.Quad{
    InitCommand=function(self)
        self:diffuse(color("#1e282f")):zoomto(width, height)
		if ThemePrefs.Get("RainbowMode") then
			self:diffusealpha(0.9)
		end
    end
}

-- The Density Graph itself
af[#af+1] = NPS_Histogram(player, width, height)..{
    Name="Histogram",
    OnCommand=function(self)
        self:addx(-width/2):addy(height/2)
    end,
    PeakNPSUpdatedMessageCommand=function(self)
        -- local peakNps = nil
        -- if player == PLAYER_1 then
        --     peakNps = GAMESTATE:Env()["P1PeakNPS"]
        -- else
        --     peakNps = GAMESTATE:Env()["P2PeakNPS"]
        -- end
        -- if peakNps then
        --     self:zoomy(clamp(peakNps/maxNps, 0, 1))
        -- end
    end
}

-- The Peak NPS text
af[#af+1] = LoadFont("Miso/_miso")..{
    Name="NPS",
    Text="Peak NPS: ",
    InitCommand=function(self)
        self:horizalign(left):zoom(0.8)
        if player == PLAYER_1 then
            self:addx(60):addy(-43)
        else
            self:addx(-136):addy(-43)
        end
    end,
    PeakNPSUpdatedMessageCommand=function(self)
        local peakNps = nil
        if player == PLAYER_1 then
            peakNps = GAMESTATE:Env()["P1PeakNPS"]
        else
            peakNps = GAMESTATE:Env()["P2PeakNPS"]
        end
        if peakNps then
            self:settext(("Peak NPS: %.1f"):format(peakNps))
        end
    end
}

-- Breakdown
af[#af+1] = Def.ActorFrame{
    Name="Breakdown",
    InitCommand=function(self)
        local actor_height = 17
        self:addy(height/2 - actor_height/2)
    end,

    Def.Quad{
        InitCommand=function(self)
            local bg_height = 17
            self:diffuse(color("#000000")):zoomto(width, bg_height):diffusealpha(0.5)
        end
    },
    
    LoadFont("Miso/_miso")..{
        Text="No Streams!",
        InitCommand=function(self)
            local text_height = 17
            local text_zoom = 0.8
            self:maxwidth(width/text_zoom):zoom(text_zoom)
            if player == PLAYER_1 then
                --self:horizalign(left):addx(-width/2)
            else
                --self:horizalign(right):addx(width/2)
            end
        end,
        CurrentSongChangedMessageCommand=function(self)
        end,
        CurrentStepsP1ChangedMessageCommand=function(self)
            self:queuecommand("UpdateBreakdown")
        end,
	    CurrentStepsP2ChangedMessageCommand=function(self)
            self:queuecommand("UpdateBreakdown")
        end,
        UpdateBreakdownCommand=function(self)
        end,
    }
    
    
}

return af