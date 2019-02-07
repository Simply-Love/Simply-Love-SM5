local graph = ...
local player = graph.player
local height = graph.height
local width = graph.width
local PeakDensity = graph.peak_density
local DensityTable = graph.density_table
local scaling_factor = graph.scaling_factor
local difficulty = GAMESTATE:GetCurrentSteps(player):GetDifficulty()
local song_position = GAMESTATE:GetPlayerState(player):GetSongPosition()
local song_beat, song_percent = 0,0

local update = function(af, delta)
	song_beat = song_position:GetSongBeat()
	song_percent = (song_beat/8)/#DensityTable
	af:queuecommand("Crop")
end


local af = Def.ActorFrame{
	InitCommand=function(self)
		self:SetUpdateFunction(update)
	end,
	OnCommand=function(self)
		self:xy(GetNotefieldX(player) - GetNotefieldWidth()/2, _screen.cy+100)
			:ztestmode("ZTestMode_WriteOnFail")
	end,
		
	Def.Sprite{ 
		Name="GradientSprite",
		InitCommand=function(self)
			self:zoom(1/scaling_factor)
				:align(0,1)
		end
	},
	
	
	Def.Quad{
		Name="ProgressQuad",
		InitCommand=function(self)
			self:ztestmode("ZTestMode_WriteOnFail")
				:zoomto(width, height)
				:align(0,1)
				:diffuse(0,0,0,0.75)
				:cropright(1)
		end,
		CropCommand=function(self)
			self:cropright(1-song_percent)
		end
	},
	
	
	
	
	Def.ActorFrameTexture{
		InitCommand=function(self)
			self:SetWidth( width ):SetHeight( height )
				:EnableAlphaBuffer(true)
				:Create():visible(false)
		end,
		OnCommand=function(self)
			self:GetParent():GetChild("GradientSprite"):SetTexture( self:GetTexture() )
			self:visible(true):Draw():visible(false)
		end,


		-- color
		Def.Quad{
			InitCommand=function(self)				
				self:zoomto(width, height)
					:align(0,0)
					:diffuse(DifficultyColor(difficulty))
			end
		},
	
		-- black overlay, transparent on bottom edge
		Def.Quad{
			InitCommand=function(self)
				self:zoomto(width, height)
					:align(0,0.45)
					:diffuse( Color.Black )
					:fadebottom(1)
			end
		}
	}	
}

return af