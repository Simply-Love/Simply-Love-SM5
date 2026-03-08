local player, pane_width = unpack(...)

local gamename = GAMESTATE:GetCurrentGame():GetName()


local num_tabs = IsUsingWideScreen() and 10 or 9
local tab_width = IsUsingWideScreen() and WideScale(26.66, 37.55) or 30
local tab_expanded_extra_width = pane_width - (tab_width*num_tabs)

-- SM({num_tabs, pane_width, tab_width, tab_expanded_extra_width})

local GetStepsToDisplay = LoadActor("./TabbedStepsToDisplay.lua", num_tabs)

local af = Def.ActorFrame{}
af.InitCommand=function(self)
	self:y(-20)
end

-- shared background behind all tabs
af[#af+1] = Def.Quad{
	InitCommand=function(self)
      self:x(WideScale(155, 208.5))
		self:vertalign(top):horizalign(right)
		self:zoomtowidth(pane_width):zoomtoheight(20)
		if not DarkUI() then self:diffuse({10/255, 20/255, 27/255, 1})
		else self:diffusealpha(0.6) end
	end
}

for i=0,num_tabs-1 do
   local tab = Def.ActorFrame{
      SetCommand=function(self)
         local StepsToDisplay = GetStepsToDisplay(player)
         local cur_steps = GAMESTATE:GetCurrentSteps(player)

         local steps_index
         for k,v in pairs(StepsToDisplay) do
            if v == cur_steps then steps_index=k; break end
         end

         self:playcommand("Redraw", StepsToDisplay)
         self:x( WideScale(-127, -171.5) + (i*tab_width) )

         if steps_index and (i+1 < steps_index) then
            self:addx(-tab_expanded_extra_width)
         end
    end
   }

   -- colored tab background
   tab[#tab+1] = Def.Quad{
      InitCommand=function(self)
         self:zoomtowidth(tab_width-1):zoomtoheight(20)
         self:vertalign(top):horizalign(right):x(42)
         if not DarkUI() then self:diffuse({10/255, 20/255, 27/255, 1}) end
      end,
      RedrawCommand=function(self, StepsToDisplay)
         local stepchart = StepsToDisplay[i+1]
         if stepchart then
            if stepchart == GAMESTATE:GetCurrentSteps(player) then
               self:diffuse( DifficultyColor(stepchart:GetDifficulty(), false) ):zoomtowidth(tab_width+tab_expanded_extra_width)
            else
               self:diffuse( BoostColor(DifficultyColor(stepchart:GetDifficulty(), false), DarkUI() and 1 or 0.55) )
               self:zoomtowidth(tab_width-1)
               self:diffusealpha(DarkUI() and 0.5 or 1)
            end
         else
            self:diffuse(DarkUI() and Color.White or {10/255, 20/255, 27/255})
            self:zoomtowidth(tab_width-1)

            if not DarkUI() then
               self:diffusealpha(1)
            else
               local stepchart = StepsToDisplay[i+1]
               if stepchart then
                  self:diffusealpha(0.6)
               else
                  self:diffusealpha(0.3)
               end
            end
         end
      end
   }

   -- difficulty meter
   tab[#tab+1] = LoadFont("Common Bold")..{
      InitCommand=function(self)
         self:zoom(0.4):diffuse(0,0,0,1):y(10)

         if not IsUsingWideScreen() then
            self:x(tab_width - 3) -- 4:3 display
         else
            self:x(tab_width - WideScale(-6,14))
         end
      end,
      RedrawCommand=function(self, StepsToDisplay)
         local stepchart = StepsToDisplay[i+1]
         if stepchart then
            self:settext(stepchart:GetMeter())
            self:diffusealpha(1)
            if stepchart == GAMESTATE:GetCurrentSteps(player) then
               self:diffusealpha(1)
            else
               self:diffusealpha( DarkUI() and 0.6 or 1 )
            end
         else
            self:settext("")
         end
      end
   }
   -- In very small text the first letter of the steps type
   tab[#tab+1] = LoadFont("Common Normal")..{
      InitCommand=function(self)
         self:zoom(0.4):diffuse(0,0,0,1):y(4)
         if not IsUsingWideScreen() then
            self:x(tab_width - 10) -- 4:3 display
         else
            self:x(tab_width - WideScale(5, 0))
         end
      end,
      RedrawCommand=function(self, StepsToDisplay)
         local stepchart = StepsToDisplay[i+1]
         if stepchart then
            local style = stepchart:GetStepsType():gsub("%w+_%w+_", ""):lower()
            local styleString = THEME:GetString("StepsType", ("%s-%s"):format(gamename, style))
            local text = styleString:sub(1,1)
            self:settext(text)
            self:diffusealpha(1)
            if stepchart == GAMESTATE:GetCurrentSteps(player) then
               self:diffusealpha(1)
            else
               self:diffusealpha( DarkUI() and 0.6 or 1 )
            end
         else
            self:settext("")
         end
      end
   }

   -- style string
   tab[#tab+1] = LoadFont("Common Normal")..{
      InitCommand=function(self)
         self:vertspacing(-10):zoom(0.8):diffuse(0,0,0,1)
         self:x(tab_width-WideScale(35, 50)):y(10.5)
      end,
      RedrawCommand=function(self, StepsToDisplay)
         local stepchart = StepsToDisplay[i+1]

         if stepchart and stepchart == GAMESTATE:GetCurrentSteps(player) then
            local style = stepchart:GetStepsType():gsub("%w+_%w+_", ""):lower()
            local styleString = THEME:GetString("StepsType", ("%s-%s"):format(gamename, style))
            local text = ("%s"):format(styleString)
            self:settext(text):zoom(text:find("\n") and 0.7 or 0.8)
         else
            self:settext("")
         end
      end
   }

   af[#af+1] = tab
end

return af