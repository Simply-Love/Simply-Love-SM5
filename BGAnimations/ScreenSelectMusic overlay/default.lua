local t = Def.ActorFrame{
	ChangeStepsMessageCommand=function(self, params)
		self:playcommand("StepsHaveChanged", {Direction=params.Direction, Player=params.Player})
	end
}

-- Each file contains the code for a particular screen element.
-- I've made this table ordered so that I can specificy
-- a desired draworder later below.

local files = {
	-- make the MusicWheel appear to cascade down
	"./MusicWheelAnimation.lua",
	-- Apply player modifiers from profile
	"./PlayerModifiers.lua",
	-- Graphical Banner
	"./Banner.lua",
	-- Song Artist, BPM, Duration (Referred to in other themes as "PaneDisplay")
	"./SongDescription.lua",
	-- Difficulty Blocks
	"./StepsDisplayList/Grid.lua",
	-- a folder of Lua files to be loaded twice (once for each player)
	"./PerPlayer"
}

for index, file in ipairs(files) do
	t[#t+1] = LoadActor(file)..{
		InitCommand=cmd(draworder, index)
	}
end

return t