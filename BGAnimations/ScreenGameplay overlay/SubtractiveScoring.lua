local player = ...

if SL[ToEnumShortString(player)].ActiveModifiers.SubtractiveScoring then

  local style = ToEnumShortString(GAMESTATE:GetCurrentStyle():GetStyleType())
  local notefield_width = GAMESTATE:GetCurrentStyle():GetWidth(player)

  -- grab the appropriate x position from ScreenGameplay's
  -- metrics on Player positioning
  local x_position = GetNotefieldX( player )

  -- a flag to determine if we are using a GameMode that utilizes FA+ timing windows
  local FAplus = (SL.Global.GameMode == "StomperZ" or SL.Global.GameMode == "ECFA")
  local undesirable_judgment = FAplus and "W3" or "W2"

  -- flag to determine whether to bother to continue counting excellents
  -- or whether to just display percent away from 100%
  local received_judgment_lower_than_desired = false

  -- these start at 0 for each new song
  -- FIXME: What about course mode?
  local undesirable_judgment_count = 0
  local judgment_count = 0
  local tns
  local hns

  return Def.BitmapText{
    Font="_wendy small",
    InitCommand=function(self)
      self:horizalign(left)
        :diffuse(color("#ff4cff")):zoom(0.35)
        :xy( x_position + (notefield_width/2.9), _screen.cy )
    end,

    JudgmentMessageCommand=function(self, params)
      if player == params.Player then
        tns = ToEnumShortString(params.TapNoteScore)
        hns = params.HoldNoteScore
        self:queuecommand("SetScore")
      end
    end,

    SetScoreCommand=function(self, params)
      -- This is a bit convoluted!
      -- If this is a W2/undesirable_judgment, then we want to count up to 10 with them,
      -- unless we get some other judgment worse than W2/undesirable_judgment.
	  -- The complication is in how hold notes are counted.
	  --
	  -- Hold note judgments contain a copy of the tap
      -- note judgment that started it (because it affects your life regen?), so
      -- we have to be careful not to double count it against you.  But we also
      -- want to a dropped hold to trigger the percentage scoring.  So the
      -- choice is having a more straightforward if else structure, but at the
      -- expense of repeating the percent displaying code vs a more complicated
      -- if else structure. DRY, so second.

      -- used to determine if a player has failed yet
      local topscreen = SCREENMAN:GetTopScreen()

      -- if this is an undesirable judgment AND we can still count up AND it's not a dropped hold
      if tns == undesirable_judgment and not received_judgment_lower_than_desired and undesirable_judgment_count < 10 and (not hns or ToEnumShortString(hns) ~= "LetGo") then
        -- if this is the tail of a hold note, don't double count it
        if not hns then
          -- increment for the first ten
          undesirable_judgment_count = undesirable_judgment_count + 1
          -- and specificy literal W2 count
          self:settext("-" .. undesirable_judgment_count)
        end

      -- else if this wouldn't subtract from percentage (W1 or mine miss)
      elseif ((FAplus and tns ~= "W1" and tns ~= "W2") or (not FAplus and tns ~= "W1") and tns ~= "AvoidMine") or
             -- unless it actually would subtract from percentage (W1 + let go)
             (hns and ToEnumShortString(hns) == "LetGo") or
             -- or we're already dead (and so can't gain any percentage.)
             (topscreen:GetLifeMeter(player):IsFailing()) then

        received_judgment_lower_than_desired = true

        -- specify percent away from 100%
        local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
        local current_possible_dp = pss:GetCurrentPossibleDancePoints()
        local possible_dp = pss:GetPossibleDancePoints()

        -- max to prevent subtractive scoring reading more than -100%
        local actual_dp = math.max(pss:GetActualDancePoints(), 0)

        local score = current_possible_dp - actual_dp
        score = ((possible_dp - score) / possible_dp) * 100

        self:settext("-" .. string.format("%.2f", 100-score) .. "%" )
      end
    end
  }
end
