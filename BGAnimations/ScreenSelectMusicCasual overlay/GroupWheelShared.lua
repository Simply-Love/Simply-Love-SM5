local args = ...
local row = args[1]
local col = args[2]
local group_info = args[3]

local af = Def.ActorFrame{ Name="GroupWheelShared" }

af[#af+1] = Def.Quad{
	InitCommand=cmd(zoomto, _screen.w, _screen.h-200; diffuse, 0,0,0,0.9; cropbottom,1),
	OnCommand=cmd(xy, _screen.cx, _screen.cy; finishtweening; accelerate, 0.2; cropbottom,1),
	SwitchFocusToGroupsMessageCommand=cmd(sleep,0.3; smooth,0.3; cropbottom,0),
	SwitchFocusToSongsMessageCommand=cmd(cropbottom,1),
	SwitchFocusToSingleSongMessageCommand=cmd(cropbottom,1),
}

-----------------------------------------------------------------
-- text

af[#af+1] = Def.ActorFrame{
	Name="CurrentGroupInfoAF",
	InitCommand=function(self) self:xy( _screen.cx, _screen.cy ):visible(false) end,
	SwitchFocusToGroupsMessageCommand=function(self) self:visible(true):sleep(0.4):linear(0.15):diffusealpha(1) end,
	SwitchFocusToSongsMessageCommand=function(self) self:visible(false):diffusealpha(0) end,
	SwitchFocusToSingleSongMessageCommand=function(self) self:visible(false):diffusealpha(0) end,

	-- unique songs
	Def.BitmapText{
		Font="_miso",
		InitCommand=function(self)
			self:zoom(1.1):diffuse(Color.White):xy(0,15):maxwidth(300)
		end,
		CurrentGroupChangedMessageCommand=function(self, params)
			if params.group then
				self:settext( group_info[params.group].num_songs .. " Unique Songs" )
			else
				self:self("")
			end
		end,
	},

	-- artists
	Def.BitmapText{
		Font="_miso",
		InitCommand=function(self)
			self:zoom(0.75):diffuse(Color.White):xy(-260, 30):horizalign(left):vertalign(top)
		end,
		CurrentGroupChangedMessageCommand=function(self, params)
			if params.group then
				self:settext( "ARTISTS:\n" .. group_info[params.group].artists )
			else
				self:self("")
			end
		end,
	},

	-- genres
	Def.BitmapText{
		Font="_miso",
		InitCommand=function(self)
			self:zoom(0.75):diffuse(Color.White):xy(-60, 30):horizalign(left):vertalign(top)
		end,
		CurrentGroupChangedMessageCommand=function(self, params)
			if params.group then
				self:settext( "GENRES:\n" .. group_info[params.group].genres )
			else
				self:self("")
			end
		end,
	},

	-- steps
	Def.BitmapText{
		Font="_miso",
		InitCommand=function(self)
			self:zoom(0.75):diffuse(Color.White):xy(130, 30):horizalign(left):vertalign(top)
		end,
		CurrentGroupChangedMessageCommand=function(self, params)
			if params.group then
				self:settext( "STEPCHARTS:\n" ..group_info[params.group].charts )
			else
				self:self("")
			end
		end,
	},

}

return af