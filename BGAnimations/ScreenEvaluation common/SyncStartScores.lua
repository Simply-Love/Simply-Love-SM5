-- only run in modified stepmania build 
if not SYNCMAN or not SYNCMAN:IsEnabled() then
  return Def.Actor{}
end

local MAX_PLAYER_COUNT = 6
local ROWS = 3
local COLS = 2
local CELL_WIDTH = 110
local CELL_HEIGHT = 20
local COL_DISTANCE = 140

local Y_POS = 112
local INIT_X = _screen.cx - (CELL_WIDTH + COL_DISTANCE) / 2
local INIT_Y = Y_POS - (CELL_HEIGHT * (ROWS - 1)) / 2

local BACKGROUND_MARGIN = 10

local playerNameTexts = {}
local scoreTexts = {}

local t = Def.ActorFrame{
  InitCommand=function(self)
    self:queuecommand("UpdateScores")
  end,

  SyncStartPlayerScoresChangedMessageCommand=function(self)
    self:queuecommand("UpdateScores")
  end,

  UpdateScoresCommand=function(self)
    local scores = SYNCMAN:GetLatestPlayerScores()

    for i = 1, MAX_PLAYER_COUNT do
      if i <= #scores then
        local score = scores[i]
        local color = score.failed and color("1,0.3,0.3,0.8") or Color.White
        playerNameTexts[i]:settext(score.playerName):diffuse(color)
        scoreTexts[i]:settext(score.score):diffuse(color)
      else
        playerNameTexts[i]:settext("")
        scoreTexts[i]:settext("")
      end 
    end
  end
}

t[#t+1] = Def.Quad{
  InitCommand=function(self)
    self:xy(_screen.cx, Y_POS)
    self:zoom(0.7)
    self:setsize(418 - BACKGROUND_MARGIN, 164 - BACKGROUND_MARGIN)
    self:diffuse(0, 0, 0, 0.80)
  end
}

t[#t+1] = Def.Quad{
  InitCommand=function(self)
    self:xy(_screen.cx, Y_POS)
    self:zoom(0.7)
    self:setsize(2, 164 - (BACKGROUND_MARGIN * 4))
    self:diffuse(255, 255, 255, 0.5)
  end
}

for i = 1, MAX_PLAYER_COUNT do
  local col = math.floor((i - 1) / ROWS)
  local row = (i - 1) % ROWS

  t[#t+1] = Def.BitmapText{
    Font="Miso/_miso light",
    Text="",
    InitCommand=function(self)
      playerNameTexts[i] = self
      self:x(INIT_X + (col * COL_DISTANCE))
      self:y(INIT_Y + row * CELL_HEIGHT)
      self:align(0, 0.5)
      self:zoom(0.75)
    end
  }

  t[#t+1] = Def.BitmapText{
    Font="Miso/_miso light",
    Text="",
    InitCommand=function(self)
      scoreTexts[i] = self
      self:x(INIT_X + (col * COL_DISTANCE) + CELL_WIDTH)
      self:y(INIT_Y + row * CELL_HEIGHT)
      self:align(1, 0.5)
      self:zoom(0.75)
    end
  }
end

return t
