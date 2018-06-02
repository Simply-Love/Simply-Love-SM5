-- The rest of the code to handle score vocalizations exists in
-- ./BGAnimations/ScreenEvaluation common/score_vocalizations.lua
-- which is, of course, loaded from
-- ./BGAnimations/ScreenEvaluation common/default.lua

function ParseScores(args)
	local digits = {}

	for k,arg in pairs(args) do
		local score = arg[1]
		local pn = arg[2]

		score = score:gsub("%%","")
		local int = math.floor(score)
		local dec = tonumber(score:sub(-2))

		if int == 100 then
			digits[#digits+1] = {'quad', pn}

		elseif score == 0 then
			 digits[#digits+1] = {nil, pn}

		else
			if int < 20 or int % 10 == 0 then
				digits[#digits+1] = {int, pn}
				digits[#digits+1] = {'point', pn}
			else
				digits[#digits+1] = {int - int % 10, pn}
				digits[#digits+1] = {int % 10, pn}
				digits[#digits+1] = {'point', pn}
			end

			if dec < 20 == 0 then
				digits[#digits+1] = {dec, pn}
			else
				digits[#digits+1] = {(dec - (dec % 10))/10, pn}

				if dec % 10 ~= 0 then
					digits[#digits+1] = {dec % 10, pn}
				end
			end
		end
	end

	return digits
end

function GetVocalizeDir()
	return THEME:GetCurrentThemeDirectory() .. "/Other/Vocalize/"
end

-- global table for all available voices
-- we'll declare it here, and fill it with data below via dofile('path/to/voice/default.lua')
Vocalization = {}

-- what voice directories exist in ./Simply Love/Other/Vocalize/ ?
local directories = FILEMAN:GetDirListing(GetVocalizeDir() , true, false)

if #directories > 0 then
	for k,directory in ipairs(directories) do
		-- Dynamically fill the table.
		local voice_path = THEME:GetPathO("","Vocalize/" .. directory .. "/default.lua", true)

		-- load all available voices now
		-- yes, it requires (a little) more memory, but this is safer
		-- than attempting to load voices later, on-demand...
		if voice_path ~= "" then
			dofile(voice_path)
		end
	end
end