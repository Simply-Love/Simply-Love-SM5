function PlayerColor( pn )
	if pn == PLAYER_1 then return DifficultyIndexColor(3) end
	if pn == PLAYER_2 then return DifficultyIndexColor(1) end
	return color("1,1,1,1")
end

function DefaultColor()
	local color = SimplyLoveColor();
	if color < 10 then
		color = "0"..color;
	end
	
	return color;	
end



function SimplyLoveColor()
	local slc = GetUserPref("SimplyLoveColor") or 1;
	return tonumber(slc);
end

function SetSimplyLoveColor( c )
	SetUserPref('SimplyLoveColor', c);	
	MESSAGEMAN:Broadcast("ColorSelected");
	return c
end

function GetCurrentColor()
	local n = (SimplyLoveColor()%12)+1
	return GetHexColor(n)
end


function GetHexColor( n )
	if n == 1  then return color("#FF7D00") end
	if n == 2  then return color("#FF3C23") end
	if n == 3  then return color("#FF003C") end
	if n == 4  then return color("#C1006F") end
	if n == 5  then return color("#8200A1") end
	if n == 6  then return color("#413AD0") end
	if n == 7  then return color("#0073FF") end
	if n == 8  then return color("#00ADC0") end
	if n == 9  then return color("#5CE087") end
	if n == 10 then return color("#AEFA44") end
	if n == 11 then return color("#FFFF00") end
	if n == 12 then return color("#FFBE00") end
	return color("#ffffff")
end


	
function DifficultyColor( difficulty )
	
	if  difficulty  == "Difficulty_Edit" then return color("#B4B7BA") end
	local index = GetYOffsetByDifficulty(difficulty);
	
	return DifficultyIndexColor(index);
end


function DifficultyIndexColor( i )
	
	local clr = i + SimplyLoveColor() + 10
	clr = math.mod(clr-1,12)+1
		
	if clr == 1 then return color("#FF7D00") end
	if clr == 2 then return color("#FF3C23") end
	if clr == 3 then return color("#FF003C") end
	if clr == 4 then return color("#C1006F") end
	if clr == 5 then return color("#8200A1") end
	if clr == 6 then return color("#413AD0") end
	if clr == 7 then return color("#0073FF") end
	if clr == 8 then return color("#00ADC0") end
	if clr == 9 then return color("#5CE087") end
	if clr == 10 then return color("#AEFA44") end
	if clr == 11 then return color("#FFFF00") end
	if clr == 12 then return color("#FFBE00") end
	
	return color("1,1,1,1");
end


function GetYOffsetByDifficulty(difficulty)
	if  difficulty  == "Difficulty_Beginner" then
		offset = 1;
	elseif difficulty  == "Difficulty_Easy" then
		offset = 2;
	elseif difficulty  == "Difficulty_Medium" then
		offset = 3;
	elseif difficulty  == "Difficulty_Hard" then
		offset = 4;
	elseif difficulty  == "Difficulty_Challenge" then
		offset = 5;
	elseif difficulty  == "Difficulty_Edit" then
		offset = 5;
	end
	
	return offset;
end





function ColorRGB ( n )
	local clr = n + SimplyLoveColor() + 12
	clr = math.mod(clr-1,12)+1
	if clr == 1  then return color("1,0.49,0,1") end
	if clr == 2  then return color("1,0.24,0.14,1") end
	if clr == 3  then return color("1,0,0.24,1") end
	if clr == 4  then return color("0.76,0,0.44,1") end
	if clr == 5  then return color("0.51,0,0.63,1") end
	if clr == 6  then return color("0.25,0.23,0.82,1") end
	if clr == 7  then return color("0,0.45,1,1") end
	if clr == 8  then return color("0,0.68,0.75,1") end
	if clr == 9  then return color("0.36,0.88,0.53,1") end
	if clr == 10 then return color("0.68,0.98,0.27,1") end
	if clr == 11 then return color("1,1,0,1") end
	if clr == 12 then return color("1,0.75,0,1") end
	return color("1,1,1,1")
end




function SelectColorScrollerItems()
	if IsUsingWideScreen() then
		return 12
	else
		return 5
	end
end