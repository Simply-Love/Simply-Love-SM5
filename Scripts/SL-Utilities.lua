-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
-- Utility Functions For Development
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
-- define helper functions local to this file first
-- global utility functions (below) will depend on these
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
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

-- SM()
-- Shorthand for SCREENMAN:SystemMessage(), this is useful for
-- rapid iterative testing by allowing us to print variables to the screen.
-- If passed a table, SM() will use the recursive TableToString (from above)
-- to display children recursively until the SystemMessage spills off the screen.
function SM( arg )
	if type( arg ) == "table" then
		SCREENMAN:SystemMessage( TableToString_Recursive(arg) )
	else
		SCREENMAN:SystemMessage( tostring(arg) )
	end
end


-- range() generator via:
-- http://lua-users.org/wiki/RangeIterator (update #3)
-- The version here is a slight deviation from the one found at that URL.
-- This one allows decimal increments good to 3 places.
--
-- range(start)             	returns an iterator from 1 to a (step = 1)
-- range(start, stop)       	returns an iterator from a to b (step = 1)
-- range(start, stop, step) 	returns an iterator from a to b, counting by step.
function range(start, stop, step)
	if start == nil then return end

	if not stop then
		stop = start
		start  = stop == 0 and 0 or (stop > 0 and 1 or -1)
	end

	step = step or (start < stop and 1 or -1)

	-- step back (once) before we start
	start = start - step

	return function()
		-- Attempting to discern equivalence on floating points
		-- is an exercise in futility.  Do a little fudging here
		-- to only ascertain equivalence to 3 decimal places.
		if ("%.0f"):format(start*10^3) == ("%.0f"):format(stop*10^3) then
			return nil
		end

		start = start + step
		return start, start
	end
end

-- stringify() accepts an indexed table, applies tostring() to each element,
-- and returns the results.  sprintf style format can be provided via an
-- optional second argument.
function stringify( tbl, form )
	if not tbl then return end

	local t = {}
	for i in tbl do
		t[#t+1] = ( form and form:format(i) ) or tostring(i)
	end
	return t
end


function FindInTable(needle, haystack)
	for i = 1, #haystack do
		if needle == haystack[i] then
			return i
		end
	end
	return nil
end