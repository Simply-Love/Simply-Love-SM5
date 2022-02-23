local t = Def.ActorFrame {
	InitCommand=function(self)
	self:draworder(150)
	self:visible(false)
	MESSAGEMAN:Broadcast("SortMenuIsClosed")
	end,
	
	--- Let's the songwheel input know if it's Open/Closed so it can stop input.
	ToggleSortMenuMessageCommand=function(self)
		if self:GetVisible() then
			self:visible(false)
			MESSAGEMAN:Broadcast("SortMenuIsClosed")
		else
			self:visible(true)
			MESSAGEMAN:Broadcast("SortMenuIsOpen")
		end
	end,
	
	-- The menu skeleton with no moving parts (jk the YES/NO buttons exist here)
	LoadActor("./menu.lua"),
	-- Thee cursor
	LoadActor("./cursor.lua"),
	-- Where all the sorts-filters exist
	LoadActor("./Sorts-Filters.lua"),
	-- Updates the music wheel only when needed
	LoadActor("./UpdateSongWheel.lua"),
	-- Runs tasks when selected in the sort menu.
	LoadActor("./Menu-Functions.lua"),
}

return t