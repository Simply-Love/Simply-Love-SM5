local defaultSize = { width = 100, height = 25, outline = 1 }

local args = ... or {}
local name = args.name or ""
local label = args.label or ""
local size = {
    width = (not args.size or not args.size.width) and defaultSize.width or args.size.width,
    height = (not args.size or not args.size.height) and defaultSize.height or args.size.height,
    outline = (not args.size or not args.size.outline) and defaultSize.outline or args.size.outline
}
local onStart = args.onStart

local hightlightColor = GetCurrentColor()

return Def.ActorFrame {
    name = "Button" .. name,

    Def.Quad {
        Name = "Outline",
        InitCommand = function(self)
            self:setsize(size.width, size.height)
        end,
        HighlightElementCommand = function(self)
            self:diffusecolor(hightlightColor)
        end,
        RemoveHighlightElementCommand = function(self)
            self:diffusecolor(Color.White)
        end
    },

    Def.Quad {
        Name = "Background",
        InitCommand = function(self)
            self:setsize(size.width - (size.outline * 2), size.height - (size.outline * 2))
                :diffuse(Color.Black)
        end
    },

    Def.BitmapText {
        Font = "Common Normal",
        Name = "Label",
        Text = label,
        InitCommand = function(self)
            self:zoom(1)
        end,
        HighlightElementCommand = function(self)
            self:diffusecolor(hightlightColor)
        end,
        RemoveHighlightElementCommand = function(self)
            self:diffusecolor(Color.White)
        end
    },

    ElementActionCommand = function(self)
        onStart(self)
    end,
}
