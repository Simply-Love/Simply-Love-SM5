function bool_option_row(name, get, set, true_text, false_text, one_for_all, trans_section)
	if trans_section then
		if THEME:HasString(trans_section, true_text) then
			true_text= THEME:GetString(trans_section, true_text)
		end
		if THEME:HasString(trans_section, false_text) then
			false_text= THEME:GetString(trans_section, false_text)
		end
	end
	return {
		Name= name, OneChoiceForAllPlayers= one_for_all,
		LayoutType= "ShowAllInRow", SelectType= "SelectOne",
		Choices= {true_text, false_text},
		LoadSelections= function(self, list, pn)
			if get(pn) then
				list[1]= true
			else
				list[2]= true
			end
		end,
		SaveSelections= function(self, list, pn)
			set(pn, list[1])
		end,
	}
end

function int_range_option_row(name, get, set, min, max, one_for_all)
	local choices= {}
	for i= min, max do
		choices[#choices+1]= i
	end
	return {
		Name= name, OneChoiceForAllPlayers= one_for_all,
		LayoutType= "ShowAllInRow", SelectType= "SelectOne",
		Choices= choices,
		LoadSelections= function(self, list, pn)
			local value= clamp(get(pn), min, max)
			list[(value-min)+1]= true
		end,
		SaveSelections= function(self, list, pn)
			for i= 1, #list do
				if list[i] then
					set(pn, choices[i])
				end
			end
		end,
	}
end
