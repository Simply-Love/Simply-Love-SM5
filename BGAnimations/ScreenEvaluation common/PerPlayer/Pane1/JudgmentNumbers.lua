local player = ...
-- Use enum's reverse lookup to set pn to 1 if PLAYER_1, or 2 if PLAYER_2
local pn = PlayerNumber:Reverse()[player] + 1

local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)

local TapNoteScores = {
	Types = { 'W1', 'W2', 'W3', 'W4', 'W5', 'Miss' },
	-- x values for P1 and P2
	x = { 64, 94 }
}

local RadarCategories = {
	Types = { 'Holds', 'Mines', 'Hands', 'Rolls' },
	-- x values for P1 and P2
	x = { -180, 218 }
}

local StomperZColors = {
	color("#FFFFFF"),	-- white
	color("#e29c18"),	-- gold
	color("#66c955"),	-- green
	color("#21CCE8"),	-- blue
	color("#000000"),	-- black
	color("#ff0000")	-- red
}

local ECFAColors = {
	color("#21CCE8"),	-- blue
	color("#FFFFFF"),	-- white
	color("#e29c18"),	-- gold
	color("#66c955"),	-- green
	color("#9e00f7"),	-- purple
	color("#ff0000")	-- red
}


local t = Def.ActorFrame{
	InitCommand=cmd(zoom, 0.8; xy,90,_screen.cy-24),
	OnCommand=function(self)
		-- shift the x position of this ActorFrame to -90 for PLAYER_2
		if player == PLAYER_2 then
			self:x( self:GetX() * -1 )
		end
	end
}

-- do "regular" TapNotes first
for index, window in ipairs(TapNoteScores.Types) do

	local number = stats:GetTapNoteScores( "TapNoteScore_"..window )

	-- actual numbers
	t[#t+1] = Def.RollingNumbers{
		Font="_ScreenEvaluation numbers",
		InitCommand=function(self)
			self:zoom(0.5):horizalign(right)
				:set_chars_wide(4)
				:set_approach_seconds(1)
				:set_leading_attribute{ Diffuse=color("#444444") }

			-- if StomperZ, color the JudgmentNumbers
			if SL.Global.GameMode == "StomperZ" or SL.Global.GameMode == "ECFA" then
				self:set_number_attribute{ Diffuse=StomperZColors[index] }

			-- if ECFA, color the JudgmentNumbers
			elseif SL.Global.GameMode == "ECFA" then
				self:set_number_attribute{ Diffuse=ECFAColors[index] }
			end


			local gmods = SL.Global.ActiveModifiers

			-- If Way Offs were turned off, the leading 0s should not
			-- be colored any differently than the (lack of) JudgmentNumber,
			-- so load a unique Metric group.
			if gmods.DecentsWayOffs == "Decents Only" and window == "W5" then
				self:set_number_attribute{ Diffuse=color("#444444") }

			-- If both Decents and WayOffs were turned off, the same logic applies.
			elseif gmods.DecentsWayOffs == "Off" and (window == "W4" or window == "W5") then
				self:set_number_attribute{ Diffuse=color("#444444") }
			end
		end,
		BeginCommand=function(self)
			self:x( TapNoteScores.x[pn] )
			self:y((index-1)*35 -20)
			self:target_number(number)
		end
	}

end

-- then handle holds, mines, hands, rolls
for index, RCType in ipairs(RadarCategories.Types) do

	local performance = stats:GetRadarActual():GetValue( "RadarCategory_"..RCType )
	local possible = stats:GetRadarPossible():GetValue( "RadarCategory_"..RCType )

	-- player performace value
	t[#t+1] = Def.RollingNumbers{
		Font="_ScreenEvaluation numbers",
		InitCommand=function(self)
			self:zoom(0.5):halign(1)
				:set_chars_wide(3)
				:set_approach_seconds(1)
				:set_leading_attribute{ Diffuse=color("#444444") }
		end,
		BeginCommand=function(self)
			self:y((index-1)*35 + 53)
			self:x( RadarCategories.x[pn] )
			self:target_number(performance)
		end
	}

	--  slash
	t[#t+1] = LoadFont("_miso")..{
		Text="/",
		InitCommand=cmd(diffuse,color("#5A6166"); zoom, 1.25; horizalign, right),
		BeginCommand=function(self)
			self:y((index-1)*35 + 53)
			self:x( ((player == PLAYER_1) and -168) or 230 )
		end
	}

	-- possible value
	t[#t+1] = LoadFont("_ScreenEvaluation numbers")..{
		InitCommand=cmd(zoom,0.5; horizalign, right),
		BeginCommand=function(self)
			self:y((index-1)*35 + 53)
			self:x( ((player == PLAYER_1) and -114) or 286 )
			self:settext(("%03.0f"):format(possible))
			local leadingZeroAttr = { Length=3-tonumber(tostring(possible):len()); Diffuse=color("#5A6166") }
			self:AddAttribute(0, leadingZeroAttr )
		end
	}
end

return t