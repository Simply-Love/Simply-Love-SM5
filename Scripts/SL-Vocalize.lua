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

Vocalization = {}