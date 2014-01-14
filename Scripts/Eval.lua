-- evaluation stuff (mainly summary)

-- banner position offsets
local bannerPos = {
	Two		= {       -70,70      },	-- two songs
	Three	= {     -140,0,140    },	-- three songs
	Four	= {   -48,-16,16,48   },	-- four songs
	Five	= {  -64,-32,0,32,64  },	-- five songs
}

function BannerX(t,v)
	return bannerPos[t][v]
end

function GetBannerX(bannerNum)
	local maxSongs = PREFSMAN:GetPreference("SongsPerPlay")
	Trace(string.format("banner %i/%i",bannerNum,maxSongs));
	if maxSongs == 1 then
		return 0; -- middle
	elseif maxSongs > 1 and maxSongs < 5 then
		local allowExtra = PREFSMAN:GetPreference("AllowExtraStage")
		-- todo: check extra stage stuff

		if maxSongs == 2 then
			Trace("xPos = "..bannerPos.Two[bannerNum])
			return bannerPos.Two[bannerNum]
		elseif maxSongs == 3 then
			Trace("xPos = "..bannerPos.Three[bannerNum])
			return bannerPos.Three[bannerNum]
		elseif maxSongs == 4 then
			Trace("xPos = "..bannerPos.Four[bannerNum])
			return bannerPos.Four[bannerNum]
		end
	else
		-- we have 5 regardless.
		Trace("banner x is "..bannerPos.Five[bannerNum]);
		return bannerPos.Five[bannerNum]
	end

	return 0 -- crazy fallback
end

function GetBannerY(bannerNum)
	local maxSongs = PREFSMAN:GetPreference("SongsPerPlay")
	if maxSongs > 3 then return bannerNum*8
	else return 0
	end
end

function GetBannerScale()
	-- old:
	-- either 0.5 (for up to 4) or 0.25 (for 5)
	--local maxSongs = PREFSMAN:GetPreference("SongsPerPlay")
	--return maxSongs < 5 and 0.5 or 0.25

	return 0.5
end