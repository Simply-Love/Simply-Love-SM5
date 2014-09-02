local pn = ...

local TNSTypes = {
	'TapNoteScore_W1',
	'TapNoteScore_W2',
	'TapNoteScore_W3',
	'TapNoteScore_W4',
	'TapNoteScore_W5',
	'TapNoteScore_Miss'
}

local labels2_RC = {'RadarCategory_Holds', 'RadarCategory_Mines', 'RadarCategory_Hands', 'RadarCategory_Rolls' }

local n = Def.ActorFrame{
	InitCommand=cmd(visible, GAMESTATE:IsPlayerEnabled(pn))
}
local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)

local performance_x1,paddng_x1,performance_x2,slash_x,possible_x,padding_x2,padding_x3

-- this function is no longer modular; sorry about that, AJ :(
-- ( There are definitely better ways to do this, but I'm lazy. )
if pn == PLAYER_1 then
	performance_x1 = 64
	performance_x2 = -180
	slash_x = -168
	possible_x = -114
elseif pn == PLAYER_2 then
	performance_x1 = 94
	performance_x2 = 218
	slash_x = 230
	possible_x = 286
end


-- do the normals first
for i=1,#TNSTypes do

	local number = stats:GetTapNoteScores(TNSTypes[i])

	-- actual numbers
	n[#n+1] = Def.RollingNumbers{
		Font="_ScreenEvaluation numbers",
		InitCommand=cmd(shadowlength,1; zoom,0.5; visible, GAMESTATE:IsPlayerEnabled(pn); Load, "RollingNumbersEvaluationA" ),
		BeginCommand=function(self)
			self:x( performance_x1 )
			self:y((i-1)*35 -20)
			self:targetnumber(number)
			self:horizalign(right)
		end
	}

end



for i=1,#labels2_RC do

	local performance = stats:GetRadarActual():GetValue(labels2_RC[i])
	local possible = stats:GetRadarPossible():GetValue(labels2_RC[i])

	-- player performace value
	n[#n+1] = Def.RollingNumbers{
		Font="_ScreenEvaluation numbers",
		InitCommand=cmd(shadowlength,1; zoom,0.5; Load, "RollingNumbersEvaluationB"),
		BeginCommand=function(self)
			self:y((i-1)*35 + 53)
			self:x(performance_x2)
			self:targetnumber(performance)
			self:horizalign(right)
		end
	}

	--  slash
	n[#n+1] = LoadFont("_misoreg hires")..{
		Text="/",
		InitCommand=cmd(diffuse,color("#5A6166"); zoom, 1.25),
		BeginCommand=function(self)
			self:y((i-1)*35 + 53)
			self:x(slash_x)
			self:horizalign(right)
		end
	}

	-- possible value
	n[#n+1] = LoadFont("_ScreenEvaluation numbers")..{
		InitCommand=cmd(shadowlength,1; zoom,0.5),
		BeginCommand=function(self)
			self:y((i-1)*35 + 53)
			self:x(possible_x)
			self:horizalign(right)
			self:settext(("%03.0f"):format(possible))
			local leadingZeroAttr = { Length=3-tonumber(tostring(possible):len()); Diffuse=color("#5A6166") }
			self:AddAttribute(0, leadingZeroAttr )
		end
	}

end

return n