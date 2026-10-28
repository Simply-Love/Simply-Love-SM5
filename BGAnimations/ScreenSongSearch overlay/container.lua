local args = ...
local boxSize = args.boxSize
local headerLabel = args.headerLabel

local headerHeight = 20

return Def.ActorFrame {
    Name = "Container",

    -- Header
    Def.ActorFrame {
        Name = "Header",
        InitCommand = function(self)
            self:horizalign(left)
                :vertalign(top)
                :xy((boxSize.width / 2) - 0.5, (headerHeight + boxSize.border) / 2)
        end,

        -- Outline
        Def.Quad {
            Name = "Outline",
            InitCommand = function(self)
                self:setsize(boxSize.width + boxSize.border, headerHeight + boxSize.border)
            end
        },

        Def.Quad {
            Name = "Background",
            InitCommand = function(self)
                self:diffusecolor(Color.Black)
                    :setsize(boxSize.width - boxSize.border, headerHeight - boxSize.border)
            end
        },

        Def.BitmapText {
            Font = "Common Bold",
            Name = "Text",
            Text = headerLabel,
            InitCommand = function(self)
                self:zoom(0.4)
            end,
            UpdateHeaderCommand = function(self, params)
                self:settext(params.newTitle)
            end
        },
    },

    Def.ActorFrame {
        Name = "Body",
        InitCommand = function(self)
            self:y(headerHeight + boxSize.border)
        end,

        Def.Quad {
            Name = "Background",
            InitCommand = function(self)
                self:diffusecolor(Color.Black)
                    :setsize(boxSize.width, boxSize.height)
                    :horizalign(left)
                    :vertalign(top)
            end
        },

        Def.Quad {
            Name = "Left",
            InitCommand = function(self)
                self:zoomto(boxSize.border, boxSize.height + boxSize.border)
                    :vertalign(top)
                    :y(-boxSize.border / 2)
            end
        },

        Def.Quad {
            Name = "Top",
            InitCommand = function(self)
                self:zoomto(boxSize.width + boxSize.border, boxSize.border)
                    :horizalign(left)
                    :x(-boxSize.border / 2)
            end
        },

        Def.Quad {
            Name = "Right",
            InitCommand = function(self)
                self:zoomto(boxSize.border, boxSize.height + boxSize.border)
                    :vertalign(top)
                    :xy(boxSize.width, -boxSize.border / 2)
            end
        },

        Def.Quad {
            Name = "Bottom",
            InitCommand = function(self)
                self:zoomto(boxSize.width + boxSize.border, boxSize.border)
                    :horizalign(left)
                    :xy(-boxSize.border / 2, boxSize.height)
            end
        }
    }
}
