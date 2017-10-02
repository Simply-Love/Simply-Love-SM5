local player = ...

local Song = GAMESTATE:GetCurrentSong()
local Steps = GAMESTATE:GetCurrentSteps(player)
local StepsType = ToEnumShortString( Steps:GetStepsType() ):gsub("_", "-"):lower()
local Difficulty = ToEnumShortString( Steps:GetDifficulty() )

local PeakNPS, NPSperMeasure = GetNPSperMeasure(Song, StepsType, Difficulty)

if NPSperMeasure and #NPSperMeasure > 1 then

	local width = GetNotefieldWidth(player)*1.2
	local height = GetNotefieldWidth(player)/2.25

	local LifeMeter, life_verts = nil, {}
	local TimingData = Song:GetTimingData()

	-- Don't use Song:MusicLengthSeconds() because it includes time
	-- at the beginning before beat 0 has occurred
	local FirstSecond =  Song:GetFirstSecond()
	local TotalSeconds = Song:GetLastSecond() - FirstSecond

	local verts = {}
	local x, y
	local w = width/TotalSeconds

	for i, nps in ipairs(NPSperMeasure) do
		x = TimingData:GetElapsedTimeFromBeat(i*4) * w
		y = -1 * scale(nps, 0, PeakNPS, 0, height)

		verts[#verts+1] = {{x, 0, 0}, {1,1,1,1}}
		verts[#verts+1] = {{x, y, 0}, {1,1,1,1}}
	end


	local af = Def.ActorFrame{
		InitCommand=function(self)
			self:xy( WideScale(-160, -214), 48 )
				:queuecommand("Sample")
		end,
		OnCommand=function(self)
			LifeMeter = SCREENMAN:GetTopScreen():GetChild("Life"..ToEnumShortString(player))
		end,
	}

	local text = Def.BitmapText{
		Font="_miso",
		Text=ScreenString("PeakNPS") .. ": " .. round(PeakNPS,2),
		InitCommand=function(self)
			self:x( _screen.w/2 - self:GetWidth()/2 - 2 + WideScale(0,-60) )
				:y( -self:GetHeight()/2 - 2 )
				:zoom(0.9)
		end
	}

	local bg = Def.Quad{
		InitCommand=function(self)
			self:zoomto(_screen.w/2,height)
				:align(0,0)
				:diffuse(color("#1E282F"))
		end
	}

	local amv = Def.ActorMultiVertex{
		Name="DensityGraph_AMV",
		InitCommand=function(self)
			self:SetDrawState{Mode="DrawMode_QuadStrip"}
				:SetVertices(verts)
				:align(0, 0)
				:x( WideScale(0,60) )
				:y(height)
				:MaskSource()
		end
	}

	local gradient = Def.Sprite{
		Texture="./NPS-gradient.png",
		InitCommand=function(self)
			self:setsize(width, height)
				:align(0,0)
				:x( WideScale(0,60) )
				:ztestmode("ZTestMode_WriteOnFail")

		end
	}

	local lifeline = Def.ActorMultiVertex{
		Name="LifeLine_AMV",
		InitCommand=function(self)
			self:SetDrawState{Mode="DrawMode_LineStrip"}
				:SetLineWidth(2)
				:align(0, 0)
				:x( WideScale(0,60) )
		end,
		SampleCommand=function(self)
			if GAMESTATE:GetCurMusicSeconds() > 0 then
				x = scale( GAMESTATE:GetCurMusicSeconds(), 0, TotalSeconds, 0, width )
				y = scale( LifeMeter:GetLife(), 1, 0, 0, height )

				life_verts[#life_verts+1] = {{x, y, 0}, {1,1,1,1}}
				self:SetVertices(life_verts)
			end

			-- sample the player's LifeMeter every 1/3 second
			-- TODO: maybe replace this later with something more sensible?
			self:sleep(0.333):queuecommand("Sample")
		end
	}

	af[#af+1] = text
	af[#af+1] = bg
	af[#af+1] = amv
	af[#af+1] = gradient
	af[#af+1] = lifeline

	return af
end
