-- ----------------------------------------
-- Distant Towers
-- ----------------------------------------

local asset_width = WideScale(1440,1920)

local directory = "21"
local audio     = "Distant Towers.ogg"

local scenes = {
	--   start  shown       finish   hidden
	  {  1.000, false},    { 31.000, false},  -- scene 1
	  { 35.333, false},    { 72.000, false},  -- scene 2
	  { 90.667, false},    {104.000, false},  -- scene 3
	  {106.667, false},    {150.000, false},  -- scene 4
	  {154.000, false},    {211.000, false},  -- scene 5
}

-- ----------------------------------------

local kinetic_novel = LoadActor("../_shared/basement stories/default.lua", {scenes, directory, audio, asset_width})

return kinetic_novel