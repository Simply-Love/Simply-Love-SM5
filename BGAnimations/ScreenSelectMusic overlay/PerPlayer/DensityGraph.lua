local player = ...
local pn = ToEnumShortString(player)

-- Height and width of the density graph.
local height = 64
local width = IsUsingWideScreen() and 286 or 276

local af = Def.ActorFrame{
	InitCommand=function(self)
		self:visible( GAMESTATE:IsHumanPlayer(player) )
		self:xy(_screen.cx-182, _screen.cy+23)

		if player == PLAYER_2 then
			self:addy(height+24)
		end

		if IsUsingWideScreen() then
			self:addx(-5)
		end
	end,
	PlayerJoinedMessageCommand=function(self, params)
		if params.Player == player then
			self:visible(true)
		end
	end,
	PlayerUnjoinedMessageCommand=function(self, params)
		if params.Player == player then
			self:visible(false)
		end
	end,
	CurrentSongChangedMessageCommand=function(self) self:queuecommand("UpdateGraph") end,
	["CurrentSteps"..pn.."ChangedMessageCommand"]=function(self) self:queuecommand("UpdateGraph") end,

	UpdateGraphCommand=function(self)
		if not GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentSong() then
			self:GetChild("Breakdown"):visible(true)
			self:GetChild("DensityGraph"):visible(true)
			self:GetChild("NPS"):visible(true)
		else
			self:GetChild("Breakdown"):visible(false)
			self:GetChild("DensityGraph"):visible(false)
			self:GetChild("NPS"):settext("Peak NPS: ")
			self:GetChild("NPS"):visible(false)
		end
	end,
}

-- Background quad for the density graph
af[#af+1] = Def.Quad{
	InitCommand=function(self)
		self:diffuse(color("#1e282f")):zoomto(width, height)
		if ThemePrefs.Get("RainbowMode") then
			self:diffusealpha(0.9)
		end
	end
}

-- The Density Graph itself
af[#af+1] = NPS_Histogram(player, width, height)..{
	Name="DensityGraph",
	OnCommand=function(self)
		self:addx(-width/2):addy(height/2)
	end,
}

-- The Peak NPS text
af[#af+1] = LoadFont("Miso/_miso")..{
	Name="NPS",
	Text="Peak NPS: ",
	InitCommand=function(self)
		self:horizalign(left):zoom(0.8)
		if player == PLAYER_1 then
			self:addx(60):addy(-41)
		else
			self:addx(-136):addy(-41)
		end
		-- We want black text in Rainbow mode, white otherwise.
		self:diffuse(DarkUI() and {0, 0, 0, 1} or {1, 1, 1, 1})
	end,
	-- Need this in the case someone scrolls out of the folder and then back in
	-- since we don't end up reparsing the chart in that case.
	["CurrentSteps"..pn.."ChangedMessageCommand"] = function(self)
		if SL[pn].Streams.PeakNPS ~= 0 then
			self:settext(("Peak NPS: %.1f"):format(SL[pn].Streams.PeakNPS))
		end
	end,
	[pn.."ChartParsedMessageCommand"] = function(self)
		if SL[pn].Streams.PeakNPS ~= 0 then
			self:settext(("Peak NPS: %.1f"):format(SL[pn].Streams.PeakNPS))
		end
	end
}

-- Breakdown
af[#af+1] = Def.ActorFrame{
	Name="Breakdown",
	InitCommand=function(self)
		local actorHeight = 17
		self:addy(height/2 - actorHeight/2)
	end,

	Def.Quad{
		InitCommand=function(self)
			local bgHeight = 17
			self:diffuse(color("#000000")):zoomto(width, bgHeight):diffusealpha(0.5)
		end
	},
	
	LoadFont("Miso/_miso")..{
		Text="",
		InitCommand=function(self)
			local textHeight = 17
			local textZoom = 0.8
			self:maxwidth(width/textZoom):zoom(textZoom)
		end,
		["CurrentSteps"..pn.."ChangedMessageCommand"]=function(self)
			self:queuecommand("UpdateBreakdown")
		end,
		UpdateBreakdownCommand=function(self)
			local textZoom = 0.8
			self:settext(GenerateBreakdownText(pn, 0))
			local minimization_level = 1
			while self:GetWidth() > (width/textZoom) and minimization_level < 4 do
				self:settext(GenerateBreakdownText(pn, minimization_level))
				minimization_level = minimization_level + 1
			end
		end,
	}
}

return af