local defaultSize = { width = 320, height = 25, outline = 1 }

local args = ... or {}
local name = args.name or ""
local label = args.label or ""
local size = {
    width = (not args.size or not args.size.width) and defaultSize.width or args.size.width,
    height = (not args.size or not args.size.height) and defaultSize.height or args.size.height,
    outline = (not args.size or not args.size.outline) and defaultSize.outline or args.size.outline
}
local labelDistance = args.labelDistance or 140
local helper = args.helper or ""
local onlyNumbers = args.onlyNumbers
local onEndInput = args.onEndInput
local currentText = args.initialValue or ""
local questionReplacement = args.questionReplacement

local hightlightColor = GetCurrentColor()

-- labels
local insertSearchValueQuestion = ScreenString(onlyNumbers and "InsertSearchNumberQuestion" or "InsertSearchTextQuestion")
    :format(questionReplacement or label)

return Def.ActorFrame {
    Name = "TextField" .. name,

    -- Label
    Def.BitmapText {
        Font = "Common Normal",
        Name = "Label",
        Text = label,
        InitCommand = function(self)
            self:zoom(1)
                :horizalign(left)
        end,
        HighlightElementCommand = function(self)
            self:diffusecolor(hightlightColor)
        end,
        RemoveHighlightElementCommand = function(self)
            self:diffusecolor(Color.White)
        end
    },

    Def.ActorFrame {
        Name = "Field",
        InitCommand = function(self)
            self:x(labelDistance)
        end,

        Def.Quad {
            Name = "Outline",
            InitCommand = function(self)
                self:setsize(size.width, size.height)
                    :horizalign(left)
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
                    :horizalign(left)
                    :x(size.outline)
            end
        },

        -- text
        Def.BitmapText {
            Font = "Common Normal",
            Name = "Text",
            Text = currentText,
            InitCommand = function(self)
                self:zoom(1)

                if onlyNumbers then
                    self:x(50)
                else
                    self:horizalign(left)
                        :x(5)
                end
            end,
            HighlightElementCommand = function(self)
                self:diffusecolor(hightlightColor)
            end,
            RemoveHighlightElementCommand = function(self)
                self:diffusecolor(Color.White)
            end,
            UpdateTextCommand = function(self)
                self:settext(currentText)
            end,
            ResetCommand = function(self)
                currentText = ""
                self:settext("")
            end
        },
    },

    -- helper
    Def.BitmapText {
        Font = "Common Normal",
        Name = "Helper",
        Text = helper,
        InitCommand = function(self)
            self:zoom(0.55)
                :horizalign(left)
                :xy(labelDistance, 20)
        end,
        HighlightElementCommand = function(self)
            self:diffusecolor(hightlightColor)
        end,
        RemoveHighlightElementCommand = function(self)
            self:diffusecolor(Color.White)
        end
    },

    ElementActionCommand = function(self)
        -- open screen
        local textEntrySettings = {
            Question = insertSearchValueQuestion,
            InitialAnswer = currentText,
            MaxInputLength = 100,
            ValidateAppend = function(answer, append)
                if onlyNumbers and type(tonumber(append)) ~= "number" then
                    return false
                end

                return true
            end,
            OnOK = function(answer)
                currentText = answer
                self:queuecommand("UpdateText")
                onEndInput(answer)
            end

        }

        SCREENMAN:AddNewScreenToTop("ScreenTextEntry")
        SCREENMAN:GetTopScreen():Load(textEntrySettings)
    end,
}
