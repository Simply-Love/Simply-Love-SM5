local args = ...
local boxSize = args.boxSize

local rowHeight = 60
local exitColors = { focus = color("#c80000"), noFocus = color("#780000") }

-- the metatable for an item.
return {
    __index = {
        create_actors = function(self, name)
            self.name = name

            local af = Def.ActorFrame {
                Name = name,

                InitCommand = function(subself)
                    self.container = subself
                    subself:MaskDest()
                        :diffusealpha(0)
                end,

                -- Background
                Def.Quad {
                    Name = "RowBackground",
                    InitCommand = function(subself)
                        self.row_background = subself

                        subself:setsize(boxSize.width - (boxSize.border * 2), rowHeight)
                            :diffusecolor(Color.White)
                            :diffusealpha(0)
                    end,
                    HasFocusCommand = function(subself)
                        subself:diffusecolor(Color.White)
                            :diffusealpha(0.25)
                    end,
                    LoseFocusCommand = function(subself)
                        subself:diffusecolor(Color.White)
                            :diffusealpha((self.isSong or self.isExit) and 0.08 or 0)
                    end,
                    ResetCommand = function(subself)
                        subself:diffusealpha(0)
                    end
                },

                -- Banner
                Def.Banner {
                    Name = "Banner",
                    InitCommand = function(subself)
                        self.song_banner = subself

                        subself:horizalign(left)
                            :x(-240)
                            :diffusealpha(0)
                    end,
                    FillRowDataCommand = function(subself, info)
                        if info.isExit then
                            subself:diffusealpha(0)
                            return
                        end

                        if info.song:HasBanner() then
                            subself:LoadFromSong(info.song)
                        else
                            subself:Load(GetFallbackBanner())
                        end

                        subself:setsize(418, 164)
                            :zoom(0.25)
                            :diffusealpha(1)
                    end
                },

                -- Song Name
                Def.BitmapText {
                    Font = "Common Normal",
                    Name = "TitleSubtitle",
                    InitCommand = function(subself)
                        subself:zoom(1)
                            :horizalign(left)
                            :xy(-130, -18)
                            :maxwidth(372)
                            :diffusealpha(0)
                    end,
                    ResetCommand = function(subself)
                        subself:settext(""):diffusealpha(0)
                    end,
                    FillRowDataCommand = function(subself, info)
                        subself:settext(not info.isExit and info.fulltitle or "")
                            :diffusecolor(Color.White)
                            :diffusealpha(not info.isExit and 1 or 0)

                        if (not info.isExit) and SL.Global.SongSearchParams.Title then
                            local searchTextStart = string.find(info.fulltitle:lower(),
                                SL.Global.SongSearchParams.Title:lower())
                            local searchTextLength = #SL.Global.SongSearchParams.Title

                            if searchTextStart ~= nil then
                                subself:AddAttribute(searchTextStart - 1, {
                                    Length = searchTextLength,
                                    Diffuse = GetCurrentColor()
                                })
                            end
                        end
                    end
                },

                -- Artist
                Def.BitmapText {
                    Font = "Common Normal",
                    Name = "Artist",
                    InitCommand = function(subself)
                        subself:zoom(0.75)
                            :horizalign(left)
                            :xy(-130, -2)
                            :maxwidth(355)
                            :diffusealpha(0)
                    end,
                    ResetCommand = function(subself)
                        subself:settext(""):diffusealpha(0)
                    end,
                    FillRowDataCommand = function(subself, info)
                        subself:settext(not info.isExit and info.artist or "")
                            :diffusecolor(color("#B2B2B2"))
                            :diffusealpha(not info.isExit and 1 or 0)

                        if (not info.isExit) and SL.Global.SongSearchParams.Artist then
                            local searchTextStart = string.find(info.artist:lower(),
                                SL.Global.SongSearchParams.Artist:lower())
                            local searchTextLength = #SL.Global.SongSearchParams.Artist

                            if searchTextStart ~= nil then
                                subself:AddAttribute(searchTextStart - 1, {
                                    Length = searchTextLength,
                                    Diffuse = GetCurrentColor()
                                })
                            end
                        end
                    end
                },

                -- Pack Icon and Name
                Def.ActorFrame {
                    Name = "Pack",
                    InitCommand = function(subself)
                        subself:horizalign(left)
                            :vertalign(bottom)
                            :xy(-130, 18)
                            :diffusealpha(0)
                    end,

                    FillRowDataCommand = function(subself, info)
                        subself:diffusealpha(not info.isExit and 1 or 0)
                    end,

                    -- Folder image
                    Def.Sprite {
                        Name = "FolderMid",
                        Texture = THEME:GetPathG("", "folder-solid.png"),
                        InitCommand = function(subself)
                            subself:horizalign(left)
                                :zoom(0.15)
                        end,
                        FillRowDataCommand = function(subself, info)
                            subself:diffusecolor(not info.isExit and info.packColor() or Color.White)
                        end
                    },

                    Def.BitmapText {
                        Font = "Common Normal",
                        Name = "PackName",
                        InitCommand = function(self)
                            self:zoom(0.7)
                                :horizalign(left)
                                :x(25)
                                :maxwidth(250)
                        end,
                        FillRowDataCommand = function(subself, info)
                            subself:settext(not info.isExit and info.packName() or "")
                                :diffusecolor(not info.isExit and info.packColor() or Color.White)
                        end
                    },
                },

                -- BPM/Length
                Def.BitmapText {
                    Font = "Common Normal",
                    Name = "BPM-Length",
                    InitCommand = function(subself)
                        subself:zoom(0.7)
                            :horizalign(right)
                            :xy((boxSize.width / 2) - 8, -2)
                            :diffusealpha(0)
                    end,
                    ResetCommand = function(subself)
                        subself:settext(""):diffusealpha(0)
                    end,
                    FillRowDataCommand = function(subself, info)
                        subself:settext(not info.isExit and (("%s • %s"):format(info.bpms(), info.length)) or "")
                            :diffusealpha(not info.isExit and 1 or 0)
                    end
                },

                -- Difficulties
                Def.BitmapText {
                    Font = "Common Normal",
                    Name = "Difficulties",
                    InitCommand = function(subself)
                        subself:zoom(0.75)
                            :horizalign(right)
                            :vertalign(bottom)
                            :xy((boxSize.width / 2) - 8, 24)
                            :diffusealpha(0)
                    end,
                    ResetCommand = function(subself)
                        subself:settext(""):diffusealpha(0)
                    end,
                    FillRowDataCommand = function(subself, info)
                        subself:settext(not info.isExit and info.difficulties() or "")
                            :diffusealpha(not info.isExit and 1 or 0)
                    end
                },

                -- Exit
                Def.BitmapText {
                    Font = "Common Normal",
                    Name = "Exit",
                    InitCommand = function(subself)
                        subself:zoom(1.1)
                            :diffusealpha(0)
                    end,
                    HasFocusCommand = function(subself)
                        subself:diffusecolor(exitColors.focus)
                    end,
                    LoseFocusCommand = function(subself)
                        subself:diffusecolor(exitColors.noFocus)
                    end,
                    ResetCommand = function(subself)
                        subself:settext(""):diffusealpha(0)
                    end,
                    FillRowDataCommand = function(subself, info)
                        subself:settext(info.isExit and info.label or "")
                            :diffusealpha(info.isExit and 1 or 0)
                    end
                },
            }

            return af
        end,
        transform = function(self, item_index, num_items, has_focus)
            self.container:finishtweening()

            if has_focus then
                self.container:queuecommand("HasFocus")
            else
                self.container:queuecommand("LoseFocus")
            end

            self.container:y((rowHeight + 2) * item_index)
            self.container:diffusealpha(1)
        end,
        set = function(self, info)
            if info == nil then
                self.container:playcommand("Reset")
                return
            end

            self.container:playcommand("FillRowData", info)

            -- save for details
            self.isSong = info.song ~= nil
            self.isExit = info.isExit
        end
    }
}
