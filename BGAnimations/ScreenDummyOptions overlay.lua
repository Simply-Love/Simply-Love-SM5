-- this handles user input
local function InputHandler(event)
	
	if not event.PlayerNumber or not event.button then
		return false
	end

	if event.type == "InputEventType_FirstPress" then
		
		local topscreen = SCREENMAN:GetTopScreen()
		local scroller = topscreen:GetChild("Overlay")
			
		if event.GameButton == "MenuRight" then
			scroller:SetCurrentAndDestinationItem( scroller:GetCurrentItem() + 1 )
			-- overlay:GetChild("change_sound"):play()

		elseif event.GameButton == "MenuLeft" then
			scroller:SetCurrentAndDestinationItem( scroller:GetCurrentItem() - 1 )
			-- overlay:GetChild("change_sound"):play()
		end
		
		SM(scroller:GetCurrentItem())
	end

	return false
end

local GenerateScrollerItems = function(n)
	local items = {}
	for i=1,n do
		items[i] = Def.ActorFrame{
		
			Def.BitmapText{
				Font="_wendy small",
				Text=tostring(i)
			},
		
			Def.Quad{
				InitCommand=function(self)
					self:diffuse(1,0,0,0.75):zoomto(_screen.w - 80, 40)
				end,
	 		}
		}
	end
	return items
end

local scroller = Def.ActorScroller {
	Name="Scroller",
	TransformFunction=function( self, offset, itemIndex, numItems)
		self:y(_screen.cx, 50 * offset)
	end,
	InitCommand=function(self)
		-- self:SetLoop(true)
		self:SetNumItemsToDraw(9)
		self:SetNumSubdivisions(3)		
	end,
	OnCommand=function(self)
		SCREENMAN:GetTopScreen():AddInputCallback( InputHandler )	
	end,
	Children=GenerateScrollerItems( 9 )
}

return scroller