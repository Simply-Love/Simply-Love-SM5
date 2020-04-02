local num_items = THEME:GetMetric("MusicWheel", "NumWheelItems")
-- subtract 2 from the total number of MusicWheelItems
-- one MusicWheelItem will be offsceen above, one will be offscreen below
local num_visible_items = num_items - 2

local item_width = _screen.w / 2.125

return Def.Quad{ InitCommand=function(self) self:horizalign(left):x(WideScale(28,33)):zoomto(item_width,_screen.h/num_visible_items-1) end }