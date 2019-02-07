local groups_wheel = setmetatable({}, sick_wheel_mt)
local group_names = SONGMAN:GetSongGroupNames()
local rows_visible = 11

local group_row_mt = LoadActor("./GroupRowMT.lua", {rows_visible=rows_visible})

local af = Def.ActorFrame{
	InitCommand=function(self)
		groups_wheel.focus_pos = math.ceil(rows_visible/2)
		groups_wheel:set_info_set(group_names, 1)
	end,
	OnCommand=function(self)
		SCREENMAN:GetTopScreen():AddInputCallback( LoadActor("./InputHandler.lua", {af=self, wheel=groups_wheel}) )
		self:GetChild("CasualModeGroupsWheel"):z(-1000)
	end,

	groups_wheel:create_actors( "CasualModeGroupsWheel", rows_visible + 2, group_row_mt, _screen.cx, _screen.cy ),
}


return af