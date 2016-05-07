local NumColumns = GAMESTATE:GetCurrentStyle():ColumnsPerPlayer()
local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers
local columns = {}

if mods.ColumnFlashOnMiss then

	local af = Def.ActorFrame{
		InitCommand=function(self)
			self:xy( GetNotefieldX(player), _screen.cy )
			-- Via empirical observation/testing, it seems that 200% mini is the effective cap.
			-- At 200% mini, arrows are effectively invisible; they reach a zoom_factor of 0.
			-- So, keeping that cap in mind, the spectrum of possible mini values in this theme
			-- becomes 0 to 2, and it becomes necessary to transform...
			-- a mini value like 35% to a zoom factor like 0.825, or
			-- a mini value like 150% to a zoom factor like 0.25
			local zoom_factor = 1 - scale( mods.Mini:gsub("%%","")/100, 0, 2, 0, 1)
			self:zoom( zoom_factor )
		end,
		JudgmentMessageCommand=function(self, params)
			if params.Player == player and (params.Notes or params.Holds) then
				for i,col in pairs(params.Notes or params.Holds) do
					local tns = ToEnumShortString(params.TapNoteScore or params.HoldNoteScore)
					if tns == "Miss" or tns == "MissedHold" then
						columns[i]:playcommand("Flash")
					end
				end
			end
		end
	}

	for ColumnIndex=1,NumColumns do
		af[#af+1] = Def.Quad{
			InitCommand=function(self)
				columns[ColumnIndex] = self
				local style = GAMESTATE:GetCurrentStyle(player)
				local width = style:GetWidth(player)
				self:diffuse(0,0,0,0)
					:x((ColumnIndex-2.5) * (width/NumColumns))
					:setsize(width/NumColumns, _screen.h*100)
	        end,
			FlashCommand=function(self)
				self:diffuse(1,0,0,0.66)
					:accelerate(0.165):diffuse(0,0,0,0)
			end
		}
	end

	return af

end