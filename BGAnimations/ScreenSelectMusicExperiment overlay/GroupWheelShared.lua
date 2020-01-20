-----------------------------------------------------------------
-- Info on the current group

local args = ...
local row = args[1]
local col = args[2]
local group_info = args[3]

if group_info == nil then
	return Def.Actor{ InitCommand=function(self) self:visible(false) end }
end
-----------------------------------------------------------------
local BarGraph = LoadActor("./BarGraph.lua", group_info)
local initializeBarGraph = CreateBarGraph(250,100)..{
	OnCommand=function(self)
		self:xy(400,400)
	end
}
----------------------------------------------------------------------

local af = Def.ActorFrame{ 
	Name="GroupWheelShared",
	UpdateGroupInfoMessageCommand=function(self, params) 
		group_info = params[1]
		MESSAGEMAN:Broadcast("CurrentGroupChanged", {group=params[2]})
	end,
}


af[#af+1] = Def.Quad{
	InitCommand=function(self) self:zoomto(_screen.w, _screen.h-200):xy(_screen.cx, _screen.cy+60):diffuse(0,0,0,0.5):cropbottom(1) end,
	SwitchFocusToGroupsMessageCommand=function(self) self:sleep(0.3):smooth(0.3):cropbottom(0) end,
	SwitchFocusToSongsMessageCommand=function(self) self:cropbottom(1) end,
	SwitchFocusToSingleSongMessageCommand=function(self) self:cropbottom(1) end,
}

-----------------------------------------------------------------
-- text

af[#af+1] = Def.ActorFrame{
	Name="CurrentGroupInfoAF",
	InitCommand=function(self) self:playcommand("SetGroupWheel"):visible(false) end,
	SwitchFocusToGroupsMessageCommand=function(self) self:visible(true):playcommand("SetGroupWheel"):diffusealpha(0):sleep(0.4):linear(0.15):diffusealpha(1) end,
	SwitchFocusToSongsMessageCommand=function(self) self:visible(false):diffusealpha(0) end,
	SwitchFocusToSingleSongMessageCommand=function(self) self:visible(false):diffusealpha(0) end,
	CloseThisFolderHasFocusMessageCommand=function(self) self:visible(true):playcommand("SetSongWheel"):sleep(0.1):linear(0.1):diffusealpha(1) end,
	--something outside of this theme also broadcasts currentsongchanged but we only want it if it's from SongMT. SongMT also includes a song param
	--so by checking for that we can tell who broadcasted 
	CurrentSongChangedMessageCommand = function(self, params) if (params.song) then self:visible(false):playcommand("SetGroupWheel"):diffusealpha(0) end end,
	SetSongWheelCommand=function(self) self:xy( _screen.cx, _screen.cy+30 ) end,
	SetGroupWheelCommand=function(self) self:xy( _screen.cx, _screen.cy+60 ) end,
	
	-- Group Label
	LoadFont("_wendy small")..{
		InitCommand=function(self)
			self:settext( "GROUP " ):zoom(.5):horizalign(right):xy(-315,-60)
		end,
		OnCommand=function(self) self:diffuse(0.75,0.75,0.75,1) end
	},
	-- Group Text
	Def.BitmapText{
		Font="Common Normal",
		Name="Title",
		InitCommand=function(self) self:zoom(1.4):diffuse(Color.White):horizalign(left):xy(-315,-60):maxwidth(300) end,
		CurrentGroupChangedMessageCommand=function(self, params)
			self:settext( GetGroupDisplayName(SL.Global.CurrentGroup))
		end,
	},
	-- Sort Label
	LoadFont("_wendy small")..{
		InitCommand=function(self)
			self:settext( "Sort " ):zoom(.35):horizalign(right):xy(-350,-30)
		end,
		OnCommand=function(self) self:diffuse(0.75,0.75,0.75,1) end
	},
	-- Sort Text
	Def.BitmapText{
		Font="Common Normal",
		Name="Title",
		InitCommand=function(self) self:zoom(1):diffuse(Color.White):horizalign(left):xy(-350,-30):maxwidth(300) end,
		CurrentGroupChangedMessageCommand=function(self, params)
			self:settext( SL.Global.GroupType )
		end,
	},
	-- Songs Label
	Def.BitmapText{
		Font="_wendy small",
		InitCommand=function(self)
			self:settext("Songs "):zoom(.35):horizalign(right):xy(-340,-5):maxwidth(300)
		end,
		OnCommand=function(self) self:diffuse(0.75,0.75,0.75,1) end
	},
	-- Songs text
	Def.BitmapText{
		Font="_wendy small",
		InitCommand=function(self)
			self:zoom(1):diffuse(Color.White):xy(-395,45):vertalign(bottom):horizalign(left):maxwidth(300)
		end,
		CurrentGroupChangedMessageCommand=function(self, params)
			if group_info[params.group] then
				self:settext( group_info[params.group].num_songs)
			end
		end,
	},
	-- Stepcharts Label
	Def.BitmapText{
		Font="_wendy small",
		InitCommand=function(self)
			self:settext("Charts "):zoom(.35):horizalign(left):xy(-275,-5):maxwidth(300)
		end,
		OnCommand=function(self) self:diffuse(0.75,0.75,0.75,1) end
	},
	-- Stepcharts text
	Def.BitmapText{
		Font="_wendy small",
		InitCommand=function(self)
			self:zoom(1):diffuse(Color.White):xy(-275,45):vertalign(bottom):horizalign(left):maxwidth(300)
		end,
		CurrentGroupChangedMessageCommand=function(self, params)
			if group_info[params.group] then
				local total = 0
				for _,item in pairs(group_info[params.group]['Level']) do
					total = total + item.num_songs
				end
				if total > 1000 then total = "1000+" end
				self:settext( total )
			end
		end,
	},
	-- Filtered Songs Label
	Def.BitmapText{
		Font="_wendy small",
		InitCommand=function(self)
			self:settext("Filtered"):zoom(.25):horizalign(right):xy(-395,60):maxwidth(300):horizalign(left)
		end,
		OnCommand=function(self) self:diffuse(0.75,0.75,0.75,1) end
	},
	-- Filtered Songs text
	Def.BitmapText{
		Font="_wendy small",
		InitCommand=function(self)
			self:zoom(0.75):diffuse(Color.White):xy(-395, 70):vertalign(top):horizalign(left)
		end,
		CurrentGroupChangedMessageCommand=function(self, params)
			if group_info[params.group] then
				local plural = "songs"
				local filteredSongs = #GetSongList(params.group) - group_info[params.group].num_songs
				self:settext( filteredSongs )
			end
		end,
	},
	-- Filtered Charts Label
	Def.BitmapText{
		Font="_wendy small",
		InitCommand=function(self)
			self:settext("Filtered"):zoom(.25):horizalign(right):xy(-275,60):maxwidth(300):horizalign(left)
		end,
		OnCommand=function(self) self:diffuse(0.75,0.75,0.75,1) end
	},
	-- Filtered Charts text
	Def.BitmapText{
		Font="_wendy small",
		InitCommand=function(self)
			self:zoom(0.75):diffuse(Color.White):xy(-275, 70):vertalign(top):horizalign(left)
		end,
		CurrentGroupChangedMessageCommand=function(self, params)
			if group_info[params.group] then
				local plural = "songs"
				local filteredSongs = #GetSongList(params.group) - group_info[params.group].num_songs
				self:settext( filteredSongs )
			end
		end,
	},
	-- Complete Charts Label
	Def.BitmapText{
		Font="_wendy small",
		InitCommand=function(self)
			self:settext("Complete"):zoom(.25):horizalign(right):xy(-170,60):maxwidth(300):horizalign(left)
		end,
		OnCommand=function(self) self:diffuse(0.75,0.75,0.75,1) end
	},
	-- Complete Charts text
	Def.BitmapText{
		Font="_wendy small",
		InitCommand=function(self)
			self:zoom(0.75):diffuse(Color.White):xy(-170, 70):vertalign(top):horizalign(left)
		end,
		CurrentGroupChangedMessageCommand=function(self, params)
			if group_info[params.group] then
				local num_passed, num_charts = 0, 0
				for k,v in pairs(group_info[params.group]["PassedLevel"]) do
					num_passed = num_passed + v.num_songs
				end
				self:settext( num_passed )
			end
		end,
	},
	-- Stepcharts text
	Def.BitmapText{
		Font="Common Normal",
		InitCommand=function(self)
			self:zoom(0.75):diffuse(Color.White):xy(-170, -35):horizalign(left):vertalign(top)
		end,
		CurrentGroupChangedMessageCommand=function(self, params)
			if group_info[params.group] then
				local num_charts,num_passed,median, mode = 0,0,{}
				for k,v in pairs(group_info[params.group]["Level"]) do
					for i = 1,v.num_songs do
						median[#median+1] = v.difficulty
					end
					num_charts = num_charts + v.num_songs
					if v.num_songs == group_info[params.group].max_num then
						if mode then mode = mode..","..v.difficulty
						else mode = v.difficulty end
					end
				end
				--if there's only one song in the group then math.floor(#median/2) will give us 0 which isn't an index.
				--add dummy elements to the start and end so there's at least 3 which gives an index of 1
				table.insert(median,1,1)
				table.insert(median,1)
				for k,v in pairs(group_info[params.group]["PassedLevel"]) do
					num_passed = num_passed + v.num_songs
				end
				local toPrint = "MODE: Level "..mode.." ("..group_info[params.group].max_num.." charts)\n"
				toPrint = toPrint.."MEDIAN: "..median[math.floor(#median/2)].."\n"
				toPrint = toPrint.."PERCENT COMPLETE: "..math.floor((num_passed/num_charts)*10000/100).."%"
				self:settext( toPrint )
			end
		end,
	},
	-- filters
	Def.BitmapText{ --TODO make this pretty
		Font="Common Normal",
		InitCommand=function(self)
			self:zoom(0.75):diffuse(Color.White):xy(275, -35):horizalign(left):vertalign(top)
		end,
		CurrentGroupChangedMessageCommand=function(self)
			self:visible(true):settext(GetActiveFiltersString())
		end,
		SetGroupWheelCommand=function(self)
			self:visible(true):settext(GetActiveFiltersString())
		end,
		CloseThisFolderHasFocusMessageCommand=function(self) self:visible(false) end
	},
}

af[#af+1] = initializeBarGraph

return af