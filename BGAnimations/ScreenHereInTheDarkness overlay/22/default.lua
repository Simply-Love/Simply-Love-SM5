-- ----------------------------------------
-- Hold On
-- ----------------------------------------

local asset_width = WideScale(1440,1920)

local directory = "22"
local audio     = "Hold On.ogg"

local scenes = {
	--   start  shown       finish   hidden
	  {   0.200, false},   { 30.000, false},  -- scene 1
	  {  35.000, false},   {180.000, false},  -- scene 2
	  { 185.000, false},   {233.000, false},  -- scene 3
}

-- ----------------------------------------

local kinetic_novel = LoadActor("../_shared/basement stories/default.lua", {scenes, directory, audio, asset_width})

return kinetic_novel