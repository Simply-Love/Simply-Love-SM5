local player = ...

if SL.Global.GameMode == "Casual" then return end

local optionslist = GetPlayerOptionsString(player)

local af = Def.ActorFrame{
  InitCommand = function(self)
    self:diffusealpha(1):xy(GetNotefieldX(player), SCREEN_HEIGHT/4*1.3)
  end,
  OnCommand=function(self)
    self:sleep(5):decelerate(0.5):diffusealpha(0)
  end,
  PlayerOptionsChangedMessageCommand=function(self, params)
    if params.Player ~= player then return false end
    self:stoptweening():playcommand("Init"):queuecommand("On")
  end,
}

af[#af+1] = LoadFont("Common Normal")..{
  Text=optionslist,
  InitCommand=function(self)
    self:y(15)
    self:zoom(0.8)
    self:wrapwidthpixels(125)
    self:shadowcolor(Color.Black)
    self:shadowlength(1)
  end,
  PlayerOptionsChangedMessageCommand=function(self, params)
    if params.Player ~= player then return false end
    optionslist = GetPlayerOptionsString(player, "ModsLevel_Song")
    self:settext(optionslist)
  end
}

return af