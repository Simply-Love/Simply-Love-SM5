local data = {
  ["Footspeed Empire"] = {
    ["Dice"] = {
      shown = false,
      time = 15,
    },
    ["Fof"] = {
      shown = false,
      time = 15,
    },
    ["Memepeace"] = {
      shown = false,
      time = 15,
    },
    ["Revitalization"] = {
      shown = false,
      time = 15,
    },
    ["Training"] = {
      shown = false,
      time = 12,
    },
  },
  ["Stamina Nation"] = {
    ["Aid"] = {
      shown = false,
      time = 13,
    },
    ["City"] = {
      shown = false,
      time = 16,
    },
    ["Insufferable"] = {
      shown = false,
      time = 18,
    },
    ["Streamscourge"] = {
      shown = false,
      time = 17,
    },
    ["Suitable"] = {
      shown = false,
      time = 8,
    },
  },
  ["Democratic People's Republic of Timing"] = {
    ["Capital"] = {
      shown = false,
      time = 16,
    },
    ["Coin"] = {
      shown = false,
      time = 11,
    },
    ["Numbers"] = {
      shown = false,
      time = 11,
    },
    ["Runt"] = {
      shown = false,
      time = 15,
    },
    ["Threats"] = {
      shown = false,
      time = 12,
    },
  },
  ["Unaffiliated"] = {
    ["Allegiance"] = {
      shown = false,
      time = 7,
    },
    ["Before"] = {
      shown = false,
      time = 16,
    },
    ["Begone"] = {
      shown = false,
      time = 12,
    },
    ["Heyman"] = {
      shown = false,
      time = 7,
    },
    ["Neutral"] = {
      shown = false,
      time = 13,
    },
  }
}

local path = THEME:GetCurrentThemeDirectory() .. "Other/srpg7.json"
if FILEMAN:DoesFileExist(path) then
  local f = RageFileUtil:CreateRageFile()
  if f:Open(path, 1) then
    local str = f:Read()
    -- (ITGmania File IO) - Zankoku
    data = json.decode(str)

    for faction, t in pairs(data) do
      for video, attr in pairs(t) do
        if attr.shown then
          data[faction][video].shown = true
        end
      end
    end
  end
  f:destroy()
end

local factionName = SL.SRPG7.GetFactionName(SL.Global.ActiveColorIndex)

-- Select a random cutscene that hasn't previously been shown.
local cutscenes = {}
for cutscene, attr in pairs(data[factionName]) do
  if not attr.shown then
    cutscenes[#cutscenes + 1] = { cutscene, attr }
  end
end

-- If cutscenes is empty, just random from all cutscenes in the faction.
if #cutscenes == 0 then
  for cutscene, attr in pairs(data[factionName]) do
    cutscenes[#cutscenes + 1] = { cutscene, attr }
  end
end

local cutscene = nil
if #cutscenes == 1 then
  cutscene = cutscenes[1]
else
  cutscene = cutscenes[math.random(1, #cutscenes)]
end
data[factionName][cutscene[1]].shown = true

local InputHandler = function(event)
	if not event.PlayerNumber or not event.button then return false end
	if event.type == "InputEventType_FirstPress" then
		if event.GameButton == "Start" then
			SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
		end
	end
end

local af = Def.ActorFrame{
  OnCommand=function(self)
    SCREENMAN:GetTopScreen():AddInputCallback(InputHandler)
  end,
  Def.Quad{
    InitCommand=function(self)
      self:FullScreen():diffuse(0,0,0,1)
    end,
  },
  Def.Sprite{
    Name="Video",
    Texture=THEME:GetPathG("","_VisualStyles/SRPG7/Cutscenes/"..factionName.."/"..cutscene[1]..".mp4"),
    InitCommand=function(self)
      local aspectRatio = 16 / 9
      -- Letterbox
      self:zoomto(_screen.w, _screen.w / aspectRatio):Center()
      self:loop(false)
    end,
  },
  Def.Sound{
    Name="Audio",
    File=THEME:GetPathG("","_VisualStyles/SRPG7/Cutscenes/"..factionName.."/"..cutscene[1]..".ogg"),
    OnCommand=function(self)
      self:play()
      self:sleep(cutscene[2].time):queuecommand("Transition")
    end,
    TransitionCommand=function(self)
      self:stop()
      SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
    end,
    OffCommand=function(self)
      self:stop()
    end,
  },
  LoadFont("Common Normal")..{
    Text=THEME:GetString("ScreenEvaluation", "PressStartToContinue"),
    InitCommand=function(self)
      self:xy(_screen.cx, 50):diffusealpha(0)
    end,
    OnCommand=function(self)
      self:linear(1):diffusealpha(0.5)
      self:sleep(cutscene[2].time-3):linear(1):diffusealpha(0)
    end,
  },
  OffCommand=function(self)
    local f = RageFileUtil.CreateRageFile()
    if f:Open(path, 2) then
      -- (ITGmania File IO) - Zankoku
      f:Write(json.encode(data))
    end
    f:destroy()
  end,
}
return af