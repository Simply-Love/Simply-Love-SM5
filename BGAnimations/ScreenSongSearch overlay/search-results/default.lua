return Def.ActorFrame {
    Name = "SearchResultsModal",

    InitCommand = function(self)
        self:diffusealpha(0)
    end,

    LoadActor('params-summary/default.lua'),

    LoadActor('results-list/default.lua'),

    DisplaySearchResultsCommand = function(self)
        self:diffusealpha(1)
    end,

}
