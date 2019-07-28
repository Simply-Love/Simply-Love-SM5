-- Your Drifting Mind

-- make an effort to namespace the many things we'll want to be
-- passing around our many files
local g = {}

g.maps = { "Autumn1", "Winter1", "Winter2", "Winter3", "Winter4", "Winter5", "Blizzard" }
g.CurrentMap = 1
g.collision_layer = {}

g.TimeAtStart = GetTimeSinceStart()

g.InputIsLocked = false
g.SleepDuration = 0.2

g.map = {
	af = nil,
	zoom = 1
}
g.Dialog = {
	Speaker = "Elli"
}

g.SeenEvents = {}
g.Events = {}
g.Player = {}

g.RunTime = function() return GetTimeSinceStart() - g.TimeAtStart end

local map_data = {}
for i,map in ipairs(g.maps) do map_data[i] = LoadActor("./map_data/" .. map .. ".lua") end

local parallax_af = LoadActor("./ParallaxBackground.lua", map_data)
local map_af = LoadActor("./MapActorFrame.lua", {g, map_data})
local phone = LoadActor("./phone/phone.lua")
local dialog_box = LoadActor("./DialogBox/dialog_box.lua", {g})

-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

return Def.ActorFrame{

	-- audio
	LoadActor("./YourDriftingMindAQ.ogg")..{
		OnCommand=function(self) self:sleep(13):queuecommand("PlayAudio") end,
		PlayAudioCommand=function(self) self:play() end
	},

	phone,
	parallax_af,
	map_af,
	dialog_box,

	-- Quad used to fade to black while transitioning between maps
	-- it handles more logic than it should because of time constraints :(
	Def.Quad{
		InitCommand=function(self) self:diffuse(0,0,0,1):FullScreen():Center(); g.SceneFade = self end,
		OnCommand=function(self) self:hibernate(13):queuecommand("FadeToClear") end,
		FadeToBlackCommand=function(self)
			g.InputIsLocked = true
			self:smooth(0.5):diffusealpha(1):queuecommand("ChangeMap")
		end,
		FadeToClearCommand=function(self)
			g.InputIsLocked = false
			self:smooth(0.5):diffusealpha(0)
		end,
		ChangeMapCommand=function(self)
			local facing = g.Player[g.CurrentMap].dir
			local map_af = self:GetParent():GetChild("Map ActorFrame")
			local parallax_af = self:GetParent():GetChild("ParallaxAF")
			parallax_af:playcommand("Hide")

			-- don't draw the old map
			map_af:GetChild("Map"..g.CurrentMap):visible(false)

			-- update CurrentMap index
			g.CurrentMap = g.next_map.index

			-- maintain the direction the player was last facing when transferring maps
			g.Player[g.CurrentMap].dir = facing
			-- call InitCommand on the player Sprite for this map, passing in starting position data specified in Tiled
			g.Player[g.CurrentMap].actor:playcommand("Init", {x=g.next_map.x, y=g.next_map.y} )

			-- reset this (just in case?)
			g.next_map = nil

			-- start drawing the new map and update its position if needed
			map_af:GetChild("Map"..g.CurrentMap):visible(true):playcommand("MoveMap")
			-- get a handle to the new parallax bg if it exists
			local parallax_bg = parallax_af:GetChild("Parallax"..g.CurrentMap)
			-- make the new parallax bg visible if it exists
			if parallax_bg then parallax_bg:visible(true) end

			self:queuecommand("FadeToClear")
		end
	},

	-- final fade
	Def.Quad{
		InitCommand=function(self)
			self:diffuse(1,1,1,0):FullScreen():Center()
				:hibernate(150)
				:queuecommand("FadeToWhite")
		end,
		FadeToWhiteCommand=function(self)
			self:linear(45):diffusealpha(1)
				:queuecommand("WhyAmILikeThis")
		end,
		WhyAmILikeThisCommand=function(self)
			SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
		end
	},
}