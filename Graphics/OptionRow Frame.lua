local t = Def.ActorFrame{}

-- a row
t[#t+1] = Def.Quad {
	OnCommand=cmd(zoomto,_screen.w*0.85,_screen.h*0.0625;);
}

-- black quad behind the title
t[#t+1] = Def.Quad {
	OnCommand=cmd(halign, 0; x, -_screen.cx/1.1775; zoomto,_screen.w*WideScale(0.18,0.15),_screen.h*0.0625; diffuse, Color.Black; diffusealpha,0.25);
}

-- This feels pretty hackish.
-- ScreenPlayerOptions overlay.lua has all the necessary NoteSkin actors loaded but not showing.
--
-- Here, we're adding one ActorProxy per-player per-OptionRow.  That's a lot of ActorProxies that mostly aren't being used! :(
--
-- Once the OptionRows are ready (after the ScreenPlayerOptions is processed), we can check each OptionRow's name.
-- If GetName() returns "NoteSkin" then SetTarget() using the appropriate hidden NoteSkin actor.

for player in ivalues( GAMESTATE:GetHumanPlayers() ) do
	local pn = ToEnumShortString(player)

	t[#t+1] = Def.ActorProxy{
		Name="OptionRowProxy" ..pn,
		BeginCommand=function(self)
			local optrow = self:GetParent():GetParent():GetParent()

			if optrow:GetName() == "NoteSkin" then
				-- if this OptionRow is NoteSkin, set the necessary parameters and queuecommand("Update")
				-- to actually SetTarget() to the appropriate NoteSkin actor
				self:x(-_screen.cx/1.1775 + _screen.w*WideScale(0.18,0.15) - (player==PLAYER_1 and 45 or 15))
					:zoom(0.4)
					:queuecommand("Update")
			else
				-- if this OptionRow isn't NoteSkin, this ActorProxy isn't needed
				-- and can be cut out of the render pipeline
				self:hibernate(math.huge)
			end
		end,
		-- UpdateCommand() gets queued from ScreenPlayerOptions overlay.lua
		-- when MenuLeft or MenuRight is pressed while the NoteSkin OptionRow is active
		UpdateCommand=function(self)
			local bmt
			-- Typically, there are multiple NoteSkins to choose from, resulting in there being one BitmapText actor per player,
			-- and one (one player joined) or both (two players joined) will be nested in an indexed table.
			--
			-- If there is only a single NoteSkin available, however, the engine will only draw one BitmapText actor ("Item")
			-- and it won't be nested in a table,  So, check how many "Item" actors there are before attempting to index
			-- a table that might not exist.
			if #self:GetParent():GetParent():GetChild("Item") > 0 then
				bmt = self:GetParent():GetParent():GetChild("Item")[ PlayerNumber:Reverse()[player]+1 ]
			else
				bmt = self:GetParent():GetParent():GetChild("Item")
			end
			self:SetTarget( SCREENMAN:GetTopScreen():GetChild("Overlay"):GetChild("NoteSkin_"..bmt:GetText()) )
		end
	}
end

return t