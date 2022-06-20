--Code based on Simply Fantasy by Poog which is based off Digital Dance by Aoreo

--if not ThemePrefs.Get("ShowCD") then return end

local t = Def.ActorFrame{}

if not GAMESTATE:IsCourseMode() then
    t[#t+1] = Def.ActorFrame {
        OnCommand= function(self)
            self:draworder(101)
            :x(_screen.cx)
            :y(SCREEN_CENTER_Y-150)
            :playcommand("SetCD")
        end,
        OffCommand= function(self)
            self:bouncebegin(0.15)
        end,
        CurrentSongChangedMessageCommand=function(self) self:playcommand("SetCD") end,
        SwitchFocusToGroupsMessageCommand=function(self) self:GetChild("CdTitle"):visible(false) end,
        SetCDCommand=function(self)
			SongOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong()
            local cdtitle = self:GetChild("CdTitle")
            if SongOrCourse and SongOrCourse:HasCDTitle() then
                cdtitle:visible(true)
                cdtitle:Load( GAMESTATE:GetCurrentSong():GetCDTitlePath() )
                local dim1, dim2=math.max(cdtitle:GetWidth(), cdtitle:GetHeight()), math.min(cdtitle:GetWidth(), cdtitle:GetHeight())
                local ratio=math.max(dim1/dim2, 2.5)
            
                local toScale = cdtitle:GetWidth() > cdtitle:GetHeight() and cdtitle:GetWidth() or cdtitle:GetHeight()
                self:zoom(22/toScale * ratio)
                self:finishtweening():addrotationy(0):linear(.5):addrotationy(360):bounce()
			else
				cdtitle:visible(false)
			end
        end,
        Def.Sprite{
			Name="CdTitle",
		},
    }
end

return t