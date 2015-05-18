local pn= ...
local life= -1
-- life_use_width is the fraction of the available width to use.
-- The main OnCommand will find the main actor for the player and center the
-- life bar on it, then the available width is the distance to the nearest
-- edge.
local life_use_width= 1
-- life_blank_percent is the fraction of the width to leave blank in the center
local life_blank_percent= .8
-- full_width and surround_mode exist to allow porting this life meter to a
-- non-surround mode.
-- An appropriate x pos will have to be used if it's in non-surround mode.
local full_width= 24
local surround_mode= true
local edge_align= left
local edge_width= 0
local xs= false
local function calc_edge_width()
	edge_width= full_width * ((1 - life_blank_percent) * .5)
	if edge_width < 0 then edge_align= right end
	xs= {full_width * -.5, full_width * .5}
end
calc_edge_width()
local gec= SL[ToEnumShortString(pn)].LifeColorChoices
local full_outer= color(SL.Colors[gec[1]])
local full_inner= color(SL.Colors[gec[2]])
local empty_outer= color(SL.Colors[gec[3]])
local empty_inner= color(SL.Colors[gec[4]])
-- Adding configurable alpha channels for the colors is left as an exercise.
-- Follow the example of the LifeColorChoice function so you don't write the
-- same code four times.
full_inner[4]= 0
empty_inner[4]= 0

-- The amount of time to take to reach the new life value.
local reach_new_time= .1

local parts= {}
local zooms= {1, -1}
local container= false
local frame_args= {
	InitCommand= function(self)
		container= self
		self:xy(0, _screen.h)
	end,
	OnCommand= function(self)
		if not surround_mode then return end
		local plactor= SCREENMAN:GetTopScreen():GetChild(
			"Player"..ToEnumShortString(pn))
		local plax= plactor:GetX()
		container:x(plax)
		local left_dist= plax
		local right_dist= _screen.w - plax
		local use_dist= math.min(left_dist, right_dist)
		full_width= use_dist * 2 * life_use_width
		calc_edge_width()
		for i, part in ipairs(parts) do
			part:x(xs[i]):playcommand("RealignWidth")
		end
	end,
	LifeChangedMessageCommand= function(self, param)
		if param.Player == pn then
			local goal_life= param.LifeMeter:GetLife()
			if goal_life == life then return end
			life= goal_life
			local curr_inner= lerp_color(life, empty_inner, full_inner)
			local curr_outer= lerp_color(life, empty_outer, full_outer)
			for i, part in ipairs(parts) do
				part:stoptweening():linear(reach_new_time):zoomy(life)
					:diffuseleftedge(curr_outer):diffuserightedge(curr_inner)
			end
		end
	end
}
for i, qx in ipairs(xs) do
	frame_args[#frame_args+1]= Def.Quad{
		InitCommand= function(self)
			parts[#parts+1]= self
			self:xy(qx, 0):vertalign(bottom)
				:zoomx(zooms[i]):zoomy(0):playcommand("RealignWidth")
		end,
		RealignWidthCommand= function(self)
			self:horizalign(edge_align):setsize(edge_width, _screen.h)
		end
	}
end
return Def.ActorFrame(frame_args)
