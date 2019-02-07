-- quant	factor	diff
-- 4		1		1 unit
-- 8		2		1 unit
-- 12		3		1 unit
-- 16		4		1 unit
-- 24		6		2 units
-- 32		8		2 units
-- 48		12		4 units
-- 64		16		4 units
-- 96		24		8 units
-- 128		32		8 units
-- -------------------------
-- 					32 units

local args = ...
local player = args.player
local p = ToEnumShortString(player)

local height = args.height
local width = args.width
local PeakDensity = args.peak_density

local colors = {
	{
		color = color("#ff2b85"),
		quantization = 1,
	},
	{
		color = color("#00c6e3"),
		quantization = 2,
	},
	{
		color = color("#6b2fe9"),
		quantization = 3,
	},
	{
		color = color("#72ed06"),
		quantization = 4,
	},
	{
		color = color("#6b2fe9"),
		quantization = 6,
	},
	{
		color = color("#ecb703"),
		quantization = 8,
	},
	{
		color = color("#6b2fe9"),
		quantization = 12,
	},
	{
		color = color("#1bd999"),
		quantization = 16,
	},
	{
		color = color("#6b2fe9"),
		quantization = 24,
	},
	{
		color = color("#6b2fe9"),	
		quantization = 32,
	},
}

local aft = Def.ActorFrameTexture{
	InitCommand=function(self)
		self:SetWidth( width ):SetHeight( height )
			:Create()
	end,
	OnCommand=function(self)
		self:GetParent():GetChild("GradientSprite_"..p):SetTexture( self:GetTexture() )
		self:visible(true):Draw():visible(false)
	end
}
local af = Def.ActorFrame{}

for i,section in ipairs(colors) do
	if section.quantization * 4 <= PeakDensity then
		local next_quant = colors[i+1] and colors[i+1].quantization or colors[#colors].quantization
		local prev_quant = colors[i-1] and colors[i-1].quantization or 0
		local difference = section.quantization - prev_quant

		for t=1,difference do
			af[#af+1] = Def.Quad{
				InitCommand=function(self)
					self:y(-section.quantization + t)
						:diffuse(section.color)
						:draworder(1)
				end
			}
		end

		if player == PLAYER_1 then
		if colors[i+1].quantization*4 <= PeakDensity then
			af[#af+1] = Def.Quad{
				InitCommand=function(self)
					self:y(-1 * (next_quant - (next_quant - section.quantization)))
						:diffusebottomedge(section.color)
						:diffusetopedge(colors[i+1].color)
						:draworder(2)
						:align(0.5,0)
						
						if player == PLAYER_1 then
							self:zoomtoheight(difference*1.65)
								:fadetop(0.2):fadebottom(0.2)
						else
							self:zoomtoheight(difference*1)
						end
				end
			}
		end
		end
		
		af.InitCommand=function(self) 
			self:zoomto(width, height/section.quantization)
				:y(height - height/section.quantization)
				:align(0, 0)
		end
	else
		break
	end
end

aft[#aft+1] = af

return aft