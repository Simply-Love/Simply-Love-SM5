------------------------------------------------------------
-- 06 SL-Utilities.lua
-- Utility Functions for Development
--
-- The filename starts with "06" so that it loads before other SL scripts that rely on
-- global functions defined here.  For more information on this numbering system that
-- pretty much no one uses, see: ./Themes/_fallback/Scripts/hierarchy.txt

------------------------------------------------------------
-- define helper functions local to this file first
-- global utility functions (below) will depend on these
------------------------------------------------------------

-- TableToString() function via:
-- http://www.hpelbers.org/lua/print_r
-- Copyright 2009: hans@hpelbers.org
TableToString = function(t, name, indent)
	local tableList = {}
	local table_r

	table_r = function(t, name, indent, full)
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
						table.insert(out,table_r(value,key,indent .. '|    ',tableList[t]))
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


------------------------------------------------------------
-- GLOBAL UTILITY FUNCTIONS
-- use these to assist in theming/scripting efforts
------------------------------------------------------------

-- SM()
-- Shorthand for SCREENMAN:SystemMessage(), this is useful for rapid iterative
-- testing by allowing us to pretty-print tables and variables to the screen.
--
-- If the first argument is a table, SM() will use TableToString (from above)
-- to display children recursively.  Larger tables will spill offscreen, so
-- rec_print_table() from the _fallback theme is good to know about and use when
-- debugging.  That will recursively pretty-print table structures to ./Logs/Log.txt
--
-- The second arugment is optional and allows you to provide a specific duration,
-- in seconds, for how long you want the text to appear on screen.
-- in Simply Love, the default SystemMessage duration used in ./BGA/ScreenSystemLayer overlay.lua is 3

SM = function( arg, duration )
	local msg

	-- if a table has been passed in, recursively stringify the table's keys and values
	if type( arg ) == "table" then
		msg = TableToString(arg)

	-- otherwise, Lua's standard tostring() should suffice
	else
		msg = tostring(arg)
	end

	-- SCREENMAN:SystemMessage() is effectively a convenience function for broadcasting
	-- "SystemMessage" with certain parameters.  see: ScreenManager.cpp
	-- let's broadcast directly using MESSAGEMAN so that we can also pack in a duration
	-- value (how long to display the SystemMessage for) if so desired
	MESSAGEMAN:Broadcast("SystemMessage", {Message=msg, Duration=duration})
	Trace(msg)
end


-- range() accepts one, two, or three arguments and returns a table
-- Example Usage:

-- range(4)           → {1, 2, 3, 4}
-- range(4, 7)        → {4, 5, 6, 7}
-- range(5, 27, 5)    → {5, 10, 15, 20, 25}

-- either of these are acceptable
-- range(-1,-3, 0.5)  → {-1, -1.5, -2, -2.5, -3 }
-- range(-1,-3, -0.5) → {-1, -1.5, -2, -2.5, -3 }

-- but this just doesn't make sense and will return an empty table
-- range(1, 3, -0.5)  → {}

range = function(start, stop, step)
	if start == nil then return end

	if not stop then
		stop = start
		start = 1
	end

	step = step or 1

	-- if step has been explicitly provided as a positive number
	-- but the start and stop values tell us to decrement
	-- multiply step by -1 to allow decrementing to occur
	if step > 0 and start > stop then
		step = -1 * step
	end

	local t = {}
	for i = start, stop, step do
		t[#t+1] = i
	end
	return t
end

-- stringify() accepts an indexed table, applies tostring() to each element,
-- and returns the results.  sprintf style format can be provided via an
-- optional second argument.  Note that this function will remove key/value pairs
-- if any are passed in via "tbl".
--
-- Example:
-- 		local blah = stringify( {10, true, "hey now", asdf=10} )
-- Result:
-- 		blah == { "10", "true", "hey now" }
--
-- For an example with range()
-- see Mini in ./Scripts/SL-PlayerOptions.lua
function stringify( tbl, form )
	if not tbl then return end

	local t = {}
	for _,value in ipairs(tbl) do
		t[#t+1] = (type(value)=="number" and form and form:format(value) ) or tostring(value)
	end
	return t
end

-- iterates over a numerically-indexed table (haystack) until a desired value (needle) is found
-- if found, return the index (number) of the desired value within the table
-- if not found, return nil
function FindInTable(needle, haystack)
	for i = 1, #haystack do
		if needle == haystack[i] then
			return i
		end
	end
	return nil
end

-- i'm learning haskell okay? map is nice -ian5v
function map(func, array)
	local new_array = {}
	for i,v in ipairs(array) do
		new_array[i] = func(v)
	end
	return new_array
end


-- Create a new table with each unique element from the input present exactly once,
-- e.g. {1, 2, 3, 2, 1} -> {1, 2, 3}
function deduplicate(array)
	local hash = {}
	local res = {}

	for _, v in ipairs(array) do
		if not hash[v] then
			res[#res+1] = v
			hash[v] = true
		end
	end

	return res
end
