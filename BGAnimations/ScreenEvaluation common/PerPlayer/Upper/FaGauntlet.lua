local asdf = ''
local parts = {}
local player = ...

local TapTypes = { 'W1', 'W2', 'W3', 'W4', 'W5', 'Miss' }
local RadarTypes = { 'Holds', 'Mines', 'Rolls' }

local TapPoints = { 3, 1, 0, 0, 0, -1 }
local RadarPoints = { 3, -3, 3 }


--local score = TapNoteScore_W1

for part in GAMESTATE:GetCurrentSong():GetSongFilePath():gmatch("[^/]*") do
	if part:len() > 0 then
		parts[#parts+1] = part
	end
end

local pack = parts[2]


if not GAMESTATE:IsCourseMode() and pack == 'The Fantastic Attack Gauntlet' then
	local score = 0
	local max_score = 0
	
	local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
	for index, window in ipairs(TapTypes) do
		local number = stats:GetTapNoteScores( "TapNoteScore_"..window )
		score = score + number * TapPoints[index]
		max_score = max_score + number * 3
	end
	
	for index, RCType in ipairs(RadarTypes) do
		local performance = stats:GetRadarActual():GetValue( "RadarCategory_"..RCType )
		local possible = stats:GetRadarPossible():GetValue( "RadarCategory_"..RCType )
		
		if RadarPoints[index] > 0 then
			score = score + performance * RadarPoints[index]
			max_score = max_score + possible * RadarPoints[index]
		else
			score = score + (possible - performance) * RadarPoints[index]
		end
		
	end
	
	return Def.ActorFrame {
		LoadFont("Miso/_miso")..{
			InitCommand=function(self)
				self:y(144)
				self:x( (player == PLAYER_1 and -114) or 30 )
				self:settext('Thee Gauntlet:')
				self:zoom(0.8)
			end
		},
		LoadFont("Miso/_miso")..{
			InitCommand=function(self)
				self:y(144)
				self:x( (player == PLAYER_1 and -44) or 100 )
				self:settext(score .. ' / ' .. max_score)
				self:zoom(0.8)
			end
		}
	}
end