-- don't allow ColumnFlashOnMiss to appear in Casual gamemode via profile settings
if SL.Global.GameMode == "Casual" then return end

local player = ...
local mods = SL[ToEnumShortString(player)].ActiveModifiers

if mods.ColumnFlashOnMiss then

	local NumColumns = GAMESTATE:GetCurrentStyle():ColumnsPerPlayer()
	local columns = {}
	local style = GAMESTATE:GetCurrentStyle(player)
	local width = style:GetWidth(player)

	local y_offset = SL.Global.GameMode == "StomperZ" and 40 or 80

	local af = Def.ActorFrame{
		InitCommand=function(self)
			self:xy( GetNotefieldX(player), y_offset)
			-- Via empirical observation/testing, it seems that 200% mini is the effective cap.
			-- At 200% mini, arrows are effectively invisible; they reach a zoom_factor of 0.
			-- So, keeping that cap in mind, the spectrum of possible mini values in this theme
			-- becomes 0 to 2, and it becomes necessary to transform...
			-- a mini value like 35% to a zoom factor like 0.825, or
			-- a mini value like 150% to a zoom factor like 0.25
			local zoom_factor = 1 - scale( mods.Mini:gsub("%%","")/100, 0, 2, 0, 1)
			self:zoomx( zoom_factor )
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

				self:diffuse(0,0,0,0)
					:x((ColumnIndex - (NumColumns/2 + 0.5)) * (width/NumColumns))
					:vertalign(top)
					:setsize(width/NumColumns, _screen.h - y_offset)
					:fadebottom(0.333)
	        end,
			FlashCommand=function(self)
				self:diffuse(1,0,0,0.66)
					:accelerate(0.165):diffuse(0,0,0,0)
			end
		}
	end

	return af

end