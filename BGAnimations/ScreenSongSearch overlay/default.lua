return Def.ActorFrame {
    -- Fullscreen Black Background
    Def.Quad {
        InitCommand = function(self)
            self:FullScreen()
                :diffuse(0, 0, 0, 0.9)
        end
    },

    -- Search Params Modal
    LoadActor('search-params/default.lua'),

    -- Results
    LoadActor('search-results/default.lua'),

    OnCommand = function()
        SCREENMAN:GetTopScreen()
            :AddInputCallback(LoadActor('input.lua'))
    end
}
