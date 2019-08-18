local Players = GAMESTATE:GetHumanPlayers()
local NumPanes = SL.Global.GameMode=="Casual" and 1 or 6

-- Start by loading actors that would be the same whether 1 or 2 players are joined.
local t = Def.ActorFrame{

	-- add a lua-based InputCalllback to this screen so that we can navigate
	-- through multiple panes of information; pass a reference to this ActorFrame
	-- and the number of panes there are to InputHandler.lua
	OnCommand=function(self)
		SCREENMAN:GetTopScreen():AddInputCallback( LoadActor("./InputHandler.lua", {af=self, num_panes=NumPanes}) )
	end,

	-- ./Graphics/Triangles.lua, shows up if we're in StomperZ mode
	LoadActor( THEME:GetPathB("", "Triangles.lua") ),

	-- code for triggering a screenshot and animating a "screenshot" texture
	LoadActor("./ScreenshotHandler.lua"),

	-- the title of the song and its graphical banner, if there is one
	LoadActor("./TitleAndBanner.lua"),

	-- text to display BPM range (and ratemod if ~= 1.0) immediately under the banner
	LoadActor("./BPM_RateMod.lua"),

	-- code for handling score vocalization
	LoadActor("./ScoreVocalization.lua"),

	-- store some attributes of this playthrough of this song in the global SL table
	-- for later retrieval on ScreenEvaluationSummary
	LoadActor("./GlobalStorage.lua"),

	-- help text that appears if we're in Casual gamemode
	LoadActor("./CasualHelpText.lua")
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

		-- letter grade
		LoadActor("./PerPlayer/LetterGrade.lua", player),

		-- nice
		LoadActor("./PerPlayer/nice.lua", player),

		-- stepartist
		LoadActor("./PerPlayer/StepArtist.lua", player),

		-- difficulty text and meter
		LoadActor("./PerPlayer/Difficulty.lua", player),

		-- Record Texts (Machine and/or Personal)
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
				self:x(_screen.cx + (player==PLAYER_1 and -155 or 155))
			end
		end,

		-- background quad for player stats
		Def.Quad{
			Name="LowerQuad",
			InitCommand=function(self)
				self:diffuse(color("#1E282F")):y(_screen.cy+34):zoomto( 300,180 )
				if ThemePrefs.Get("RainbowMode") then
					self:diffusealpha(0.9)
				end
			end,
			-- this background Quad may need to shrink and expand if we're playing double
			-- and need more space to accommodate more columns of arrows;  these commands
			-- are queued as needed from the InputHandler
			ShrinkCommand=function(self)
				self:zoomto(300,180):x(0)
			end,
			ExpandCommand=function(self)
				self:zoomto(520,180):x(3)
			end
		},

		-- "Look at this graph."  –Some sort of meme on The Internet
		LoadActor("./PerPlayer/Graphs.lua", player),

		-- list of modifiers used by this player for this song
		LoadActor("./PerPlayer/PlayerModifiers.lua", player),

		-- was this player disqualified from ranking?
		LoadActor("./PerPlayer/Disqualified.lua", player),
	}

	-- add available Panes to the lower ActorFrame via a loop
	-- Note(teejusb): Some of these actors may be nil. This is not a bug, but
	-- a feature for any panes we want to be conditional (e.g. the QR code).
	for i=1, NumPanes do
		lower[#lower+1] = LoadActor("./PerPlayer/Pane"..i, player)
	end

	-- add lower ActorFrame to the primary ActorFrame
	t[#t+1] = lower
end


return t