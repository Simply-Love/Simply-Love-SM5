local num_items = THEME:GetMetric("MusicWheel", "NumWheelItems")
-- subtract 2 from the total number of MusicWheelItems
-- one MusicWheelItem will be offsceen above, one will be offscreen below
local num_visible_items = num_items - 2

local item_width = _screen.w / 2.125

return Def.ActorFrame{
	-- the MusicWheel is centered via metrics under [ScreenSelectMusic]; offset by a slight amount to the right here
	InitCommand=function(self) self:x(WideScale(28,33)) end,

	Def.Quad{
		InitCommand=function(self) 
			self:horizalign(left):diffuse(color("#000000")):zoomto(item_width, _screen.h/num_visible_items)
			if ThemePrefs.Get("VisualStyle") == "Technique" then
				self:diffusealpha(0.5)
			end
		end
	},
	Def.Quad{
		InitCommand=function(self) 
			self:horizalign(left):diffuse(color("#4c565d")):zoomto(item_width, _screen.h/num_visible_items - 1)
			if ThemePrefs.Get("VisualStyle") == "Technique" then
				self:diffusealpha(0.5)
			end
		end
	},
	Def.ActorFrame{
		Name="FolderStack",
		InitCommand=function(self)
			self:x(-3)
		end,
		SetCommand=function(self, params)
			local is_parent = params and params.IsParentSection
			self:GetChild("FolderBack"):visible(is_parent)
			self:GetChild("FolderFront"):visible(is_parent)
			self:GetChild("FolderMid"):visible(true):diffuse(params.Color)
			if not is_parent and params.ParentSection ~= "" then
				self:x(8)
			else
				self:x(-3)
			end
		end,
		Def.Sprite{
			Name="FolderBack",
			Texture=THEME:GetPathG("", "folder-solid.png"),
			InitCommand=function(self)
				self:horizalign(left):zoom(0.175)
				self:x(-4 + self:GetWidth()*self:GetZoom() - 8, -4)
					self:diffuse(color("#5c6972"))
			end,
			SetCommand=function(self, params)
				local is_parent = params and params.IsParentSection
				self:diffuse(color("#5c6972"))
			end
		},
		Def.Sprite{
			Name="FolderMid",
			Texture=THEME:GetPathG("", "folder-solid.png"),
			InitCommand=function(self)
				self:horizalign(left):zoom(0.175)
				self:xy( 0 + self:GetWidth()*self:GetZoom() - 8, 1 )
				self:diffuse(color("#74818b"))
			end,
			SetCommand=function(self, params)
				local is_parent = params and params.IsParentSection
				if not is_parent then
					self:diffuse(params.Color)
				else
					self:diffuse(color("#74818b"))
				end
			end,
		},
		Def.Sprite{
			Name="FolderFront",
			Texture=THEME:GetPathG("", "folder-solid.png"),
			InitCommand=function(self)
				self:horizalign(left):zoom(0.175)
				self:xy( 4 + self:GetWidth()*self:GetZoom() - 8, 2)
				self:diffuse(color("#8495a1"))
			end
		},
	},
}