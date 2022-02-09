local af = ...

-- add one choice to represent empty string, e.g. "no character"
-- GAMESTATE:SetCharacter() doesn't actually accept this
-- once a dancing character is chosen this way, there aren't
-- Lua hooks available to set it back to "no character"
-- the SM5 engine would need to be patched
af[#af+1] = Def.Actor{
	Name="Characters_",
	InitCommand=function(self) self:visible(false) end
}

for dancing_character in ivalues( CHARMAN:GetAllCharacters() ) do
	local path = dancing_character:GetCardPath()

	if path ~= "" and FILEMAN:DoesFileExist(path) then
		af[#af+1] = LoadActor( path )..{
			Name="Characters_"..dancing_character:GetDisplayName(),
			InitCommand=function(self)
				local texture = self:GetTexture()
				local row_height = 70
				self:zoomtoheight(row_height)
				self:zoomtowidth( row_height * (texture:GetImageWidth()/texture:GetImageHeight()))
				self:visible(false) end,
		}
	else
		af[#af+1] = Def.Actor{ Name=("Characters_"..dancing_character:GetDisplayName()), InitCommand=function(self) self:visible(false) end }
	end
end
