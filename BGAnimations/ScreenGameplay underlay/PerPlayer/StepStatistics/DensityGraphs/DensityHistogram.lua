local graph = ...
local player = graph.player
local DensityTable = graph.density_table
local PeakDensity = graph.peak_density
local width, height = graph.width, graph.height
local scaling_factor = graph.scaling_factor

local Song = GAMESTATE:GetCurrentSong()
local MusicLengthSeconds = Song:MusicLengthSeconds()
local TimingData = Song:GetTimingData()

if DensityTable and #DensityTable > 1 then

	local af = Def.ActorFrame{
		InitCommand=function(self)
			self:x( -_screen.w/4 )
			self:zoom(0.5)	
		end,
		
		-- Def.Sprite{
		-- 	Name="HistogramSprite",
		-- 	OnCommand=function(self)
		-- 		self:xy(GetNotefieldX(player) - GetNotefieldWidth()/2, _screen.cy+100)
		-- 			:align(0,1)
		-- 			:zoom(1/scaling_factor)
		-- 			:MaskSource()
		-- 	end
		-- }
	}


	local verts = {}
	local x, y
	local w = width/MusicLengthSeconds
	-- local w = width/#DensityTable

	for i, notecount in ipairs(DensityTable) do
		x = TimingData:GetElapsedTimeFromBeat(i*4) * w
		y = -1 * scale(notecount, 0, PeakDensity, 0, height)

		verts[#verts+1] = {{x, 0, 0}, {1,1,1,1}}
		verts[#verts+1] = {{x, y, 0}, {1,1,1,1}}
	end

	
	local amv = Def.ActorMultiVertex{		
		Name="DensityGraph_AMV",
		InitCommand=function(self)
			self:SetDrawState{Mode="DrawMode_QuadStrip"}
				:SetVertices(verts)	
				:align(0, 0)
				:y(height)
		end
	}

	-- local aft = Def.ActorFrameTexture{
	-- 	InitCommand=function(self)
	-- 		self:SetWidth( width ):SetHeight( height )
	-- 			:EnableAlphaBuffer(true)
	-- 			:Create()
	-- 	end,
	-- 	OnCommand=function(self)
	-- 		self:GetParent():GetChild("HistogramSprite"):SetTexture( self:GetTexture() )
	-- 		self:visible(true):Draw():visible(false)
	-- 	end,
	--
	-- 	Def.ActorMultiVertex{
	-- 		Name="DensityGraph_AMV",
	-- 		InitCommand=function(self)
	-- 			self:SetDrawState{Mode="DrawMode_QuadStrip"}
	-- 				:SetVertices(verts)
	-- 				:align(0, 0)
	-- 				:y(height)
	-- 		end
	-- 	}
	-- }
	--
	--
	-- af[#af+1] = aft
	af[#af+1] = amv

	return af
end