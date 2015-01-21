-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
-- Development Utility Functions
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
local function SMPairs(t)
	local temp = ""
	for k,v in pairs(t) do
		temp = temp .. "key: " .. tostring(k) .. ", val: " .. tostring(v) .."\n"
	end
	SCREENMAN:SystemMessage(temp)
end

function SM(str)
	if type(str) == "table" then
		SMPairs(str)
	else
		SCREENMAN:SystemMessage(tostring(str))
	end
end

function FindInTable(needle, haystack)
	for i = 1, #haystack do
		if needle == haystack[i] then
			return i
		end
	end
	return nil
end