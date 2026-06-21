local vocalizeList = GetVocalizations()

-- Table of just the names for easy randomization
local vocalizeNames = {}

for key, value in pairs(vocalizeList) do
  table.insert(vocalizeNames, key)
end

local numVoices = table.getn(vocalizeNames)

function GetSpeakerFromMods(player)
	local speaker = SL[ToEnumShortString(player)].ActiveModifiers.Vocalize
    if (speaker == "Random") then 
		return vocalizeNames[math.random(1,numVoices)]
	else
		return speaker
	end
end


function GetDigits(player,speaker)
	local digits = {''}
	
	if GAMESTATE:IsPlayerEnabled(player) then
		local score = STATSMAN:GetCurStageStats():GetPlayerStageStats(player):GetPercentDancePoints() * 100 + 0.005
		local int = math.floor(score)
		local dec1 = math.floor((score - int) * 10)
		local dec2 = math.floor((score - int) * 100 - dec1 * 10)

		if int == 100 then
			digits[1] = '100percent' .. math.random(1, vocalizeList[speaker])
		else
			if int < 20 then
				digits[1] = int;
				digits[2] = 'point'
			elseif math.mod(int,10) == 0 then
				digits[1] = int;
				digits[2] = 'point'
			else
				digits[1] = int - math.mod(int,10);
				digits[2] = math.mod(int,10);
				digits[3] = 'point'
			end
			for i=2,4 do
				if not digits[i] then
					digits[i] = dec1;
					digits[i+1] = dec2
					break
				end
			end
		end
	end
	return digits
end

function Vocalize(player,digit,digits,speaker)
	if digits[digit] then
		SOUND:PlayOnce(THEME:GetPathS('', 'Vocalize/' .. speaker ..'/'..digits[digit]..'.ogg' ))
	end
end

-- AI wrote this. Seems to work
function GetAudioLengthInSeconds(file_data)
    if not file_data or file_data:sub(1, 4) ~= "OggS" then
        return nil, "Not a valid Ogg file or file is empty"
    end

    -- 1. Extract the sample rate from the Vorbis identification header
    -- (4 bytes starting at index 41 of the file)
    local sample_rate_pos = 41
    local b1, b2, b3, b4 = file_data:byte(sample_rate_pos, sample_rate_pos + 3)
    if not b1 then return nil, "Failed to parse sample rate headers" end
    local sample_rate = b1 + (b2 * 256) + (b3 * 65536) + (b4 * 16777216)

    if sample_rate == 0 then return nil, "Invalid sample rate" end

    -- 2. Find total samples from the final Ogg page header
    local file_size = #file_data
    
    -- Look backwards from the end of the file string to find the final "OggS" sync marker
    local last_ogg_pos = nil
    for i = file_size - 3, 1, -1 do
        if file_data:sub(i, i + 3) == "OggS" then
            last_ogg_pos = i
            break
        end
    end

    if not last_ogg_pos then
        return nil, "Could not locate the final Ogg page header block"
    end

    -- Extract 64-bit granule position (total audio samples) at offset +6 from the marker
    local g_pos = last_ogg_pos + 6
    local gb = { file_data:byte(g_pos, g_pos + 7) }
    
    local total_samples = 0
    for i = 0, 7 do
        total_samples = total_samples + ((gb[i + 1] or 0) * (256 ^ i))
    end

    -- 3. Calculate length in seconds
    return total_samples / sample_rate
end

return Def.ActorFrame{
	InitCommand=function(self)
		self.p1Speaker = GetSpeakerFromMods(PLAYER_1)
		self.p2Speaker = GetSpeakerFromMods(PLAYER_2)
		self.p1Digits = GetDigits(PLAYER_1,self.p1Speaker)
		self.p2Digits = GetDigits(PLAYER_2,self.p2Speaker)
		
		if GAMESTATE:IsPlayerEnabled(PLAYER_1) and self.p1Speaker ~= "Off" then
			for i=1,table.getn(self.p1Digits) do
				self:queuecommand("Vocalize"..i)
				local audioClip = lua.ReadFile(THEME:GetPathS('', 'Vocalize/' .. self.p1Speaker .. '/' .. self.p1Digits[i] ..'.ogg'))
				self:sleep(GetAudioLengthInSeconds(audioClip))
			end
			-- Pause between players
			self: sleep(0.3)
		end
		
		if GAMESTATE:IsPlayerEnabled(PLAYER_2) and self.p2Speaker ~= "Off" then
			for i=1,table.getn(self.p2Digits) do
				self:queuecommand("Vocalize"..i+5)
				local audioClip = lua.ReadFile(THEME:GetPathS('', 'Vocalize/' .. self.p2Speaker .. '/' .. self.p2Digits[i] ..'.ogg'))
				self:sleep(GetAudioLengthInSeconds(audioClip))
			end
		end
	end,
	Vocalize1Command=function(self)
		Vocalize(PLAYER_1, 1, self.p1Digits, self.p1Speaker)
	end,
	Vocalize2Command=function(self)
		Vocalize(PLAYER_1, 2, self.p1Digits, self.p1Speaker)
	end,
	Vocalize3Command=function(self)
		Vocalize(PLAYER_1, 3, self.p1Digits, self.p1Speaker)
	end,
	Vocalize4Command=function(self)
		Vocalize(PLAYER_1, 4, self.p1Digits, self.p1Speaker)
	end,
	Vocalize5Command=function(self)
		Vocalize(PLAYER_1, 5, self.p1Digits, self.p1Speaker)
	end,
	Vocalize6Command=function(self)
		Vocalize(PLAYER_2, 1, self.p2Digits, self.p2Speaker)
	end,
	Vocalize7Command=function(self)
		Vocalize(PLAYER_2, 2, self.p2Digits, self.p2Speaker)
	end,
	Vocalize8Command=function(self)
		Vocalize(PLAYER_2, 3, self.p2Digits, self.p2Speaker)
	end,
	Vocalize9Command=function(self)
		Vocalize(PLAYER_2, 4, self.p2Digits, self.p2Speaker)
	end,
	Vocalize10Command=function(self)
		Vocalize(PLAYER_2, 5, self.p2Digits, self.p2Speaker)
	end,
}