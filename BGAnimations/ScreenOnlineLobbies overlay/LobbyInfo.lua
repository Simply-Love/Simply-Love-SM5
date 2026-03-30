local focus_pos = 1
local offset = 0
local num_rows = 5
local data = {}

local t = Def.ActorFrame{
  InitCommand=function(self)
    self:y(-180)
  end,
  UpdateDataCommand=function(self, params)
    data = params.data
    focus_pos = 1
    offset = 0
    if self:GetParent() then
      self:GetParent():playcommand("UpdateIndex", {idx=(#data > 0 and 1 or 0), total=#data})
    end
    self:queuecommand("UpdateSelf")
  end,
  NextLobbyCommand=function(self)
    if focus_pos < num_rows and focus_pos < #data then
      focus_pos = focus_pos + 1
      self:queuecommand("UpdateSelf")
      SOUND:PlayOnce(THEME:GetPathS("ScreenSelectMaster", "change"))
      self:GetParent():playcommand("UpdateIndex", {idx=focus_pos+offset, total=#data})
    elseif focus_pos == num_rows and focus_pos + offset < #data then
      offset = offset + 1
      self:queuecommand("UpdateSelf")
      SOUND:PlayOnce(THEME:GetPathS("ScreenSelectMaster", "change"))
      self:GetParent():playcommand("UpdateIndex", {idx=focus_pos+offset, total=#data})
    end
  end,
  PrevLobbyCommand=function(self)
    if focus_pos > 1 then
      focus_pos = focus_pos - 1
      self:queuecommand("UpdateSelf")
      SOUND:PlayOnce(THEME:GetPathS("ScreenSelectMaster", "change"))
      self:GetParent():playcommand("UpdateIndex", {idx=focus_pos+offset, total=#data})
    elseif focus_pos == 1 and focus_pos + offset > 1 then
      offset = offset - 1
      self:queuecommand("UpdateSelf")
      SOUND:PlayOnce(THEME:GetPathS("ScreenSelectMaster", "change"))
      self:GetParent():playcommand("UpdateIndex", {idx=focus_pos+offset, total=#data})
    end
  end,
  SelectLobbyCommand=function(self, params)
    local selected = data[focus_pos + offset]
    if not selected then
      SOUND:PlayOnce(THEME:GetPathS("Common", "Cancel"))
      return
    end

    MESSAGEMAN:Broadcast("OnlineLobbyJoinSelected", {
      code = selected.code,
      isPasswordProtected = selected.isPasswordProtected,
      password = (params and params.password) or ""
    })
  end
}

-- +2 because we want to have two of the actors for padding purposes.
for i=1,num_rows+2 do
  local af = Def.ActorFrame{
    InitCommand=function(self)
      self.idx = i
      if i > num_rows then
        self:diffusealpha(0)
      end
      self:y(60 * i)
    end,
    UpdateSelfCommand=function(self)
      if #data < i or i > num_rows then
        self:diffusealpha(0)
      else
        self:diffusealpha(1)
      end
    end
  }

  af[#af+1] = Def.Quad{
    InitCommand=function(self)
      self:zoomto(350, 50):diffuse(Color.White)
      self.focus = false
    end,
    GainFocusCommand=function(self)
      self.focus = true
      self:diffuse(i == focus_pos and Color.Yellow or Color.White)
    end,
    LoseFocusCommand=function(self)
      self.focus = false
      self:diffuse(Color.White)
    end,
    UpdateSelfCommand=function(self)
      self:diffuse(self.focus and i == focus_pos and Color.Yellow or Color.White)
    end
  }

  af[#af+1] = Def.Quad{
    InitCommand=function(self)
      self:zoomto(350-2, 50-2):diffuse(Color.Black)
    end
  }

  af[#af+1] = LoadFont("Common Normal")..{
    Text="Lobby Code",
    InitCommand=function(self)
      self:x(-120):y(-10)
    end,
  }

  af[#af+1] = LoadFont("Common Bold")..{
    Text="",
    InitCommand=function(self)
			self:zoom(0.5):x(-120):y(10)
    end,
    UpdateSelfCommand=function(self)
      if i + offset <= #data then
        self:settext(data[i + offset].code)
      end
    end
  }

  af[#af+1] = LoadFont("Common Normal")..{
    Text="Players In Lobby",
    InitCommand=function(self)
      self:y(-10)
    end,
  }

  af[#af+1] = LoadFont("Common Bold")..{
    Text="",
    InitCommand=function(self)
			self:zoom(0.5):y(10)
    end,
    UpdateSelfCommand=function(self)
      if i + offset <= #data then
        self:settext(data[i + offset].playerCount)
      end
    end
  }

  af[#af+1] = LoadFont("Common Normal")..{
    Text="Protected",
    InitCommand=function(self)
      self:x(120):y(-10)
    end,
  }

  af[#af+1] = LoadFont("Common Normal")..{
    Text="🔒",
    InitCommand=function(self)
      self:visible(false):x(120):y(10)
    end,
    UpdateSelfCommand=function(self)
      if i + offset <= #data then
        self:visible(data[i + offset].isPasswordProtected)
      end
    end
  }

  t[#t+1] = af
end


return t