-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
-- Development Utility Functions
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function SMPairs(t)
	local temp = ""
	for k,v in pairs(t) do
		temp = temp .. "key: " .. tostring(k) .. ", val: " .. tostring(v) .."\n"
	end
	SCREENMAN:SystemMessage(temp);
end

function SM(str)
	SCREENMAN:SystemMessage(tostring(str));
end