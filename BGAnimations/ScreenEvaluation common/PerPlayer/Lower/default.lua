-- per-player lower half of ScreenEvaluation

local player, NumPanes = unpack(...)

local af = Def.ActorFrame{
	Name=ToEnumShortString(player).."_AF_Lower",
	OnCommand=function(self)
		-- if double style, center the gameplay stats
		if GAMESTATE:GetCurrentStyle():GetStyleType() == "StyleType_OnePlayerTwoSides" then
			self:x(_screen.cx)
		else
			self:x(_screen.cx + (player==PLAYER_1 and -155 or 155))
		end
	end
}

-- -----------------------------------------------------------------------
-- background quad for player stats

af[#af+1] = Def.Quad{
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
}

-- "Look at this graph."  –Some sort of meme on The Internet
af[#af+1] = LoadActor("./Graphs.lua", player)

-- list of modifiers used by this player for this song
af[#af+1] = LoadActor("./PlayerModifiers.lua", player)

-- was this player disqualified from ranking?
af[#af+1] = LoadActor("./Disqualified.lua", player)

-- -----------------------------------------------------------------------
-- add available Panes to the lower ActorFrame via a loop
-- Note(teejusb): Some of these actors may be nil. This is not a bug, but
-- a feature for any panes we want to be conditional.

for i=1, NumPanes do
	af[#af+1] = LoadActor("./Pane"..i, player)
end

-- -----------------------------------------------------------------------

return af