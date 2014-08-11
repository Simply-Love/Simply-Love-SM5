local Players = GAMESTATE:GetHumanPlayers()

local t = Def.ActorFrame{
	
	CodeMessageCommand=function(self, params)
		if params.Name == "Screenshot" then
			SaveScreenshot(params.PlayerNumber, false, true)
		end
	end,
	
	-- quad behind the song/course title text
	Def.Quad{
		InitCommand=cmd(diffuse,color("#1E282F"); xy,_screen.cx, 54.5; zoomto, 292.5,20)
	},

	-- song/course title text
	LoadFont("_misoreg hires")..{
		InitCommand=cmd(xy,_screen.cx,54; NoStroke; shadowlength,1; maxwidth, 294 ),
		OnCommand=function(self)
			local songtitle = GAMESTATE:GetCurrentSong():GetDisplayFullTitle()
			if songtitle then
				self:settext(songtitle)
			end
		end
	},
		
	
	
	--fallback banner
	LoadActor( THEME:GetPathB("ScreenSelectMusic", "overlay/colored_banners/banner" .. SimplyLoveColor() .. ".png"))..{
		OnCommand=cmd(xy, _screen.cx, 121.5; zoom, 0.7)
	},
	
	--songs's banner, if it has one
	Def.Sprite{
		Name="Banner",
		InitCommand=cmd(xy, _screen.cx, 121.5),
		OnCommand=function(self)
			-- these need to be declared as empty variables here
			-- otherwise, the banner from round1 can persist into round2
			-- if round2 doesn't have banner!
			local song, bannerpath
			song = GAMESTATE:GetCurrentSong()
			
			if song then
				 bannerpath = song:GetBannerPath()
			end
			
			if bannerpath then
				self:LoadBanner(bannerpath)
				self:setsize(418,164)
				self:zoom(0.7)
			end
		end
	},
	
	--quad behind the ratemod, if there is one
	Def.Quad{
		InitCommand=cmd(diffuse,color("#1E282FCC"); xy,_screen.cx, 172; zoomto, 292.5,14 ),
		OnCommand=function(self)
			local MusicRate = SL.Global.ActiveModifiers.MusicRate
			if MusicRate == 1 then
				self:visible(false)
			end
		end
	},
	
	--the ratemod, if there is one
	LoadFont("_misoreg hires")..{
		InitCommand=cmd(xy,_screen.cx, 173; shadowlength,1; zoom, 0.7),
		OnCommand=function(self)	
			-- what was the MusicRate for this song?
			local MusicRate = SL.Global.ActiveModifiers.MusicRate
			
			-- Store the MusicRate for later retrieval on ScreenEvaluationSummary
			SL.Global.Stages.MusicRate[#SL.Global.Stages.MusicRate + 1] = MusicRate
			
			local bpm = GetDisplayBPMs()
			
			if MusicRate ~= 1 then
				self:settext(string.format("%.1f", MusicRate) .. " Music Rate")

				if bpm then

					--if there is a range of BPMs
					if string.match(bpm, "%-") then
						local bpms = {}
						for i in string.gmatch(bpm, "%d+") do
							bpms[#bpms+1] = round(tonumber(i) * MusicRate)
						end
						if bpms[1] and bpms[2] then
							bpm = bpms[1] .. "-" .. bpms[2]
						end
					else
						bpm = tonumber(bpm) * MusicRate
					end
					
					self:settext(self:GetText() .. " (" .. bpm .. " BPM)" )
				end
			else
				-- else MusicRate was 1.0
				self:settext("")
			end
		end
	},
	
	-- Score Vocalization
	LoadActor("score_vocalization")
}

for pn in ivalues(Players) do
	
	t[#t+1] = Def.ActorFrame{
		Name=ToEnumShortString(pn).." AF Upper",
		OnCommand=function(self)
			if pn == PLAYER_1 then
				self:x(_screen.cx - 155)
			elseif pn == PLAYER_2 then
				self:x(_screen.cx + 155)
			end
		end,
		
		
	
		--letter grade
		LoadActor("letterGrade", pn)..{
			InitCommand=function(self)
				if pn == PLAYER_1 then
					self:xy(-70, _screen.cy-134)
				elseif pn == PLAYER_2 then
					self:xy(70, _screen.cy-134)
				end
			end,
			OnCommand=cmd(zoom, 0.4)
		},
	
	
		--stepartist
		LoadFont("_misoreg hires")..{
			InitCommand=function(self)
				if pn == PLAYER_1 then
					self:xy(-115, _screen.cy-80)
					self:horizalign(left)
				elseif pn == PLAYER_2 then
					self:xy(115, _screen.cy-80)
					self:horizalign(right)
				end
				self:zoom(0.7)
			end,
			BeginCommand=function(self)					
				local stepartist;
				local cs = GAMESTATE:GetCurrentSteps(pn)
			
				if cs then
					stepartist = cs:GetAuthorCredit()
				end
				self:settext(stepartist)
			end
		},
		
		--difficulty text
		LoadFont("_misoreg hires")..{
			InitCommand=function(self)
				if pn == PLAYER_1 then
					self:xy(-115, _screen.cy-64)
					self:horizalign(left)
				elseif pn == PLAYER_2 then
					self:xy(115, _screen.cy-64)
					self:horizalign(right)
				end
				self:zoom(0.7)
			end,
			OnCommand=function(self)
				local currentSteps = GAMESTATE:GetCurrentSteps(pn)
				
				if currentSteps then
					local difficulty = currentSteps:GetDifficulty();
					-- GetDifficulty() returns a value from the Difficulty Enum
					-- "Difficulty_Hard" for example.
					-- Strip the characters up to and including the underscore.
					difficulty = difficulty:gsub("Difficulty_", "")
					self:settext(THEME:GetString("Difficulty", difficulty))
				end
			end
		},
		
		-- Record Texts
		LoadActor("recordTexts", pn)..{
			InitCommand=function(self)
				if pn == PLAYER_1 then
					self:xy(-80, 54)
				elseif pn == PLAYER_2 then
					self:xy(80, 54)
				end
				self:zoom(0.225)
			end
		},
	
		-- colored background for the chart's difficulty meter
		Def.Quad{
			InitCommand=function(self)
				self:zoomto(30, 30)
				if pn == PLAYER_1 then
					self:xy(-134.5, _screen.cy-71)
				elseif pn == PLAYER_2 then
					self:xy(134.5, _screen.cy-71)
				end
			end,
			OnCommand=function(self)			
				local currentSteps = GAMESTATE:GetCurrentSteps(pn)
				if currentSteps then
					local currentDifficulty = currentSteps:GetDifficulty()
					self:diffuse(DifficultyColor(currentDifficulty))
				end
			end
		},					
	
		-- chart's difficulty meter
		LoadFont("_wendy small")..{
			InitCommand=function(self)
				self:diffuse(Color.Black)
				self:zoom(0.4)
				if pn == PLAYER_1 then
					self:xy(-134.5, _screen.cy-71)
				elseif pn == PLAYER_2 then
					self:xy(134.5, _screen.cy-71)
				end
			end,
			BeginCommand=function(self)
				local steps = GAMESTATE:GetCurrentSteps(pn);
				if steps then
					local meter = steps:GetMeter();
			
					if meter then	
						self:settext(meter)
					end
				end
			end
		}
	}
	
	t[#t+1] = Def.ActorFrame{
		Name=ToEnumShortString(pn).." AF Lower",
		OnCommand=function(self)
			if GAMESTATE:GetCurrentStyle():GetStyleType() == "StyleType_OnePlayerTwoSides" then
				self:x(_screen.cx)
			else
				if pn == PLAYER_1 then
					self:x(_screen.cx - 155)
				elseif pn == PLAYER_2 then
					self:x(_screen.cx + 155)
				end
			end
		end,
		
				
		-- background quad for player stats
		Def.Quad{
			InitCommand=cmd(diffuse,color("#1E282F"); y,_screen.cy+34; zoomto, 300,180 );
		},
	
			
		LoadActor("judgeLabels", pn)..{
			InitCommand=function(self)
				if pn == PLAYER_1 then
					self:xy(50, _screen.cy-24)
				elseif pn == PLAYER_2 then
					self:xy(-50, _screen.cy-24)
				end
			end
		},
		
		-- dark background quad behind player percent score
		Def.Quad{
			InitCommand=function(self)
				self:diffuse(color("#101519"))
				self:zoomto(160,60)
				if pn == PLAYER_1 then
					self:xy(-70, _screen.cy-26)
				elseif pn == PLAYER_2 then
					self:xy(70, _screen.cy-26)
				end
			end
		},
		
		-- percentage score
		LoadActor("percentage", pn)..{
			Name="PercentageContainer"..ToEnumShortString(pn),
			InitCommand=function(self)
				self:y(_screen.cy-26)
				self:zoom(0.65)
				self:horizalign(right)
				if pn == PLAYER_2 then
					self:x(140)
				end
			end,
			OnCommand=function(self)
				-- Format the Percentage string, removing the % symbol
				local text = self:GetText()
				text = text:gsub("%%", "")
				self:settext(text)
			end
		},

		-- numbers
		LoadActor("judgeNumbers", pn)..{
			InitCommand=function(self)
				if pn == PLAYER_1 then
					self:xy(90, _screen.cy-24);
				elseif pn == PLAYER_2 then
					self:xy(-90, _screen.cy-24);
				end
				self:zoom(0.8)
			end
		},
		
		Def.Quad{
			InitCommand=cmd(zoomto,300,53; y, _screen.cy+150.5; MaskSource),
			OnCommand=cmd(linear,1; cropleft,1)
		},
		
		Def.GraphDisplay{
			InitCommand=cmd(Load,"GraphDisplay"..SimplyLoveColor(); y, _screen.cy+150.5;),
			BeginCommand=function(self)
				local playerStageStats = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)
				local stageStats = STATSMAN:GetCurStageStats()
				self:Set(stageStats, playerStageStats)
				-- hide the GraphDisplay's stroke ("line")
				self:GetChild("Line"):diffusealpha(0)
				-- tween the GraphDisplay into visibility
				self:GetChild("")[2]:MaskDest(true)
			end
		},
		
		Def.ComboGraph{
			InitCommand=cmd(Load,"ComboGraphP1"; y, _screen.cy+182.5),
			BeginCommand=function(self)
				local playerStageStats = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)
				local stageStats = STATSMAN:GetCurStageStats()
				self:Set(stageStats, playerStageStats)
			end
		},
		
		LoadActor("playerOptions", pn)..{
			InitCommand=cmd(y, _screen.cy+200.5)
		},
		
		-- was this player disqualified from ranking?
		LoadActor("disqualified", pn)..{
			InitCommand=cmd(y, _screen.cy+138)
		},
		
	}
end



return t;