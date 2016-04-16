local Players = GAMESTATE:GetHumanPlayers()
local game = GAMESTATE:GetCurrentGame():GetName()


-- Start by loading actors that would be the same whether 1 or 2 players are joined.
local t = Def.ActorFrame{
	OnCommand=function(self)
		-- sorry, kb7
		if game == "dance" or game == "pump" or game ~= "techno" then
			SCREENMAN:GetTopScreen():AddInputCallback( LoadActor("./InputHandler.lua", self) )
		end
	end,

	LoadActor( THEME:GetPathB("", "Triangles.lua") ),

	LoadActor("./ScreenshotHandler.lua"),

	LoadActor("./TitleAndBanner.lua"),

	LoadActor("./RateMod.lua"),

	LoadActor("./ScoreVocalization.lua"),

	LoadActor("./GlobalStorage.lua")
}



-- Then, load the player-specific actors.
for pn in ivalues(Players) do

	-- the upper half of ScreenEvaluation
	t[#t+1] = Def.ActorFrame{
		Name=ToEnumShortString(pn).."_AF_Upper",
		OnCommand=function(self)
			if pn == PLAYER_1 then
				self:x(_screen.cx - 155)
			elseif pn == PLAYER_2 then
				self:x(_screen.cx + 155)
			end
		end,

		-- store player stats for later retrieval on EvaluationSummary and NameEntryTraditional
		LoadActor("./PerPlayer/Storage.lua", pn),

		--letter grade
		LoadActor("./PerPlayer/LetterGrade.lua", pn),

		--stepartist
		LoadActor("./PerPlayer/StepArtist.lua", pn),

		--difficulty text and meter
		LoadActor("./PerPlayer/Difficulty.lua", pn),

		-- Record Texts
		LoadActor("./PerPlayer/RecordTexts.lua", pn)
	}

	-- the lower half of ScreenEvaluation
	local lower = Def.ActorFrame{
		Name=ToEnumShortString(pn).."_AF_Lower",
		OnCommand=function(self)

			-- if double style, center the gameplay stats
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
			Name="LowerQuad",
			InitCommand=cmd(diffuse,color("#1E282F"); y,_screen.cy+34; zoomto, 300,180 ),
			ShrinkCommand=function(self)
				self:zoomto(300,180):x(0)
			end,
			ExpandCommand=function(self)
				self:zoomto(520,180):x(3)
			end
		},

		-- "Look at this graph."
		-- Some sort of meme on the Internet
		LoadActor("./PerPlayer/Graphs.lua", pn),

		-- list of modifiers used by this player for this song
		LoadActor("./PerPlayer/PlayerModifiers.lua", pn),

		-- was this player disqualified from ranking?
		LoadActor("./PerPlayer/Disqualified.lua", pn),

		Def.ActorFrame{
			Name="Pane1",

			-- labels (like "FANTASTIC, MISS, holds, rolls, etc.")
			LoadActor("./PerPlayer/Pane1/JudgmentLabels.lua", pn),

			-- DP score displayed as a percentage
			LoadActor("./PerPlayer/Pane1/Percentage.lua", pn),

			-- numbers (how many Fantastics? How many misses? etc.)
			LoadActor("./PerPlayer/Pane1/JudgmentNumbers.lua", pn),
		},
	}

	if game ~= "dance" or game ~= "pump" or game ~= "techno" then
		lower[#lower+1] = Def.ActorFrame{
			Name="Pane2",
			InitCommand=function(self)
				local style = ToEnumShortString(GAMESTATE:GetCurrentStyle():GetStyleType())
				if style == "OnePlayerTwoSides" then
					self:x(-_screen.w/8 )
				end
				
				self:visible(false)
			end,

			LoadActor("./PerPlayer/Pane2/Percentage.lua", pn),
			LoadActor("./PerPlayer/Pane2/JudgmentLabels.lua", pn),
			LoadActor("./PerPlayer/Pane2/Arrows.lua", pn)
		}
	end

	t[#t+1] = lower
end



return t