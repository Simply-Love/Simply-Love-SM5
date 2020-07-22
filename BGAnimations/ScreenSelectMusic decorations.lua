local t = LoadFallbackB();

if not GAMESTATE:IsCourseMode() then
    local function CDTitleUpdate(self)
        local song = GAMESTATE:GetCurrentSong();
        local cdtitle = self:GetChild("CDTitle");
        local height = cdtitle:GetHeight();
        if song then
            if song:HasCDTitle() then
                cdtitle:visible(true);
                cdtitle:Load(song:GetCDTitlePath());
            else
                cdtitle:visible(false);
            end;
        else
            cdtitle:visible(false);
        end;

        local dim1, dim2=math.max(cdtitle:GetWidth(), cdtitle:GetHeight()), math.min(cdtitle:GetWidth(), cdtitle:GetHeight())
        local ratio=math.max(dim1/dim2, 2)

        local toScale = cdtitle:GetWidth() > cdtitle:GetHeight() and cdtitle:GetWidth() or cdtitle:GetHeight()
        self:zoom(22/toScale * ratio)
    end;
    t[#t+1] = Def.ActorFrame {
        OnCommand=cmd(draworder,101;x,IsUsingWideScreen() and SCREEN_CENTER_X+100 or 260;y,SCREEN_CENTER_Y-92;zoom,1;diffusealpha,1;SetUpdateFunction,CDTitleUpdate);
        OffCommand=cmd(bouncebegin,0.15;zoomx,0;zoomy,0);
        Def.Sprite {
            Name="CDTitle";
            OnCommand=function(self) self:draworder(101) end,
            BackCullCommand=cmd(diffuse,color("0.5,0.5,0.5,1"));
        };    
    };
end

return t