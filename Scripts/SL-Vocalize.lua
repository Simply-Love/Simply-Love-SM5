function ParseScores(scores)
	local digits = {}
	
	for k,score in pairs(scores) do
		score = score:gsub("%%","")
		local int = math.floor(score)
		local dec = tonumber(score:sub(-2))
	
		if int == 100 then
			digits[#digits+1] = {'quad', "P"..k}
		
		elseif score == 0 then
			 digits[#digits+1] = {nil, "P"..k}
		 
		else
			if int < 20 or int % 10 == 0 then
				digits[#digits+1] = {int, "P"..k}
				digits[#digits+1] = {'point', "P"..k}
			else
				digits[#digits+1] = {int - int % 10, "P"..k}
				digits[#digits+1] = {int % 10, "P"..k}
				digits[#digits+1] = {'point', "P"..k}
			end
		
			if dec < 20 or dec % 10 == 0 then
				digits[#digits+1] = {dec, "P"..k}
			else
				digits[#digits+1] = {(dec - (dec % 10))/10, "P"..k}
				digits[#digits+1] = {dec % 10, "P"..k}
			end
		end
	end
	
	return digits
end

Vocalization = {}