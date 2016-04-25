local Players = GAMESTATE:GetHumanPlayers()

-- Start by loading actors that would be the same whether 1 or 2 players are joined.
local t = Def.ActorFrame{
	OnCommand=function(self)
		SCREENMAN:GetTopScreen():AddInputCallback( LoadActor("./InputHandler.lua", self) )
	end,

	LoadActor( THEME:GetPathB("", "Triangles.lua") ),

	LoadActor("./ScreenshotHandler.lua"),

	LoadActor("./TitleAndBanner.lua"),

	LoadActor("./RateMod.lua"),

	LoadActor("./ScoreVocalization.lua"),

	LoadActor("./GlobalStorage.lua")
}



-- Then, load the player-specific actors.
for player in ivalues(Players) do

	-- the upper half of ScreenEvaluation
	t[#t+1] = Def.ActorFrame{
		Name=ToEnumShortString(player).."_AF_Upper",
		OnCommand=function(self)
			if player == PLAYER_1 then
				self:x(_screen.cx - 155)
			elseif player == PLAYER_2 then
				self:x(_screen.cx + 155)
			end
		end,

		-- store player stats for later retrieval on EvaluationSummary and NameEntryTraditional
		LoadActor("./PerPlayer/Storage.lua", player),

		--letter grade
		LoadActor("./PerPlayer/LetterGrade.lua", player),

		--stepartist
		LoadActor("./PerPlayer/StepArtist.lua", player),

		--difficulty text and meter
		LoadActor("./PerPlayer/Difficulty.lua", player),

		-- Record Texts
		LoadActor("./PerPlayer/RecordTexts.lua", player)
	}

	-- the lower half of ScreenEvaluation
	local lower = Def.ActorFrame{
		Name=ToEnumShortString(player).."_AF_Lower",
		OnCommand=function(self)

			-- if double style, center the gameplay stats
			if GAMESTATE:GetCurrentStyle():GetStyleType() == "StyleType_OnePlayerTwoSides" then
				self:x(_screen.cx)
			else
				if player == PLAYER_1 then
					self:x(_screen.cx - 155)
				elseif player == PLAYER_2 then
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
		LoadActor("./PerPlayer/Graphs.lua", player),

		-- list of modifiers used by this player for this song
		LoadActor("./PerPlayer/PlayerModifiers.lua", player),

		-- was this player disqualified from ranking?
		LoadActor("./PerPlayer/Disqualified.lua", player),


	}
	
	lower[#lower+1] = LoadActor("./PerPlayer/Pane1", player)
	lower[#lower+1] = LoadActor("./PerPlayer/Pane2", player)
	lower[#lower+1] = LoadActor("./PerPlayer/Pane3", player)

	t[#t+1] = lower
end



return t