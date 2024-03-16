if SL.Global.GameMode == "Casual" then return end

local player = ...
local pn = ToEnumShortString(player)
local NumPlayers = #GAMESTATE:GetHumanPlayers()

local GraphWidth  = THEME:GetMetric("GraphDisplay", "BodyWidth")
local GraphHeight = THEME:GetMetric("GraphDisplay", "BodyHeight")

local function TotalCourseLength()
    -- utility for graph stuff because i ended up doing this a lot
    -- i use this method instead of TrailUtil.GetTotalSeconds because that leaves unused time at the end in graphs
    local trail = GAMESTATE:GetCurrentTrail(player)
    local t = 0
    for te in ivalues(trail:GetTrailEntries()) do
        t = t + te:GetSong():GetLastSecond()
    end

    return t / SL.Global.ActiveModifiers.MusicRate
end

local function TotalCourseLengthPlayed()
	local trail = GAMESTATE:GetCurrentTrail(player)
	local storage = SL[pn].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1]
	if storage.DeathSecond ~= nil then
		local deathSecond = storage.DeathSecond
		local t = 0
		for te in ivalues(trail:GetTrailEntries()) do
			t = t + ( te:GetSong():GetLastSecond() / SL.Global.ActiveModifiers.MusicRate )
			if t > deathSecond then break end
		end
		return t
	else
		return -1
	end
end

local af = Def.ActorFrame{
	Name="JudgeGraph",
	InitCommand=function(self)
		self:y(_screen.cy + 124)
		if NumPlayers == 1 then
			-- not quite an even 0.25 because we need to accomodate the extra 10px
			-- that would normally be between the left and right panes
			self:addx(GraphWidth * 0.2541)
		end
	end,

	-- Draw a Quad behind the GraphDisplay (lifebar graph) and Judgment ScatterPlot
	Def.Quad{
		InitCommand=function(self)
			self:zoomto(GraphWidth, GraphHeight):diffuse(color("#101519")):vertalign(top)
			if ThemePrefs.Get("VisualStyle") == "Technique" then
				self:diffusealpha(0.75)
			end
		end
	},
}

-- Only add the background histogram in normal gameplay.
-- Course mode needs to get all subsong density graphs and put them togetehr which we
-- don't currently support.
if not GAMESTATE:IsCourseMode() then
	af[#af+1] = NPS_Histogram(player, GraphWidth, GraphHeight, 0.5)..{
		Name="DensityGraph",
		OnCommand=function(self)
			self:addx(-GraphWidth/2):addy(GraphHeight)
			-- Lower the opacity otherwise some of the scatter plot points might become hard to see.
			self:diffusealpha(0.5)
			self:queuecommand("Redraw")
		end,
	}
else
	af[#af+1] = NPS_Histogram_Static_Course(player, GraphWidth, GraphHeight, 0.5)..{
		Name="DensityGraph",
		OnCommand=function(self)
			self:addx(-GraphWidth/2):addy(GraphHeight)
			-- Lower the opacity otherwise some of the scatter plot points might become hard to see.
			self:diffusealpha(0.5)
		end,
	}
end

af[#af+1] = LoadActor("./ScatterPlot.lua", {player=player, GraphWidth=GraphWidth, GraphHeight=GraphHeight} )

-- The GraphDisplay provided by the engine provides us a solid color histogram detailing
-- the player's lifemeter during gameplay capped by a white line.
-- in normal gameplay (non-CourseMode), we hide the solid color but leave the white line.
-- in CourseMode, we hide the white line (for aesthetic reasons) and leave the solid color
-- as ScatterPlot.lua does not yet support CourseMode.
af[#af+1] = Def.GraphDisplay{
	Name="GraphDisplay",
	InitCommand=function(self)
		self:vertalign(top)
		local ColorIndex = ((SL.Global.ActiveColorIndex + (player==PLAYER_1 and -1 or 1)) % #SL.Colors) + 1
		self:Load("GraphDisplay" .. ColorIndex )

		if not GAMESTATE:IsCourseMode() then
			local steps = GAMESTATE:GetCurrentSteps(player)
			local timingData = steps:GetTimingData()
			local firstSecond = math.min(timingData:GetElapsedTimeFromBeat(0), 0)
			local chartStartSecond = GAMESTATE:GetCurrentSong():GetFirstSecond()
			local lastSecond = GAMESTATE:GetCurrentSong():GetLastSecond()
			local duration = lastSecond - firstSecond

			-- GraphDisplay starts at chartStartSecond, but the NPS graph
			-- and the scatter plot start at firstSecond, so we have to
			-- move the lifebar to the correct offset to align it with the
			-- NPS graph.
			local offsetFactor = (chartStartSecond - firstSecond) / duration
			local offset = GraphWidth * offsetFactor
			self:addx(offset/2)
			self:SetWidth(GraphWidth - offset)
		else
			local duration = TotalCourseLength()
			local liveDuration = TotalCourseLengthPlayed()

			if liveDuration ~= -1 then
				self:SetWidth(liveDuration / duration * GraphWidth):x(-GraphWidth/2):horizalign(left)
			end
		end

		local playerStageStats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
		local stageStats = STATSMAN:GetCurStageStats()
		
		self:Set(stageStats, playerStageStats)
		
		-- hide the GraphDisplay's body (2nd unnamed child)
		self:GetChild("")[2]:visible(false)
		self:GetChild("Line"):addy(1)
	end
}

af[#af+1] = Def.Quad{
	Name="ZeroLine",
	InitCommand=function(self)
		self:zoomto(GraphWidth,1)
		self:y(GraphHeight/2)
		self:diffusealpha(0.1)
	end
}

local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
local storage = SL[pn].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1]

if storage.DeathSecond ~= nil then
	local seconds = storage.TotalSeconds
	local deathSecond = storage.DeathSecond
	local deathMeasures = storage.DeathMeasures
	local graphPercentage = storage.GraphPercentage
	local graphLabel = storage.GraphLabel
	local secondsLeft = seconds - deathSecond
	
	if GAMESTATE:IsCourseMode() then
		local duration = TotalCourseLength()
		local liveDuration = TotalCourseLengthPlayed()
		graphPercentage = graphPercentage * liveDuration / duration
	end

	-- If the player failed, check how much time was remaining
	af[#af+1] = Def.ActorFrame {
		InitCommand=function(self)
			self:zoom(1.25)
			-- Start at the start of the graph
			self:addx(-GraphWidth / 2):addy(GraphHeight - 10)
			-- Move to where the player failed
			self:addx(GraphWidth * graphPercentage)
		end,
		Def.ActorFrame {
			Name="BGQuad",
			SetSizeCommand=function(self, params)
				if params.lines == 2 then self:addy(-10) end
			end,
			Def.Quad {
				InitCommand=function(self)
					self:diffuse(Color.Red)
				end,
				SetSizeCommand=function(self, params)
					self:zoomto(params.width + 1, 10 * params.lines + 1)
					self:addx(params.addx)
				end
			},
			Def.Quad {
				InitCommand=function(self)
					self:diffuse(Color.Black)
				end,
				SetSizeCommand=function(self, params)
					self:zoomto(params.width,10 * params.lines)
					self:addx(params.addx)
				end
			},
		},
		LoadFont("Common Normal")..{
			InitCommand=function(self)
				self:zoom(0.5)
				self:diffuse(Color.Red)
				local text
				-- fail time formatting
				if secondsLeft > 3600 then
					-- format to display as H:MM:SS
					text = math.floor(secondsLeft / 3600) .. ":" .. SecondsToMMSS(secondsLeft % 3600)
				else
					-- format to display as M:SS
					text = SecondsToMSS(secondsLeft)
				end	
				if deathMeasures then text = text .. "\n" .. deathMeasures self:addy(-10) end
				self:settext(text)
				local width = self:GetWidth() * 0.65
				local addx = math.max(width * 0.8, 10)
				local quad = self:GetParent():GetChild("BGQuad")
				quad:playcommand("SetSize", { width=width, addx=addx, lines=(deathMeasures ~= nil and 2 or 1) })
				self:addx(addx)
			end
		}	
	}
end

return af
