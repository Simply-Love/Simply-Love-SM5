local args = ...
local row = args[1]
local col = args[2]
local y_offset = args[3]

local af = Def.ActorFrame{
	Name="SongWheelShared",
	InitCommand=function(self) self:zoom(0) end
}


-----------------------------------------------------------------
-- text

af[#af+1] = Def.ActorFrame{
	Name="CurrentSongInfoAF",
	InitCommand=function(self) self:diffusealpha(0) end,
	OnCommand=function(self) self:sleep(0.15):linear(0.15):diffusealpha(1) end,

	SwitchFocusToGroupsMessageCommand=function(self)
		self:visible(false):runcommandsonleaves(function(leaf) if leaf.settext then leaf:settext("") end end)
	end,
	CloseThisFolderHasFocusMessageCommand=function(self)
		local song = GAMESTATE:GetCurrentSong()
		local groupName = song and song:GetGroupName() or ''
		self:runcommandsonleaves(function(leaf) if leaf.settext then leaf:settext(groupName) end end)
	end,
	SwitchFocusToSongsMessageCommand=function(self)
		self:visible(true):linear(0.2):zoom(0.8)
		self:runcommandsonleaves(function(leaf) leaf:diffuse(1,1,1,1) end)
	end,
	SwitchFocusToSingleSongMessageCommand=function(self)
		self:linear(0.2):zoom(0.8)
		self:runcommandsonleaves(function(leaf) leaf:diffuse(1,1,1,1) end)
	end,

	-- main title
	Def.BitmapText{
		Font="Common Normal",
		Name="Title",
		InitCommand=function(self) self:zoom(0.8):diffuse(Color.White):maxwidth(300) end,
		CurrentSongChangedMessageCommand=function(self, params)
			if params.song then
				self:settext( params.song:GetDisplayMainTitle() .. " " .. params.song:GetDisplaySubTitle() )
			end
		end,
	},
}


return af