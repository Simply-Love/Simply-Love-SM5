-- sick_wheel_mt is a metatable with global scope defined in ./Scripts/Consensual-sick_wheel.lua
local candidatesScroller = setmetatable({}, sick_wheel_mt)
local candidateItemMt = LoadActor("CandidateItemMT.lua")
local inputHandler = function(event)
    SM(event)
    if not (event and event.PlayerNumber and event.button) then
        return false
    end

    -- local overlay = SCREENMAN:GetTopScreen():GetChild("SongSearch")
    
    if event.type ~= "InputEventType_Release" then
		if event.GameButton == "MenuRight" or event.GameButton == "MenuDown" then
            SM("down")
            candidatesScroller:scroll_by_amount(1)
        elseif event.GameButton == "MenuLeft" or event.GameButton == "MenuUp" then
            SM("Up")
            candidatesScroller:scroll_by_amount(-1)
        elseif event.GameButton == "Start" then
            local focus = candidatesScroller:get_actor_item_at_focus_pos()
            SM(TableToString(focus))
        elseif event.GameButton == "Back" or event.GameButton == "Select" then
            -- overlay:queuecommand("DirectInputToEngine")
        end
    end
    return false
end

local paneHeight = 319
local paneWidth = 319
local borderWidth = 2

local textHeight = 15
local numScrollers = 6
local scrollerHeight = (paneHeight - (numScrollers - 1) * borderWidth)/numScrollers
local scrollerWidth = paneWidth/2

local af = Def.ActorFrame {
    Name="SongSearch",
    InitCommand=function(self)
        self:visible(false)
    end,
    DisplaySearchResultsMessageCommand=function(self, params)
        self:visible(true)

        SCREENMAN:GetTopScreen():AddInputCallback(inputHandler)
        for player in ivalues(PlayerNumber) do
            SCREENMAN:set_input_redirected(player, true)
        end
        self:playcommand("AssessCandidates", params)
    end,
    DirectInputToEngineCommand=function(self)
        -- SCREENMAN:GetTopScreen():RemoveInputCallback(inputHandler)
        -- for player in ivalues(PlayerNumber) do
        --     SCREENMAN:set_input_redirected(player, false)
        -- end
        -- self:visible(false)
    end,
    -- slightly darken the entire screen
    Def.Quad {
        InitCommand=function(self)
            self:FullScreen():diffuse(Color.Black):diffusealpha(0.8)
        end
    },
    
    Def.ActorFrame {
        Name="Overlay",
        InitCommand=function(self)
            self:xy(_screen.cx, _screen.cy + 40)
        end,

        AssessCandidatesCommand=function(self, params)
            self:GetChild("SearchText"):playcommand("UpdateText", params)
            self:GetChild("NumResults"):playcommand("UpdateText", params)
            table.insert(params.candidates, "Exit")
            candidatesScroller.disable_wrapping = true
            candidatesScroller.focus_pos = 1
            candidatesScroller:set_info_set(params.candidates, 0)
        end,

        -- White border
        Def.Quad {
            InitCommand=function(self)
                self:diffuse(Color.White)
                self:zoomto(paneWidth + borderWidth, paneHeight + borderWidth)
            end,
        },

        -- Main black body
        Def.Quad {
            InitCommand=function(self)
                self:diffuse(Color.Black)
                self:zoomto(paneWidth, paneHeight)
            end,
        },

        Def.Quad {
            InitCommand=function(self)
                self:diffuse(color("0.2,0.2,0.2"))
                self:zoomto(borderWidth, paneHeight - 10)
            end,
        },

        LoadFont("Common Normal").. {
            Text="Search Results For:",
            InitCommand=function(self)
                self:diffuse(Color.White)
                self:y(-paneHeight/2 - textHeight * 5)
            end,
        },

        LoadFont("Common Normal").. {
            Name="SearchText",
            InitCommand=function(self)
                self:diffuse(Color.White)
                self:y(-paneHeight/2 - textHeight * 3)
            end,
            UpdateTextCommand=function(self, params)
                self:settext("\""..params.searchText.."\"")
                self:AddAttribute(1, {Length=#self:GetText()-2; Diffuse=Color.Green})
            end,
        },

        LoadFont("Common Normal").. {
            Name="NumResults",
            InitCommand=function(self)
                self:diffuse(Color.White)
                self:maxwidth(paneWidth/2)
                self:y(-paneHeight/2 - textHeight)
            end,
            UpdateTextCommand=function(self, params)
                self:settext(#params.candidates.." Results Found")
            end
        },

        candidatesScroller:create_actors("Candidates", 10, candidateItemMt, -paneWidth/4, -paneHeight/2 - textHeight/2)
    }

}

return af