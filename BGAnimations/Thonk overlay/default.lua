local bpm = 179
local spb = 60/bpm

local sw = SCREEN_WIDTH
local sh = SCREEN_HEIGHT

local globalOffset = PREFSMAN:GetPreference("GlobalOffsetSeconds")

local base_positions = {}
local ss_playmode_items = {}

local splash_table = {}

taronuke_thonk_aft = nil
taronuke_thonk_giant1 = nil
taronuke_thonk_giant2 = nil

local lastbeat = -1
local beat = 0

local mods_beat_enabled = false
local mods_bob_enabled = false
local function mods_randomize_positions(power,skew)

	local underlay = SCREENMAN:GetTopScreen():GetChild("Underlay")
	local overlay = SCREENMAN:GetTopScreen():GetChild("Overlay")

	local sk = 0
	if skew then sk = 1 end

	if underlay:GetChild("ColorWheel") then
		for i=1,32 do
			if underlay:GetChild("ColorWheel"):GetChild("item"..i) then
				local zm = underlay:GetChild("ColorWheel"):GetChild("item"..i):GetZoom()

				underlay:GetChild("ColorWheel"):GetChild("item"..i):GetChild(""):stoptweening():x( math.random(-60*power,60*power)/zm ):y( math.random(-60*power,60*power)/zm ):rotationz( math.random(0,360) ):decelerate(sk*(60/bpm)):skewx(sk*.6)
			end
		end
	end

	if SCREENMAN:GetTopScreen():GetName() == "ScreenSelectStyle" then
		if underlay:GetChild("") then

			local tab = SCREENMAN:GetTopScreen():GetChild("Underlay"):GetChildren()

			for i=1,10 do
				local a = underlay:GetChild("")[i]
				if a then

					for j=1,10 do
						local b = a:GetChild("")[j]

						if b then

							local id = "ScreenSelectStyleitem_"..i.."_"..j

							if base_positions[id] then

								if j == 1 then --text item

									b:stoptweening():x( base_positions[id].x + math.random(-60*power,60*power) ):y( base_positions[id].y + math.random(-60*power,60*power) ):rotationz( math.random(0,360) ):decelerate(sk*(60/bpm)):skewx(sk*.6)

								else --pad items

									b:stoptweening():x( base_positions[id].x + math.random(-60*power,60*power) ):y( base_positions[id].y + math.random(-60*power,60*power) ):rotationz( math.random(0,360) ):decelerate(sk*(60/bpm)):skewx(sk*.6)

								end

							end

						end
					end

				end
			end

		end
	end

	if SCREENMAN:GetTopScreen():GetName() == "ScreenSelectPlayMode" or SCREENMAN:GetTopScreen():GetName() == "ScreenSelectPlayMode2" then

		for k,v in pairs(ss_playmode_items) do

			local b = v

			if b then

				b:x( base_positions[k].x + math.random(-60*power,60*power) )
					:y( base_positions[k].y + math.random(-60*power,60*power) )
					:rotationz( math.random(-45,45) )
					:decelerate(sk*(60/bpm)):skewx(sk*.6)

				if k == "ScreenSelectPlayModeItemUnderlay8" then
					b:zoom( base_positions[k].zoom )
				end

			end

		end

	end

end

local lr_pos = 1
local ud_pos = 1

local function mods_shuffle_lr(strength)

	local underlay = SCREENMAN:GetTopScreen():GetChild("Underlay")
	local overlay = SCREENMAN:GetTopScreen():GetChild("Overlay")

	if underlay:GetChild("ColorWheel") then
		for i=1,32 do
			if underlay:GetChild("ColorWheel"):GetChild("item"..i) then
				local zm = underlay:GetChild("ColorWheel"):GetChild("item"..i):GetZoom()

				underlay:GetChild("ColorWheel"):GetChild("item"..i):GetChild(""):stoptweening():x( strength*lr_pos/zm ):y( 0 ):rotationz( 0 )
			end
		end
	end

	if SCREENMAN:GetTopScreen():GetName() == "ScreenSelectStyle" then
		if underlay:GetChild("") then

			local tab = SCREENMAN:GetTopScreen():GetChild("Underlay"):GetChildren()

			local zm = 1
			local k = 1
			local k2 = 1
			for i=1,10 do
				local a = underlay:GetChild("")[i]
				if a then

					for j=1,10 do
						local b = a:GetChild("")[j]

						if b then

							local id = "ScreenSelectStyleitem_"..i.."_"..j

							if base_positions[id] then

								if j == 1 then --text item

									b:stoptweening():x( base_positions[id].x + ((k%2)*2-1) * strength*lr_pos/zm ):y( base_positions[id].y + 40 ):rotationz( 0 ):rotationy( 0 ):skewx(0)

									k = k+1

								else --pad items

									b:stoptweening():y( base_positions[id].y + ((k2%2)*2-1) * strength*lr_pos/zm ):x( base_positions[id].x ):rotationz( 0 ):skewx(0)

									k2 = k2+1

								end

							end

						end
					end

				end
			end

		end
	end

	if SCREENMAN:GetTopScreen():GetName() == "ScreenSelectPlayMode" or SCREENMAN:GetTopScreen():GetName() == "ScreenSelectPlayMode2" then

		for k,v in pairs(ss_playmode_items) do

			local b = v

			if b then

				b:x( base_positions[k].x + strength*lr_pos*1.2 )
					:y( base_positions[k].y )
					:rotationz( 0 ):skewx( 0 )

				if k == "ScreenSelectPlayModeItemUnderlay8" then
					b:zoom( base_positions[k].zoom )
				end

			end

		end

	end

	lr_pos = lr_pos*-1

end

local function mods_shuffle_ud(strength)

	local underlay = SCREENMAN:GetTopScreen():GetChild("Underlay")
	local overlay = SCREENMAN:GetTopScreen():GetChild("Overlay")

	if underlay:GetChild("ColorWheel") then
		for i=1,32 do
			if underlay:GetChild("ColorWheel"):GetChild("item"..i) then
				local zm = underlay:GetChild("ColorWheel"):GetChild("item"..i):GetZoom()

				underlay:GetChild("ColorWheel"):GetChild("item"..i):GetChild(""):stoptweening():y( ((i%2)*2-1) * strength*ud_pos/zm ):x( 0 ):rotationz( 0 )
			end
		end
	end

	if SCREENMAN:GetTopScreen():GetName() == "ScreenSelectStyle" then
		if underlay:GetChild("") then

			local tab = SCREENMAN:GetTopScreen():GetChild("Underlay"):GetChildren()

			local zm = 1
			local k = 1
			local k2 = 1
			for i=1,10 do
				local a = underlay:GetChild("")[i]
				if a then

					for j=1,10 do
						local b = a:GetChild("")[j]

						if b then

							local id = "ScreenSelectStyleitem_"..i.."_"..j

							if base_positions[id] then

								if j == 1 then --text item

									b:stoptweening():y( base_positions[id].y + 40 + ((k%2)*2-1) * strength*ud_pos/zm ):x( base_positions[id].x ):rotationz( 0 ):rotationy( 0 ):skewx(0)

									k = k+1

								else --pad items

									b:stoptweening():x( base_positions[id].x + ((1%2)*2-1) * strength*ud_pos/zm ):y( base_positions[id].y ):rotationz( 0 ):skewx(0)

									k2 = k2+1

								end

							end

						end
					end

				end
			end

		end
	end

	if SCREENMAN:GetTopScreen():GetName() == "ScreenSelectPlayMode" or SCREENMAN:GetTopScreen():GetName() == "ScreenSelectPlayMode2" then

		for k,v in pairs(ss_playmode_items) do

			local b = v

			if b then

				b:y( base_positions[k].y + strength*ud_pos*1.2 )
					:x( base_positions[k].x )
					:rotationz( 0 ):skewx( 0 )

				if k == "ScreenSelectPlayModeItemUnderlay8" then
					b:zoom( base_positions[k].zoom )
				end

			end

		end

	end

	ud_pos = ud_pos*-1

end

local function make_splash(amt)

	for i=1,amt do

		local a = splash_table[i]
		if a then
			local b = a:GetChild("")
			if b then

				local zm = (sh/480)*( .8 + math.random()*.4 )*.8
				local rz = math.random()*360
				local st = math.random()*.2
				local tt = (.8+math.random()*.4)*1.25

				a:finishtweening()
					:visible(true)
					:x( sw*.1 + math.random()*sw*.8 )
					:y( sh + 64*zm + 10 + math.random()*60*zm )
					:zoom( zm )
					:sleep(st)
					:decelerate(tt)
					:addy( -(200+math.random(300))*zm )
					:addx( math.random(-50,50) )
					:queuecommand("Hide")

				b:rotationz(rz)
					:sleep(st)
					:setstate( math.random(0,10) )
					:diffusealpha(2)
					:linear(tt)
					:diffusealpha(0)
					:rotationz(rz + (math.random(180,360))*(math.random(1,2)*2-3))

			end
		end

	end

	--splash_table[1]:Center()
	--splash_table[1]:visible(true)

end

local function beatBounce(fBeatStrength)

	local fAccelTime = 0.2;
	local fTotalTime = 0.75;

	local fBeat = beat + fAccelTime;

	local bEvenBeat = false;
	if math.mod(math.floor(fBeat),2) == 0 then
		bEvenBeat = true;
	end

	fBeat = fBeat-math.floor( fBeat );
	fBeat = fBeat+1;
	fBeat = fBeat-math.floor( fBeat );

	if fBeat >= fTotalTime then
		return 0
	end

	if fBeat<fTotalTime then
		local fAmount = 0;
		if fBeat < fAccelTime then
			fAmount = scale( fBeat, 0.0, fAccelTime, 0.0, 1.0);
			fAmount = fAmount*fAmount;
		else
			--fBeat < fTotalTime
			fAmount = scale( fBeat, fAccelTime, fTotalTime, 1.0, 0.0);
			fAmount = 1 - (1-fAmount) * (1-fAmount);
		end

		if bEvenBeat then
			fAmount = fAmount*-1;
		end

		local fShift = fAmount
		return fBeatStrength * fShift

	end

	return 0

end




local pulse_strength = 0


local mods_cur_mod = 1
local mods = {
	{0,function() pulse_strength = 0 end},
	{0,function() mods_bob_enabled = false end},
	{0,function() mods_beat_enabled = true end},
	{0,function() if beat < 1 then MESSAGEMAN:Broadcast("HideThonk") end end},
	{29.5,function() mods_beat_enabled = false end},
	{30,function() mods_randomize_positions(1) end},
	{31,function() mods_randomize_positions(1) end},
	{32,function() mods_beat_enabled = true end},
	{61.5,function() mods_beat_enabled = false end},
	{62,function() mods_randomize_positions(1) end},
	{63,function() mods_randomize_positions(1) end},
	{64,function() mods_bob_enabled = true end},
	{95.5,function() mods_beat_enabled = true end},
	{96,function() mods_bob_enabled = false end},
	{96,function() if beat < 97 then MESSAGEMAN:Broadcast("ThonkFadeIn") end end},
	{131.5,function() mods_beat_enabled = false end},
	{132,function() if beat < 133 then MESSAGEMAN:Broadcast("GiantThonk") end end},
	{132,function() mods_randomize_positions(2) end},
	{132.75,function() mods_randomize_positions(2) end},
	{133.5,function() mods_randomize_positions(2) end},
	{134.25,function() mods_randomize_positions(2) end},
	{135,function() mods_randomize_positions(2) end},
	{135.5,function() mods_randomize_positions(2) end},

	{136,function() pulse_strength = 1 end},

	--made with chart2lua :)
	{136.000,function() mods_randomize_positions(1,true) end},
	{137.000,function() mods_randomize_positions(1) end},
	{137.250,function() mods_randomize_positions(1) end},
	{137.500,function() mods_randomize_positions(1) end},
	{137.750,function() mods_randomize_positions(1) end},
	{138.000,function() mods_randomize_positions(1) end},
	{138.250,function() mods_randomize_positions(1) end},
	{138.500,function() mods_randomize_positions(1) end},
	{138.750,function() mods_randomize_positions(1) end},
	{139.000,function() mods_randomize_positions(1) end},
	{139.250,function() mods_randomize_positions(1) end},
	{139.500,function() mods_randomize_positions(1) end},
	{139.750,function() mods_randomize_positions(1) end},
	{140.000,function() mods_shuffle_lr(32) end},
	{140.250,function() mods_shuffle_lr(32) end},
	{140.500,function() mods_shuffle_lr(32) end},
	{140.750,function() mods_shuffle_lr(32) end},
	{141.000,function() mods_shuffle_ud(32) end},
	{141.500,function() mods_shuffle_ud(32) end},
	{142.000,function() mods_shuffle_lr(32) end},
	{142.500,function() mods_shuffle_lr(32) end},
	{143.000,function() mods_shuffle_lr(32) end},
	{143.500,function() mods_shuffle_lr(32) end},
	{144.000,function() mods_randomize_positions(1,true) end},
	{145.000,function() mods_randomize_positions(1) end},
	{145.250,function() mods_randomize_positions(1) end},
	{145.500,function() mods_randomize_positions(1) end},
	{145.750,function() mods_randomize_positions(1) end},
	{146.000,function() mods_randomize_positions(1) end},
	{146.250,function() mods_randomize_positions(1) end},
	{146.500,function() mods_randomize_positions(1) end},
	{146.750,function() mods_randomize_positions(1) end},
	{147.000,function() mods_randomize_positions(1) end},
	{147.250,function() mods_randomize_positions(1) end},
	{147.500,function() mods_randomize_positions(1) end},
	{147.750,function() mods_randomize_positions(1) end},
	{148.000,function() mods_shuffle_lr(32) end},
	{148.250,function() mods_shuffle_lr(32) end},
	{148.500,function() mods_shuffle_lr(32) end},
	{149.000,function() mods_shuffle_ud(32) end},
	{149.500,function() mods_shuffle_lr(32) end},
	{150.000,function() mods_shuffle_ud(32) end},
	{150.500,function() mods_shuffle_ud(32) end},
	{151.000,function() mods_shuffle_lr(32) end},
	{151.500,function() mods_shuffle_ud(32) end},
	{152.000,function() mods_randomize_positions(1,true) end},
	{153.250,function() mods_randomize_positions(1) end},
	{153.750,function() mods_randomize_positions(1) end},
	{154.000,function() mods_randomize_positions(1) end},
	{154.500,function() mods_randomize_positions(1) end},
	{154.750,function() mods_randomize_positions(1) end},
	{155.250,function() mods_randomize_positions(1) end},
	{155.500,function() mods_randomize_positions(1) end},
	{155.750,function() mods_randomize_positions(1) end},
	{156.000,function() mods_shuffle_lr(32) end},
	{156.250,function() mods_shuffle_lr(32) end},
	{156.500,function() mods_shuffle_lr(32) end},
	{156.750,function() mods_shuffle_lr(32) end},
	{157.000,function() mods_shuffle_ud(32) end},
	{157.500,function() mods_shuffle_ud(32) end},
	{158.000,function() mods_shuffle_lr(32) end},
	{158.500,function() mods_shuffle_ud(32) end},
	{159.000,function() mods_shuffle_lr(32) end},
	{159.500,function() mods_shuffle_ud(32) end},
	{160.000,function() mods_randomize_positions(1,true) end},
	{161.000,function() mods_randomize_positions(1) end},
	{161.250,function() mods_randomize_positions(1) end},
	{161.500,function() mods_randomize_positions(1) end},
	{161.750,function() mods_randomize_positions(1) end},
	{162.000,function() mods_randomize_positions(1) end},
	{162.250,function() mods_randomize_positions(1) end},
	{162.500,function() mods_randomize_positions(1) end},
	{162.750,function() mods_randomize_positions(1) end},
	{163.000,function() mods_randomize_positions(1) end},
	{163.250,function() mods_randomize_positions(1) end},
	{163.500,function() mods_randomize_positions(1) end},
	{163.750,function() mods_randomize_positions(1) end},
	{164.000,function() mods_shuffle_lr(32) end},
	{164.250,function() mods_shuffle_lr(32) end},
	{164.500,function() mods_shuffle_lr(32) end},
	{164.750,function() mods_shuffle_lr(32) end},
	{165.000,function() mods_shuffle_ud(32) end},
	{165.500,function() mods_shuffle_lr(32) end},
	{166.000,function() mods_shuffle_ud(32) end},
	{166.250,function() mods_shuffle_ud(32) end},
	{166.500,function() mods_shuffle_ud(32) end},
	{167.000,function() mods_shuffle_lr(32) end},
	{167.250,function() mods_shuffle_lr(32) end},
	{167.500,function() mods_shuffle_lr(32) end},
	{167.750,function() mods_shuffle_lr(32) end},
	{168.000,function() mods_randomize_positions(1,true) end},
	{169.000,function() mods_randomize_positions(1) end},
	{169.250,function() mods_randomize_positions(1) end},
	{169.500,function() mods_randomize_positions(1) end},
	{169.750,function() mods_randomize_positions(1) end},
	{170.000,function() mods_randomize_positions(1) end},
	{170.250,function() mods_randomize_positions(1) end},
	{170.500,function() mods_randomize_positions(1) end},
	{170.750,function() mods_randomize_positions(1) end},
	{171.000,function() mods_randomize_positions(1) end},
	{171.250,function() mods_randomize_positions(1) end},
	{171.500,function() mods_randomize_positions(1) end},
	{171.750,function() mods_randomize_positions(1) end},
	{172.000,function() mods_shuffle_lr(32) end},
	{172.250,function() mods_shuffle_lr(32) end},
	{172.500,function() mods_shuffle_lr(32) end},
	{172.750,function() mods_shuffle_lr(32) end},
	{173.000,function() mods_shuffle_ud(32) end},
	{173.500,function() mods_shuffle_ud(32) end},
	{174.000,function() mods_shuffle_lr(32) end},
	{174.500,function() mods_shuffle_lr(32) end},
	{175.000,function() mods_shuffle_lr(32) end},
	{175.500,function() mods_shuffle_lr(32) end},
	{176.000,function() mods_randomize_positions(1,true) end},
	{177.000,function() mods_randomize_positions(1) end},
	{177.250,function() mods_randomize_positions(1) end},
	{177.500,function() mods_randomize_positions(1) end},
	{177.750,function() mods_randomize_positions(1) end},
	{178.000,function() mods_randomize_positions(1) end},
	{178.250,function() mods_randomize_positions(1) end},
	{178.500,function() mods_randomize_positions(1) end},
	{178.750,function() mods_randomize_positions(1) end},
	{179.000,function() mods_randomize_positions(1) end},
	{179.250,function() mods_randomize_positions(1) end},
	{179.500,function() mods_randomize_positions(1) end},
	{179.750,function() mods_randomize_positions(1) end},
	{180.000,function() mods_shuffle_lr(32) end},
	{180.250,function() mods_shuffle_lr(32) end},
	{180.500,function() mods_shuffle_lr(32) end},
	{181.000,function() mods_shuffle_ud(32) end},
	{181.500,function() mods_shuffle_lr(32) end},
	{182.000,function() mods_shuffle_ud(32) end},
	{182.500,function() mods_shuffle_ud(32) end},
	{183.000,function() mods_shuffle_lr(32) end},
	{183.500,function() mods_shuffle_ud(32) end},
	{184.000,function() mods_randomize_positions(1,true) end},
	{185.250,function() mods_randomize_positions(1) end},
	{185.750,function() mods_randomize_positions(1) end},
	{186.000,function() mods_randomize_positions(1) end},
	{186.500,function() mods_randomize_positions(1) end},
	{186.750,function() mods_randomize_positions(1) end},
	{187.250,function() mods_randomize_positions(1) end},
	{187.500,function() mods_randomize_positions(1) end},
	{187.750,function() mods_randomize_positions(1) end},
	{188.000,function() mods_shuffle_lr(32) end},
	{188.250,function() mods_shuffle_lr(32) end},
	{188.500,function() mods_shuffle_lr(32) end},
	{188.750,function() mods_shuffle_lr(32) end},
	{189.000,function() mods_shuffle_ud(32) end},
	{189.500,function() mods_shuffle_ud(32) end},
	{190.000,function() mods_shuffle_lr(32) end},
	{190.500,function() mods_shuffle_ud(32) end},
	{191.000,function() mods_shuffle_lr(32) end},
	{191.500,function() mods_shuffle_ud(32) end},
	{192.000,function() mods_randomize_positions(1,true) end},
	{193.000,function() mods_randomize_positions(1) end},
	{193.250,function() mods_randomize_positions(1) end},
	{193.500,function() mods_randomize_positions(1) end},
	{193.750,function() mods_randomize_positions(1) end},
	{194.000,function() mods_randomize_positions(1) end},
	{194.250,function() mods_randomize_positions(1) end},
	{194.500,function() mods_randomize_positions(1) end},
	{194.750,function() mods_randomize_positions(1) end},
	{195.000,function() mods_randomize_positions(1) end},
	{195.250,function() mods_randomize_positions(1) end},
	{195.500,function() mods_randomize_positions(1) end},
	{195.750,function() mods_randomize_positions(1) end},
	{196.000,function() mods_shuffle_lr(32) end},
	{196.250,function() mods_shuffle_lr(32) end},
	{196.500,function() mods_shuffle_lr(32) end},
	{196.750,function() mods_shuffle_lr(32) end},
	{197.000,function() mods_shuffle_ud(32) end},
	{197.500,function() mods_shuffle_lr(32) end},
	{198.000,function() mods_shuffle_ud(32) end},
	{198.250,function() mods_shuffle_ud(32) end},
	{198.500,function() mods_shuffle_ud(32) end},
	{199.000,function() mods_shuffle_lr(32) end},
	{199.250,function() mods_shuffle_lr(32) end},
	{199.500,function() mods_shuffle_lr(32) end},
	{199.750,function() mods_shuffle_lr(32) end},
	{200.000,function() mods_randomize_positions(1,true) end},
	{201.000,function() mods_randomize_positions(1) end},
	{201.250,function() mods_randomize_positions(1) end},
	{201.500,function() mods_randomize_positions(1) end},
	{201.750,function() mods_randomize_positions(1) end},
	{202.000,function() mods_randomize_positions(1) end},
	{202.250,function() mods_randomize_positions(1) end},
	{202.500,function() mods_randomize_positions(1) end},
	{202.750,function() mods_randomize_positions(1) end},
	{203.000,function() mods_randomize_positions(1) end},
	{203.250,function() mods_randomize_positions(1) end},
	{203.500,function() mods_randomize_positions(1) end},
	{203.750,function() mods_randomize_positions(1) end},
	{204.000,function() mods_shuffle_lr(32) end},
	{204.250,function() mods_shuffle_lr(32) end},
	{204.500,function() mods_shuffle_lr(32) end},
	{204.750,function() mods_shuffle_lr(32) end},
	{205.000,function() mods_shuffle_ud(32) end},
	{205.500,function() mods_shuffle_ud(32) end},
	{206.000,function() mods_shuffle_lr(32) end},
	{206.500,function() mods_shuffle_lr(32) end},
	{207.000,function() mods_shuffle_lr(32) end},
	{207.500,function() mods_shuffle_lr(32) end},
	{208.000,function() mods_randomize_positions(1,true) end},
	{209.000,function() mods_randomize_positions(1) end},
	{209.250,function() mods_randomize_positions(1) end},
	{209.500,function() mods_randomize_positions(1) end},
	{209.750,function() mods_randomize_positions(1) end},
	{210.000,function() mods_randomize_positions(1) end},
	{210.250,function() mods_randomize_positions(1) end},
	{210.500,function() mods_randomize_positions(1) end},
	{210.750,function() mods_randomize_positions(1) end},
	{211.000,function() mods_randomize_positions(1) end},
	{211.250,function() mods_randomize_positions(1) end},
	{211.500,function() mods_randomize_positions(1) end},
	{211.750,function() mods_randomize_positions(1) end},
	{212.000,function() mods_shuffle_lr(32) end},
	{212.250,function() mods_shuffle_lr(32) end},
	{212.500,function() mods_shuffle_lr(32) end},
	{213.000,function() mods_shuffle_ud(32) end},
	{213.500,function() mods_shuffle_lr(32) end},
	{214.000,function() mods_shuffle_ud(32) end},
	{214.500,function() mods_shuffle_ud(32) end},
	{215.000,function() mods_shuffle_lr(32) end},
	{215.500,function() mods_shuffle_ud(32) end},
	{216.000,function() mods_randomize_positions(1,true) end},
	{217.250,function() mods_randomize_positions(1) end},
	{217.750,function() mods_randomize_positions(1) end},
	{218.000,function() mods_randomize_positions(1) end},
	{218.500,function() mods_randomize_positions(1) end},
	{218.750,function() mods_randomize_positions(1) end},
	{219.250,function() mods_randomize_positions(1) end},
	{219.500,function() mods_randomize_positions(1) end},
	{219.750,function() mods_randomize_positions(1) end},
	{220.000,function() mods_shuffle_lr(32) end},
	{220.250,function() mods_shuffle_lr(32) end},
	{220.500,function() mods_shuffle_lr(32) end},
	{220.750,function() mods_shuffle_lr(32) end},
	{221.000,function() mods_shuffle_ud(32) end},
	{221.500,function() mods_shuffle_ud(32) end},
	{222.000,function() mods_shuffle_lr(32) end},
	{222.500,function() mods_shuffle_ud(32) end},
	{223.000,function() mods_shuffle_lr(32) end},
	{223.500,function() mods_shuffle_ud(32) end},
	{224.000,function() mods_randomize_positions(1,true) end},
	{225.000,function() mods_randomize_positions(1) end},
	{225.250,function() mods_randomize_positions(1) end},
	{225.500,function() mods_randomize_positions(1) end},
	{225.750,function() mods_randomize_positions(1) end},
	{226.000,function() mods_randomize_positions(1) end},
	{226.250,function() mods_randomize_positions(1) end},
	{226.500,function() mods_randomize_positions(1) end},
	{226.750,function() mods_randomize_positions(1) end},
	{227.000,function() mods_randomize_positions(1) end},
	{227.250,function() mods_randomize_positions(1) end},
	{227.500,function() mods_randomize_positions(1) end},
	{227.750,function() mods_randomize_positions(1) end},
	{228.000,function() mods_shuffle_lr(32) end},
	{228.250,function() mods_shuffle_lr(32) end},
	{228.500,function() mods_shuffle_lr(32) end},
	{228.750,function() mods_shuffle_lr(32) end},
	{229.000,function() mods_randomize_positions(3) end},
	{229.500,function() mods_randomize_positions(3) end},
	{230.000,function() mods_shuffle_ud(32) end},
	{230.250,function() mods_shuffle_ud(32) end},
	{230.500,function() mods_shuffle_ud(32) end},
	{230.750,function() mods_shuffle_ud(32) end},
	{231.000,function() mods_randomize_positions(3) end},
	{231.500,function() mods_randomize_positions(3) end},
	{232.000,function() mods_shuffle_lr(32) end},
	{232.250,function() mods_shuffle_lr(32) end},
	{232.500,function() mods_shuffle_lr(32) end},
	{232.750,function() mods_shuffle_lr(32) end},
	{233.000,function() mods_randomize_positions(2) end},
	{233.500,function() mods_randomize_positions(2) end},
	{234.000,function() mods_randomize_positions(1) end},
	{234.250,function() mods_randomize_positions(1) end},
	{234.500,function() mods_randomize_positions(1) end},
	{235.000,function() mods_randomize_positions(2) end},
	{235.500,function() mods_randomize_positions(2) end},
	{235,function() pulse_strength = 0 end},
}

local pulse_beat = 0

local Update = function(self, delta)


	--This is more reliable than GAMESTATE:GetSongBeat() it seems
	beat = (self:GetSecsIntoEffect() + globalOffset) * (bpm/60)

	--beat = (GAMESTATE:GetSongBeat() * ratio) - 1

	--SM(beat)

	local underlay = SCREENMAN:GetTopScreen():GetChild("Underlay")
	local overlay = SCREENMAN:GetTopScreen():GetChild("Overlay")

	if beat < lastbeat then
		mods_cur_mod = 1
		pulse_beat = 0
	end

	while beat > pulse_beat do

		if math.mod(pulse_beat,8) == 0 then
			if pulse_beat >= 136 and pulse_beat < 168 then
				make_splash(5)
			elseif pulse_beat >= 168 and pulse_beat < 200 then
				make_splash(10)
			elseif pulse_beat >= 200 and pulse_beat <= 228 then
				make_splash(15)
			end
		end

		if pulse_beat == 0 or pulse_beat == 32 or pulse_beat == 64 or pulse_beat == 96 then
			--make_splash(5)
		end

		pulse_beat = pulse_beat+1
		if pulse_beat == 132 then pulse_beat = 136 end
		MESSAGEMAN:Broadcast("Pulse")
	end

	while mods_cur_mod <= #mods and beat > mods[mods_cur_mod][1] do

		mods[mods_cur_mod][2]()

		mods_cur_mod = mods_cur_mod+1

	end

	if taronuke_thonk_giant1 and taronuke_thonk_giant2 then

		if beat > 96 and beat < 132 then

			local amt = (beat-96)/36

			--scaletofit,0,0,sw*.4,sh*.4;Center;diffusealpha,0;
			taronuke_thonk_giant1:visible(true):stopeffect():scaletofit(0,0,sw*(.4+amt*.1),sh*(.4+amt*.1)):Center():diffusealpha( amt*.15 )
			taronuke_thonk_giant2:visible(true):stopeffect():scaletofit(0,0,sw*(.4+amt*.1),sh*(.4+amt*.1)):Center():diffusealpha( amt*.15 )

		end

		if beat > 132 and beat < 136 then
			taronuke_thonk_giant1:effectmagnitude( 6 + 2*(beat-132), 6 + 2*(beat-132), 0 )
			taronuke_thonk_giant2:effectmagnitude( 6 + 2*(beat-132), 6 + 2*(beat-132), 0 )
		else
			taronuke_thonk_giant1:effectmagnitude( 0,0,0 )
			taronuke_thonk_giant2:effectmagnitude( 0,0,0 )
		end

	end

	if underlay:GetChild("ColorWheel") then
		for i=1,32 do
			if underlay:GetChild("ColorWheel"):GetChild("item"..i) then
				local zm = underlay:GetChild("ColorWheel"):GetChild("item"..i):GetZoom()

				if mods_beat_enabled or mods_bob_enabled then
					underlay:GetChild("ColorWheel"):GetChild("item"..i):GetChild(""):stoptweening():x( 0 ):y( 0 ):rotationz( 0 ):skewx( 0 )

					if mods_beat_enabled then
						underlay:GetChild("ColorWheel"):GetChild("item"..i):GetChild(""):stoptweening():addy( beatBounce((1/zm)*50*((i%2)*2-1)) )
					end
					if mods_bob_enabled then
						underlay:GetChild("ColorWheel"):GetChild("item"..i):GetChild(""):stoptweening():addy( 1/zm * 128*math.sin(beat*math.pi*0.25)*((i%2)*2-1) ):rotationz( 90*beat )
					end
				end

			end
		end
	end

	if SCREENMAN:GetTopScreen():GetName() == "ScreenSelectStyle" then
		if underlay:GetChild("") then

			local k = 1
			local k2 = 1
			for i=1,10 do
				local a = underlay:GetChild("")[i]
				if a then

					for j=1,10 do
						local b = a:GetChild("")[j]

						if b then

							local id = "ScreenSelectStyleitem_"..i.."_"..j

							if not base_positions[id] then
								base_positions[id] = {x = b:GetX(), y = b:GetY()}
							end

							local zm = 1

							if j == 1 then --text item

								if mods_beat_enabled or mods_bob_enabled then
									b:stoptweening():x( base_positions[id].x ):y( base_positions[id].y + 40 ):rotationy( 0 ):rotationz( 0 ):skewx( 0 )

									if mods_beat_enabled then
										b:stoptweening():addx( beatBounce((1/zm)*32*((k2%2)*2-1)) )
									end
									if mods_bob_enabled then
										b:stoptweening():addx( 1/zm * 64*math.sin(beat*math.pi*0.25)*((k2%2)*2-1) ):rotationy( 90*beat )
									end

								end
								k2 = k2+1
							else --pad items
								if mods_beat_enabled or mods_bob_enabled then
									b:stoptweening():x( base_positions[id].x ):y( base_positions[id].y ):rotationz( 0 ):skewx( 0 )

									if mods_beat_enabled then
										b:stoptweening():addy( beatBounce((1/zm)*32*((k%2)*2-1)) )
									end
									if mods_bob_enabled then
										b:stoptweening():addy( 1/zm * 64*math.sin(beat*math.pi*0.25)*((k%2)*2-1) ):skewx( math.sin(beat*math.pi*0.5) )
									end

								end
								k = k+1
							end
						end
					end

				end
			end

		end
	end

	if SCREENMAN:GetTopScreen():GetName() == "ScreenSelectPlayMode" or SCREENMAN:GetTopScreen():GetName() == "ScreenSelectPlayMode2" then


		local radius = 0
		if beat > 64 and beat < 72 then
			radius = (beat-64)/8
		elseif beat >= 72 and beat < 88 then
			radius = 1
		elseif beat >= 88 and beat < 96 then
			radius = (96-beat)/8
		end


		local xp = radius*100*math.cos(beat*math.pi*0.25)
		local yp = 100*math.sin(beat*math.pi*0.25)

		if not base_positions["ScreenSelectPlayModeUnderlay"] then
			base_positions["ScreenSelectPlayModeUnderlay"] = {x = underlay:GetX(), y = underlay:GetY(), zoom = underlay:GetZoom()}
			ss_playmode_items["ScreenSelectPlayModeUnderlay"] = underlay
		end

		if mods_beat_enabled or mods_bob_enabled then
			if beat >= 64 and beat < 96 then
				underlay:x(base_positions["ScreenSelectPlayModeUnderlay"].x + xp):y(base_positions["ScreenSelectPlayModeUnderlay"].y + yp):rotationz(0)
			else
				underlay:x(base_positions["ScreenSelectPlayModeUnderlay"].x):y(base_positions["ScreenSelectPlayModeUnderlay"].y)
			end

			if mods_beat_enabled then
				underlay:zoom(base_positions["ScreenSelectPlayModeUnderlay"].zoom - 0.04 + math.abs(0.08*math.sin(beat*math.pi)) ):rotationz(0)
			else
				underlay:zoom(base_positions["ScreenSelectPlayModeUnderlay"].zoom)
			end
		end

		local items = {"IconChoiceCasual","IconChoiceITG","IconChoiceFA+"}
		if SCREENMAN:GetTopScreen():GetName() == "ScreenSelectPlayMode2" then
			items = {"IconChoiceRegular","IconChoiceMarathon"}
		end

		local zm = 1

		for i=1, #items do

			local b = SCREENMAN:GetTopScreen():GetChild( items[i] )
			if b then

				--menu items

				local id = "ScreenSelectPlayModeItem_"..i

				if not base_positions[id] then
					base_positions[id] = {x = b:GetX(), y = b:GetY(), zoom = b:GetZoom()}
					ss_playmode_items[id] = b
				end

				if mods_beat_enabled or mods_bob_enabled then
					b:finishtweening():x( base_positions[id].x ):y( base_positions[id].y ):rotationy( 0 ):rotationz( 0 ):skewx( 0 )

					if mods_beat_enabled then
						b:finishtweening():addx( beatBounce((1/zm)*32*((i%2)*2-1)) )
					end
					if mods_bob_enabled then
						b:finishtweening():rotationx( 90*beat ):addx(xp):addy(yp)
					end

				end

			end

		end

		--underlay

		--SM( underlay:GetChildren() )

		local items2 = {SCREENMAN:GetTopScreen():GetChild("LifeMeter"),SCREENMAN:GetTopScreen():GetChild("Cursor")}

		table.insert(items2,underlay:GetChild("")[7]) -- 77.41

		for i=1, #items2 do

			local b = items2[i]
			if b then

				local id = "ScreenSelectPlayModeItem2_"..i

				if not base_positions[id] then
					base_positions[id] = {x = b:GetX(), y = b:GetY(), zoom = b:GetZoom()}
					ss_playmode_items[id] = b
				end

				if mods_beat_enabled or mods_bob_enabled then
					b:x( base_positions[id].x ):y( base_positions[id].y ):rotationy( 0 ):rotationz( 0 ):skewx( 0 ):zoom( base_positions[id].zoom )

					if mods_beat_enabled then
						b:addx( beatBounce((1/zm)*32*((i%2)*2-1)) )
					end
					if mods_bob_enabled then
						b:rotationx( 90*beat )
					end

				end

			end

		end

		local b = underlay:GetChild("")[6] --description text
		if b then

			local id = "ScreenSelectPlayModeItemUnderlay6"

			if not base_positions[id] then
				base_positions[id] = {x = b:GetX(), y = b:GetY(), zoom = b:GetZoom()}
				ss_playmode_items[id] = b
			end

			if mods_beat_enabled or mods_bob_enabled then
				b:x( base_positions[id].x ):y( base_positions[id].y ):rotationy( 0 ):rotationz( 0 ):skewx( 0 ):zoom( base_positions[id].zoom )

				if mods_beat_enabled then
					b:addy( beatBounce((1/zm)*32*((1%2)*2-1)) )
				end
				if mods_bob_enabled then
					b:rotationz( 30*math.sin(beat*0.25*math.pi) )
				end

			end

		end

		local b = underlay:GetChild("")[8] --playfield
		if b then

			local id = "ScreenSelectPlayModeItemUnderlay8"

			if not base_positions[id] then
				base_positions[id] = {x = b:GetX(), y = b:GetY(), zoom = b:GetZoom()}
				ss_playmode_items[id] = b
			end

			if mods_beat_enabled or mods_bob_enabled then
				b:x( base_positions[id].x ):y( base_positions[id].y ):rotationy( 0 ):rotationz( 0 ):skewx( 0 ):zoom(base_positions[id].zoom)

				if mods_beat_enabled then
					b:zoom( base_positions[id].zoom + math.abs(0.5*math.sin(beat*math.pi))):rotationz( 30*math.cos(beat*math.pi) )
				end
				if mods_bob_enabled then
					b:skewx( 1*math.sin(beat*0.25*math.pi) )
				end

			end

		end





	end

	lastbeat = beat

end






local af = Def.ActorFrame{
	InitCommand=function(self) self:effectclock('music'):SetUpdateFunction( Update ) end,

	OnCommand=function(self) self:sleep(0.05):queuecommand("Thonk") end,
	ThonkCommand=function(self)

		--SM( SCREENMAN:GetTopScreen():GetName() )

		--SM( SCREENMAN:GetTopScreen():GetChildren() )

	end,

	LoadActor("thonk.png")..{
		InitCommand=function(self) taronuke_thonk_giant1 = self end,
		OnCommand=function(self) self:visible(false):scaletofit(0,0,sw/2,sh/2):Center() end,
		HideThonkMessageCommand=function(self) self:stoptweening():visible(false):stopeffect() end,
		-- ThonkFadeInMessageCommand=function(self) self:stoptweening():visible(true):stopeffect():scaletofit(0,0,sw*0.4,sh*0.4):Center():diffusealpha(0):linear(spb*32):diffusealpha(0.1):scaletofit(0,0,sw*0.5,sh*0.5):Center() end,
		GiantThonkMessageCommand=function(self) self:stoptweening():vibrate():effectmagnitude(6,6,0):diffusealpha(0.2):linear(spb*2):scaletofit(0,0,sw*1,sh*1):Center():diffusealpha(0.6):linear(spb*2):scaletofit(0,0,sw*1.5,sh*1.5):Center():diffusealpha(0) end,
	},

	Def.ActorFrameTexture {

		InitCommand = function(self)
			taronuke_thonk_aft = self
			self:SetWidth(sw)
				:SetHeight(sh)
				:EnableAlphaBuffer( false )
				:Create()
		end,

		Def.ActorProxy{
			OnCommand=function(self) self:queuecommand("GetProxy") end,
			GetProxyCommand=function(self) if SCREENMAN:GetTopScreen():GetChild("Underlay") then self:SetTarget( SCREENMAN:GetTopScreen():GetChild("Underlay") ) end end,
		},
		Def.ActorProxy{
			OnCommand=function(self) self:queuecommand("GetProxy") end,
			GetProxyCommand=function(self) if SCREENMAN:GetTopScreen():GetChild("MemoryCardDisplayP1") then self:SetTarget( SCREENMAN:GetTopScreen():GetChild("MemoryCardDisplayP1") ) end end,
		},
		Def.ActorProxy{
			OnCommand=function(self) self:queuecommand("GetProxy") end,
			GetProxyCommand=function(self) if SCREENMAN:GetTopScreen():GetChild("MemoryCardDisplayP2") then self:SetTarget( SCREENMAN:GetTopScreen():GetChild("MemoryCardDisplayP2") ) end end,
		},

		LoadActor("thonk.png")..{
			InitCommand=function(self) taronuke_thonk_giant2 = self end,
			OnCommand=function(self) self:visible(false):scaletofit(0,0,sw/2,sh/2):Center() end,
			HideThonkMessageCommand=function(self) self:stoptweening():visible(false):stopeffect() end,
			-- ThonkFadeInMessageCommand=function(self) self:stoptweening():visible(true):stopeffect():scaletofit(0,0,sw*.4,sh*.4):Center():diffusealpha(0):linear(spb*32):diffusealpha(0.2):scaletofit(0,0,sw*0.5,sh*0.5):Center() end,
			GiantThonkMessageCommand=function(self) self:stoptweening():vibrate():effectmagnitude(6,6,0):diffusealpha(0.2):linear(spb*2):scaletofit(0,0,sw*1,sh*1):Center():diffusealpha(0.6):linear(spb*2):scaletofit(0,0,sw*1.5,sh*1.5):Center():diffusealpha(0) end,
		},

		Def.Sprite{
			OnCommand=function(self)
				self:SetTexture( taronuke_thonk_aft:GetTexture() ):Center():zoom(1.05):diffusealpha(0):blend(1)
			end,
			PulseMessageCommand=function(self) self:stoptweening():zoom(1.05):diffusealpha(pulse_strength):linear(spb):zoom(1):diffusealpha(0) end,
			GiantThonkMessageCommand=function(self) self:stoptweening():zoom(1):diffusealpha(0):linear(spb*2):zoom(1.1):diffusealpha(1):linear(spb*2):zoom(1):diffusealpha(0) end,

		},

		Def.Sprite{
			OnCommand=function(self)
				self:SetTexture( taronuke_thonk_aft:GetTexture() ):Center():zoom(1.05):diffusealpha(0):blend(1)
			end,
			PulseMessageCommand=function(self) self:stoptweening():zoom(1.05):diffusealpha(pulse_strength):linear(spb):zoom(1):diffusealpha(0) end,
			GiantThonkMessageCommand=function(self) self:stoptweening():zoom(1):diffusealpha(0):linear(spb*2):zoom(1.1):diffusealpha(1):linear(spb*2):zoom(1):diffusealpha(0) end,
		},

	},

	Def.Sprite{
		OnCommand=function(self)
			self:SetTexture( taronuke_thonk_aft:GetTexture() ):Center():zoom(1.05):diffusealpha(0):blend(1)
		end,
		PulseMessageCommand=function(self) self:stoptweening():zoom(1.05):diffusealpha(pulse_strength):linear(spb):zoom(1):diffusealpha(0) end,
		GiantThonkMessageCommand=function(self) self:stoptweening():zoom(1):diffusealpha(0):linear(spb*2):zoom(1.1):diffusealpha(1):linear(spb*2):zoom(1):diffusealpha(0) end,
	},

}

for i=1,20 do

	af[#af+1] = Def.ActorFrame{
		OnCommand=function(self)
			self:visible(false)
			table.insert(splash_table,self)
		end,
		HideCommand=function(self) self:visible(false) end,
		LoadActor("splash 4x3.png")..{
			InitCommand=function(self)
				self:animate(false)
			end
		}
	}

end

return af