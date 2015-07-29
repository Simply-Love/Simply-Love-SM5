-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
-- Utility Functions For Development
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
-- local helper functions first
-- the handful of global utility functions below will depend on these
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


-- TableToString_Recursive() function via:
-- http://www.hpelbers.org/lua/print_r
-- Copyright 2009: hans@hpelbers.org
local function TableToString_Recursive(t, name, indent)
	local tableList = {}

	function table_r (t, name, indent, full)
		local id = not full and name or type(name)~="number" and tostring(name) or '['..name..']'
		local tag = indent .. id .. ' = '
		local out = {}	-- result

		if type(t) == "table" then
			if tableList[t] ~= nil then
				table.insert(out, tag .. '{} -- ' .. tableList[t] .. ' (self reference)')
			else
				tableList[t]= full and (full .. '.' .. id) or id
				if next(t) then -- Table not empty
					table.insert(out, tag .. '{')
					for key,value in pairs(t) do
						table.insert(out,table_r(value,key,indent .. '|  ',tableList[t]))
					end
					table.insert(out,indent .. '}')
				else
					table.insert(out,tag .. '{}')
				end
			end
		else
			local val = type(t)~="number" and type(t)~="boolean" and '"'..tostring(t)..'"' or tostring(t)
			table.insert(out, tag .. val)
		end

		return table.concat(out, '\n')
	end

	return table_r(t,name or 'Value',indent or '')
end


-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
-- GLOBAL UTILITY FUNCTIONS
-- use these to assist in theming/scripting efforts

-- shorthand for SystemMessage()
-- displays tables recursively until the message spills off the screen
function SM( arg )
	if type( arg ) == "table" then
		SCREENMAN:SystemMessage( TableToString_Recursive(arg) )
	else
		SCREENMAN:SystemMessage( tostring(arg) )
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