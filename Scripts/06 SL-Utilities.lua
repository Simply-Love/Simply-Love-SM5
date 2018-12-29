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


function table.val_to_str ( v )
	if "string" == type( v ) then
		v = string.gsub( v, "\n", "\\n" )

		if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
			return "'" .. v .. "'"
		end
		return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
	else
		return "table" == type( v ) and table.tostring( v ) or tostring( v )
	end
end

function table.key_to_str ( k )
	if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
		return k
	else
		return "[" .. table.val_to_str( k ) .. "]"
	end
end

function table.tostring( tbl )
	local result, done = {}, {}
	for k, v in ipairs( tbl ) do
		table.insert( result, table.val_to_str( v ) )
    	done[ k ] = true
	end
	for k, v in pairs( tbl ) do
		if not done[ k ] then
			table.insert( result, "\t" .. table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
		end
	end
	return "{\n" .. table.concat( result, ",\n" ) .. "\n}"
end


-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
-- GLOBAL UTILITY FUNCTIONS
-- use these to assist in theming/scripting efforts
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

-- SM()
-- Shorthand for SCREENMAN:SystemMessage(), this is useful for
-- rapid iterative testing by allowing us to print variables to the screen.
-- If passed a table, SM() will use the TableToString_Recursive (from above)
-- to display children recursively until the SystemMessage spills off the screen.
function SM( arg )

	-- if a table has been passed in
	if type( arg ) == "table" then

		-- recurively print its contents to a string
		local msg = TableToString_Recursive(arg)
		-- and SystemMessage() that string
		SCREENMAN:SystemMessage( msg )
	else
		SCREENMAN:SystemMessage( tostring(arg) )
	end
end


-- range() accepts one, two, or three arguments and returns a table
-- Example Usage:

-- range(4)			--> {1, 2, 3, 4}
-- range(4, 7)		--> {4, 5, 6, 7}
-- range(5, 27, 5) 	--> {5, 10, 15, 20, 25}

-- either of these are acceptable
-- range(-1,-3, 0.5)	--> {-1, -1.5, -2, -2.5, -3 }
-- range(-1,-3, -0.5)	--> {-1, -1.5, -2, -2.5, -3 }

-- but this just doens't make sense and will return an empty table
-- range(1, 3, -0.5)	--> {}

function range(start, stop, step)
	if start == nil then return end

	if not stop then
		stop = start
		start = 1
	end

	step = step or (start < stop and 1 or -1)

	-- if step has been explicitly provided as a positve number
	-- but the start and stop values tell us to decrement
	-- multiply step by -1 to allow decrementing to occur
	if step > 0 and start > stop then
		step = -1 * step
	end

	local t = {}
	while start < stop+step do
		t[#t+1] = start
		start = start + step
	end
	return t
end

function SecondsToMMSS_range(start, stop, step)
	local ret = {}
	local range = range(start, stop, step)
	for v in ivalues(range) do
		ret[#ret+1] = SecondsToMMSS(v):gsub("^0*", "")
	end
	return ret
end


-- stringify() accepts an indexed table, applies tostring() to each element,
-- and returns the results.  sprintf style format can be provided via an
-- optional second argument.  Note that this function will ignores key/value pairs
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


function FindInTable(needle, haystack)
	for i = 1, #haystack do
		if needle == haystack[i] then
			return i
		end
	end
	return nil
end