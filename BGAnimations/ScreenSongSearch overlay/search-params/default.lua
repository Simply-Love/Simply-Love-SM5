local utils = LoadActor('utils.lua')

-- input management
local inputBlocked = false
local isInputBlocked = function() return inputBlocked end

-- selection
local paramSelected = 1
local getParamSelected = function() return paramSelected end
local setParamSelected = function(index) paramSelected = index end

-- settings
local searchParamsSettings = {
    {
        name = "Title",
        label = ScreenString("Title"),
        type = "input-text",
        helper = ScreenString("TitleHelper")
    },
    {
        name = "Artist",
        label = ScreenString("Artist"),
        type = "input-text",
    },
    {
        name = "BPMFrom",
        label = ScreenString("BPMRange"),
        type = "input-text",
        size = { width = 100 },
        onlyNumbers = true,
        questionReplacement = ScreenString("BPMFrom"),
        helper = ScreenString("BPMRangeHelper")
    },
    {
        name = "BPMTo",
        label = ScreenString("to"),
        type = "input-text",
        size = { width = 100 },
        position = { x = 260, y = 100 },
        labelDistance = 35,
        onlyNumbers = true,
        questionReplacement = ScreenString("BPMTo")
    },
    {
        name = "MeterFrom",
        label = ScreenString("DifficultyRange"),
        type = "input-text",
        size = { width = 100 },
        position = { y = 150 },
        onlyNumbers = true,
        questionReplacement = ScreenString("MeterFrom"),
        helper = ScreenString("DifficultyRangeHelper")
    },
    {
        name = "MeterTo",
        label = ScreenString("to"),
        type = "input-text",
        size = { width = 100 },
        position = { x = 260, y = 150 },
        labelDistance = 35,
        onlyNumbers = true,
        questionReplacement = ScreenString("MeterTo")
    },
    {
        name = "ExcludePacks",
        label = ScreenString("ExcludePacks"),
        type = "input-text",
        position = { y = 200 },
        helper = ScreenString("ExcludePacksHelper")
    },

    -- buttons
    {
        name = "ResetButton",
        label = THEME:GetString("OptionNames", "Reset"),
        type = "button",
        position = { x = 230, y = 250 },
        onStart = function()
            SL.Global.SongSearchParams = {}
            SCREENMAN:GetTopScreen():queuecommand("Reset")
        end
    },
    {
        name = "SearchButton",
        label = THEME:GetString("OptionNames", "Search"),
        type = "button",
        position = { x = 160, y = 305 },
        onStart = function()
            -- empty params
            if next(SL.Global.SongSearchParams) == nil then return end

            utils.normalizeSearchParams()
            local songsResults = utils.searchSongs()

            SCREENMAN:GetTopScreen()
                :playcommand("DisplaySearchResults", songsResults)
        end
    },
    {
        name = "ExitButton",
        label = THEME:GetString("OptionNames", "Exit"),
        type = "button",
        position = { x = 300, y = 305 },
        onStart = function()
            SCREENMAN:GetTopScreen()
                :StartTransitioningScreen("SM_GoToPrevScreen")
        end
    },
}

local containerBoxSize = {
    border = 1,
    width = 500,
    height = 360,
}

local af = Def.ActorFrame {
    Name = "SearchParamsModal",

    InitCommand = function(self)
        self:xy((_screen.w - containerBoxSize.width) / 2, ((_screen.h - containerBoxSize.height) / 2) - 32)
    end,

    LoadActor('../container.lua', {
        boxSize = containerBoxSize,
        headerLabel = ScreenString("SearchParamsTitle"):upper()
    }),

    OnCommand = function(self)
        local inputHandler = LoadActor('input.lua', {
            isInputBlocked = isInputBlocked,
            getParamSelected = getParamSelected,
            setParamSelected = setParamSelected,
            numParams = #searchParamsSettings,
            searchFieldFrame = self
        })

        SCREENMAN:GetTopScreen():AddInputCallback(inputHandler)
    end,

    DisplaySearchResultsCommand = function(self)
        inputBlocked = true
        self:diffusealpha(0)
    end
}

local paramsAf = Def.ActorFrame {
    Name = "SearchParamsList",
    InitCommand = function(self)
        self:vertalign(top)
            :horizalign(left)
            :xy(15, 50)
    end
}

for i, elem in ipairs(searchParamsSettings) do
    local field = Def.ActorFrame {
        Name = elem.name .. "Param",
        InitCommand = function(self)
            local xPos = (not elem.position or not elem.position.x)
                and 0
                or elem.position.x
            local yPos = (not elem.position or not elem.position.y)
                and (50 * (i - 1))
                or elem.position.y

            self:xy(xPos, yPos)
        end,
        OnCommand = function(self)
            self:queuecommand("SelectElement")
        end,
        SelectElementCommand = function(self)
            if paramSelected == i then
                self:queuecommand("HighlightElement")
            else
                self:queuecommand("RemoveHighlightElement")
            end
        end,
        StartElementActionCommand = function(self)
            if paramSelected == i then
                self:queuecommand("ElementAction")
            end
        end
    }

    if elem.type == "input-text" then
        -- Field
        field[#field + 1] = LoadActor("components/text-param.lua", {
            name = elem.name,
            label = elem.label or elem.name,
            size = elem.size,
            labelDistance = elem.labelDistance,
            helper = elem.helper,
            onlyNumbers = elem.onlyNumbers,
            onEndInput = elem.onEndInput or function(answer)
                SL.Global.SongSearchParams[elem.name] = (answer ~= "" and answer or nil)
            end,
            initialValue = elem.initialValue or SL.Global.SongSearchParams[elem.name],
            questionReplacement = elem.questionReplacement
        })
    elseif elem.type == "button" then
        field[#field + 1] = LoadActor("components/button.lua", {
            name = elem.name,
            label = elem.label or elem.name,
            size = elem.size,
            onStart = elem.onStart,
        })
    end

    paramsAf[#paramsAf + 1] = field
end

af[#af + 1] = paramsAf

return af
