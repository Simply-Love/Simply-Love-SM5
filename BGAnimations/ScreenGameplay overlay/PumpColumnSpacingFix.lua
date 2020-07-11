local player = ...

return Def.Actor{
	OnCommand=function(self)
		local screen = SCREENMAN:GetTopScreen()
		if screen then
			local playerAF = screen:GetChild("Player"..ToEnumShortString(player))
			if playerAF then
				local notefield = playerAF:GetChild("NoteField")
				if notefield then
					local columns = notefield:get_column_actors()
					local spacing = 7

					if #columns == 5 then
						for i, column in ipairs(columns) do
							column:addx((i-3)*spacing)
						end


					elseif #columns == 10 then
						for i, column in ipairs(columns) do
							column:addx(((i-5)*spacing) - spacing*0.5)
						end
					end
				end
			end
		end
	end
}