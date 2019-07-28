-- score vocalization assets can be downloaded at
-- http://www.mediafire.com/file/mpsmto82d8diflr/Vocalize.zip

-- -------------------------------------
-- Vocalization is a global table that will contain timing data
-- for each digit of each available voice
Vocalization = {}

-- voice directories should be installed in ./Simply Love/Other/Vocalize/
-- but we can't assume that the theme directory will always be titled "Simply Love"
-- maybe the path is ./Simply-Love-SM5-master/Other/Vocalize/
-- maybe the path is ./Stamina-House-Tokyo/Other/Vocalize/
-- maybe someone else has made a new theme and is using this code
local vocalize_dir = THEME:GetCurrentThemeDirectory().."/Other/Vocalize/"

-- what voice directories exist in ./Simply Love/Other/Vocalize/ ?
local directories = FILEMAN:GetDirListing(vocalize_dir, true, false)

if #directories > 0 then
	for i, voice_dir in ipairs(directories) do
		local path = vocalize_dir .. voice_dir .. "/default.lua"

		-- if a file exists at ./Simply Love/Other/Vocalize/[voice_dir]/default.lua
		if FILEMAN:DoesFileExist(path) then
			-- then we'll just hope that it contains nice, error-free code that will add
			-- digit timing data for this voice directly to the Vocalization table
			-- because that's the backwards-compatible corner we've backed ourselves into
			dofile(path)
		end
	end
end
-- -------------------------------------

-- a starry afternoon
-- a sinking symphony
-- and the polo champ
-- who gave it all up
-- for no reason
-- whatsoever