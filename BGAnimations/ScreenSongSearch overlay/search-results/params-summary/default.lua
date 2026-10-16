local boxSize = {
    border = 1,
    width = 200,
    height = 215,
}

local searchSummarySettings = {
    {
        name = "Title",
        label = ScreenString("Title"),
    },
    {
        name = "Artist",
        label = ScreenString("Artist"),
    },
    {
        name = "BPMRange",
        label = ScreenString("BPMRange"),
        value = function()
            if SL.Global.SongSearchParams.BPMFrom == nil and SL.Global.SongSearchParams.BPMTo == nil then
                return nil
            end

            if SL.Global.SongSearchParams.BPMFrom == SL.Global.SongSearchParams.BPMTo then
                return ("%.0f BPM"):format(SL.Global.SongSearchParams.BPMFrom)
            else
                return ("%.0f - %.0f BPM"):format(SL.Global.SongSearchParams.BPMFrom, SL.Global.SongSearchParams.BPMTo)
            end
        end
    },
    {
        name = "DifficultyRange",
        label = ScreenString("DifficultyRange"),
        value = function()
            if SL.Global.SongSearchParams.MeterFrom == nil and SL.Global.SongSearchParams.MeterTo == nil then
                return nil
            end

            if SL.Global.SongSearchParams.MeterFrom == SL.Global.SongSearchParams.MeterTo then
                return ("%d"):format(SL.Global.SongSearchParams.MeterFrom)
            else
                return ("%d - %d"):format(SL.Global.SongSearchParams.MeterFrom, SL.Global.SongSearchParams.MeterTo)
            end
        end
    },
    {
        name = "ExcludePacks",
        label = ScreenString("ExcludePacks"):gsub("\n", " "),
    },
}

local af = Def.ActorFrame {
    Name = "SearchParamsSummary",
    InitCommand = function(self)
        self:xy(60, ((_screen.h - boxSize.height) / 2) - 32)
    end,

    -- container
    LoadActor('../../container.lua', {
        boxSize = boxSize,
        headerLabel = ScreenString("YourSearch"):upper()
    }),
}

local afSummaryList = Def.ActorFrame {
    Name = "SummaryParamsList",
    InitCommand = function(self)
        self:xy(10, 40)
    end,
}

for i, param in ipairs(searchSummarySettings) do
    afSummaryList[#afSummaryList + 1] = Def.ActorFrame {
        Name = "Summary" .. param.name,
        InitCommand = function(self)
            self:y(40 * (i - 1))
        end,

        -- Label
        Def.BitmapText {
            Font = "Common Normal",
            Name = "Label",
            Text = param.label .. ":",
            InitCommand = function(self)
                self:zoom(0.8)
                    :horizalign(left)
                    :diffusecolor(GetCurrentColor())
            end
        },

        -- Value
        Def.BitmapText {
            Font = "Common Normal",
            Name = "Value",
            InitCommand = function(self)
                self:zoom(0.75)
                    :horizalign(left)
                    :xy(15, 16)
                    :maxwidth(210)
            end,
            DisplaySearchResultsCommand = function(self)
                self:settext(((param.value ~= nil and param.value() or SL.Global.SongSearchParams[param.name])) or "—")
            end,
        },
    }
end

af[#af + 1] = afSummaryList

return af
