---  this difficulty grid doesn't support CourseMode
---  CourseContentsList.lua should be used instead
if GAMESTATE:IsCourseMode() then return end
-- ----------------------------------------------

local num_rows    = 5
local num_columns = 0

local GridZoomX = IsUsingWideScreen() and 0.435 or 0.39
local BlockZoomY = 0.275

local P1 = GAMESTATE:IsHumanPlayer(PLAYER_1)
local P2 = GAMESTATE:IsHumanPlayer(PLAYER_2)

local GetStepsToDisplay = LoadActor("./StepsToDisplay.lua")


local function getInputHandler(actor, player)
	return (function(event)
		if event.GameButton == "Start" and event.PlayerNumber == player and GAMESTATE:IsHumanPlayer(event.PlayerNumber) then
			actor:visible(true)
		end
	end)
end

local t = Def.ActorFrame{
	Name="StepsDisplayList",
	InitCommand=function(self) self:draworder(0):vertalign(top):xy(IsUsingWideScreen() and _screen.cx-294 or _screen.cx-219.5,IsUsingWideScreen() and _screen.cy - 168 or _screen.cy - 355.8):zoom(IsUsingWideScreen() and WideScale(0.7,1) or 1) end,

	OnCommand=function(self)                           self:queuecommand("RedrawStepsDisplay") end,
	CurrentSongChangedMessageCommand=function(self)    self:queuecommand("RedrawStepsDisplay") end,
	CurrentStepsP1ChangedMessageCommand=function(self) self:queuecommand("RedrawStepsDisplay") end,
	CurrentStepsP2ChangedMessageCommand=function(self) self:queuecommand("RedrawStepsDisplay") end,


	
	RedrawStepsDisplayCommand=function(self)

		local song = GAMESTATE:GetCurrentSong()

		if song then
			local steps = SongUtil.GetPlayableSteps( song )

			if steps then
				local StepsToDisplay = GetStepsToDisplay(steps)

				for i=1,num_rows do
					if StepsToDisplay[i] then
						-- if this particular song has a stepchart for this row, update the Meter
						-- and BlockRow coloring appropriately
						local meter = StepsToDisplay[i]:GetMeter()
						local difficulty = StepsToDisplay[i]:GetDifficulty()
						self:GetChild("Grid"):GetChild("Meter_"..i):playcommand("Set",  {Meter=meter, Difficulty=difficulty})
						self:GetChild("Grid"):GetChild("Meter_1"..i):playcommand("Set",  {Meter=meter, Difficulty=difficulty})
						self:GetChild("Grid"):GetChild("Meter_2"..i):playcommand("Set",  {Meter=meter, Difficulty=difficulty})
						self:GetChild("Grid"):GetChild("Meter_3"..i):playcommand("Set",  {Meter=meter, Difficulty=difficulty})
						self:GetChild("Grid"):GetChild("Meter_4"..i):playcommand("Set",  {Meter=meter, Difficulty=difficulty})
						self:GetChild("Grid"):GetChild("Meter_5"..i):playcommand("Set",  {Meter=meter, Difficulty=difficulty})
						self:GetChild("Grid"):GetChild("Meter_6"..i):playcommand("Set",  {Meter=meter, Difficulty=difficulty})
						self:GetChild("Grid"):GetChild("Meter_7"..i):playcommand("Set",  {Meter=meter, Difficulty=difficulty})
						self:GetChild("Grid"):GetChild("Meter_8"..i):playcommand("Set",  {Meter=meter, Difficulty=difficulty})
						self:GetChild("Grid"):GetChild("Meter_9"..i):playcommand("Set",  {Meter=meter, Difficulty=difficulty})
						self:GetChild("Grid"):GetChild("Blocks_"..i):playcommand("Set", {Meter=meter, Difficulty=difficulty})
					else
						-- otherwise, set the meter to an empty string and hide this particular colored BlockRow
						self:GetChild("Grid"):GetChild("Meter_"..i):playcommand("Unset")
						self:GetChild("Grid"):GetChild("Meter_1"..i):playcommand("Unset")
						self:GetChild("Grid"):GetChild("Meter_2"..i):playcommand("Unset")
						self:GetChild("Grid"):GetChild("Meter_3"..i):playcommand("Unset")
						self:GetChild("Grid"):GetChild("Meter_4"..i):playcommand("Unset")
						self:GetChild("Grid"):GetChild("Meter_5"..i):playcommand("Unset")
						self:GetChild("Grid"):GetChild("Meter_6"..i):playcommand("Unset")
						self:GetChild("Grid"):GetChild("Meter_7"..i):playcommand("Unset")
						self:GetChild("Grid"):GetChild("Meter_8"..i):playcommand("Unset")
						self:GetChild("Grid"):GetChild("Meter_9"..i):playcommand("Unset")
						self:GetChild("Grid"):GetChild("Blocks_"..i):playcommand("Unset")
					end
				end
			end
		else
			self:playcommand("Unset")
		end
	end,

}


local Grid = Def.ActorFrame{
	Name="Grid",
	InitCommand=function(self) self:horizalign(left):vertalign(top):xy(8, -52 ) end,
	
}


for RowNumber=1,num_rows do

	Grid[#Grid+1] =	Def.Sprite{
		Name="Blocks_"..RowNumber,
		Texture=THEME:GetPathB("ScreenSelectMusicDD", "overlay/StepsDisplayList/_block.png"),

		InitCommand=function(self) self:diffusealpha(0) end,
		OnCommand=function(self)
			local width = self:GetWidth()
			local height= self:GetHeight()
			self:y( RowNumber * height * BlockZoomY)
			self:zoomto(width * num_columns * GridZoomX, height * BlockZoomY)
		end,
		SetCommand=function(self, params)
			-- the engine's Steps::TidyUpData() method ensures that difficulty meters are positive
			-- (and does not seem to enforce any upper bound that I can see)
			self:customtexturerect(0, 0, num_columns, 1)
			self:cropright( 1 - (params.Meter * (1/num_columns)) )
			self:diffuse( DifficultyColor(params.Difficulty, true) )
		end,
		UnsetCommand=function(self)
			self:customtexturerect(0,0,0,0)
		end
	}

	-------------------------------- Player 1 Meter stuff --------------------------------
	Grid[#Grid+1] = LoadFont("Common Bold")..{
		Name="Meter_1"..RowNumber,
		InitCommand=function(self)
			local height = self:GetParent():GetChild("Blocks_"..RowNumber):GetHeight()
			self:horizalign(center)
			self:y(WideScale(358,282))
			self:x(IsUsingWideScreen() and WideScale(RowNumber * height/0.35 * BlockZoomY - 112,RowNumber * height/0.35 * BlockZoomY-155) or RowNumber * height/0.35 * BlockZoomY-106)
			self:zoom(0.75)
			if IsUsingWideScreen() then
					self:visible(P1)
				else
					self:visible(true)
			end
		end,
		SetCommand=function(self, params)
			-- diffuse and set each chart's difficulty meter
			self:diffuse( Color.Black)
			if params.Meter < 40 then
				self:settext(params.Meter)
			else
				self:settext("M")
			end
		end,
		UnsetCommand=function(self) self:settext(""):diffuse(color("#182025")) end,
		OnCommand=function(self)
			SCREENMAN:GetTopScreen():AddInputCallback(getInputHandler(self, 'PlayerNumber_P1'))
		end
	}
	
	Grid[#Grid+1] = LoadFont("Common Bold")..{
		Name="Meter_2"..RowNumber,
		InitCommand=function(self)
			local height = self:GetParent():GetChild("Blocks_"..RowNumber):GetHeight()
			self:horizalign(center)
			self:y(WideScale(362,286))
			self:x(IsUsingWideScreen() and  WideScale(RowNumber * height/0.35 * BlockZoomY - 96,RowNumber * height/0.35 * BlockZoomY-159) or RowNumber * height/0.35 * BlockZoomY-102)
			self:zoom(0.75)
			if IsUsingWideScreen() then
					self:visible(P1)
				else
					self:visible(true)
			end
		end,
		SetCommand=function(self, params)
			-- diffuse and set each chart's difficulty meter
			self:diffuse( Color.Black)
			if params.Meter < 40 then
				self:settext(params.Meter)
			else
				self:settext("M")
			end
		end,
		UnsetCommand=function(self) self:settext(""):diffuse(color("#182025")) end,
		OnCommand=function(self)
			SCREENMAN:GetTopScreen():AddInputCallback(getInputHandler(self, 'PlayerNumber_P1'))
		end
	}
	
	Grid[#Grid+1] = LoadFont("Common Bold")..{
		Name="Meter_3"..RowNumber,
		InitCommand=function(self)
			local height = self:GetParent():GetChild("Blocks_"..RowNumber):GetHeight()
			self:horizalign(center)
			self:y(WideScale(358,282))
			self:x(IsUsingWideScreen() and WideScale(RowNumber * height/0.35 * BlockZoomY - 96,RowNumber * height/0.35 * BlockZoomY-159) or RowNumber * height/0.35 * BlockZoomY-102)
			self:zoom(0.75)
			if IsUsingWideScreen() then
					self:visible(P1)
				else
					self:visible(true)
			end
		end,
		SetCommand=function(self, params)
			-- diffuse and set each chart's difficulty meter
			self:diffuse( Color.Black)
			if params.Meter < 40 then
				self:settext(params.Meter)
			else
				self:settext("M")
			end
		end,
		UnsetCommand=function(self) self:settext(""):diffuse(color("#182025")) end,
		OnCommand=function(self)
			SCREENMAN:GetTopScreen():AddInputCallback(getInputHandler(self, 'PlayerNumber_P1'))
		end
	}
	
	Grid[#Grid+1] = LoadFont("Common Bold")..{
		Name="Meter_4"..RowNumber,
		InitCommand=function(self)
			local height = self:GetParent():GetChild("Blocks_"..RowNumber):GetHeight()
			self:horizalign(center)
			self:y(WideScale(362,286))
			self:x(IsUsingWideScreen() and WideScale(RowNumber * height/0.35 * BlockZoomY - 112,RowNumber * height/0.35 * BlockZoomY-155) or RowNumber * height/0.35 * BlockZoomY-106)
			self:zoom(0.75)
			if IsUsingWideScreen() then
					self:visible(P1)
				else
					self:visible(true)
			end
		end,
		SetCommand=function(self, params)
			-- diffuse and set each chart's difficulty meter
			self:diffuse( Color.Black)
			if params.Meter < 40 then
				self:settext(params.Meter)
			else
				self:settext("M")
			end
		end,
		UnsetCommand=function(self) self:settext(""):diffuse(color("#182025")) end,
		OnCommand=function(self)
			SCREENMAN:GetTopScreen():AddInputCallback(getInputHandler(self, 'PlayerNumber_P1'))
		end
	}
	
	----- The actual numbers -----
	Grid[#Grid+1] = LoadFont("Common Bold")..{
		Name="Meter_"..RowNumber,
		InitCommand=function(self)
			local height = self:GetParent():GetChild("Blocks_"..RowNumber):GetHeight()
			self:horizalign(center)
			self:y(WideScale(360,284))
			self:x(WideScale(RowNumber * height/0.35 * BlockZoomY -104,RowNumber * height/0.35 * BlockZoomY-157))
			self:zoom(0.75)
			if IsUsingWideScreen() then
					self:visible(P1)
				else
					self:visible(true)
			end
		end,
		SetCommand=function(self, params)
			-- diffuse and set each chart's difficulty meter
			self:diffuse( DifficultyColor(params.Difficulty) )
			if params.Meter < 40 then
				self:settext(params.Meter)
			else
				self:settext("M")
			end
		end,
		UnsetCommand=function(self) self:settext(""):diffuse(color("#182025")) end,
		OnCommand=function(self)
			SCREENMAN:GetTopScreen():AddInputCallback(getInputHandler(self, 'PlayerNumber_P1'))
		end
	}
	
	-------------------------------- Player 2 Meter stuff --------------------------------
	
	Grid[#Grid+1] = LoadFont("Common Bold")..{
		Name="Meter_6"..RowNumber,
		InitCommand=function(self)
			local height = self:GetParent():GetChild("Blocks_"..RowNumber):GetHeight()
			self:horizalign(center)
			self:y(WideScale(362,286))
			self:x(WideScale(RowNumber * height/0.35 * BlockZoomY + 577,RowNumber * height/0.35 * BlockZoomY+430.5))
			self:zoom(0.75)
			if IsUsingWideScreen() then
					self:visible(P2)
				else
					self:visible(false)
					self:zoom(0)
			end
		end,
		SetCommand=function(self, params)
			-- diffuse and set each chart's difficulty meter
			self:diffuse( Color.Black)
			if params.Meter < 40 then
				self:settext(params.Meter)
			else
				self:settext("M")
			end
		end,
		UnsetCommand=function(self) self:settext(""):diffuse(color("#182025")) end,
		OnCommand=function(self)
			SCREENMAN:GetTopScreen():AddInputCallback(getInputHandler(self, 'PlayerNumber_P2'))
		end
	}
	
	Grid[#Grid+1] = LoadFont("Common Bold")..{
		Name="Meter_7"..RowNumber,
		InitCommand=function(self)
			local height = self:GetParent():GetChild("Blocks_"..RowNumber):GetHeight()
			self:horizalign(center)
			self:y(WideScale(358,282))
			self:x(WideScale(RowNumber * height/0.35 * BlockZoomY + 573,RowNumber * height/0.35 * BlockZoomY+426.5))
			self:zoom(0.75)
			if IsUsingWideScreen() then
					self:visible(P2)
				else
					self:visible(false)
					self:zoom(0)
			end
		end,
		SetCommand=function(self, params)
			-- diffuse and set each chart's difficulty meter
			self:diffuse( Color.Black)
			if params.Meter < 40 then
				self:settext(params.Meter)
			else
				self:settext("M")
			end
		end,
		UnsetCommand=function(self) self:settext(""):diffuse(color("#182025")) end,
		OnCommand=function(self)
			SCREENMAN:GetTopScreen():AddInputCallback(getInputHandler(self, 'PlayerNumber_P2'))
		end
	}
	
	Grid[#Grid+1] = LoadFont("Common Bold")..{
		Name="Meter_8"..RowNumber,
		InitCommand=function(self)
			local height = self:GetParent():GetChild("Blocks_"..RowNumber):GetHeight()
			self:horizalign(center)
			self:y(WideScale(362,286))
			self:x(WideScale(RowNumber * height/0.35 * BlockZoomY + 573,RowNumber * height/0.35 * BlockZoomY+426.5))
			self:zoom(0.75)
			if IsUsingWideScreen() then
					self:visible(P2)
				else
					self:visible(false)
					self:zoom(0)
			end
		end,
		SetCommand=function(self, params)
			-- diffuse and set each chart's difficulty meter
			self:diffuse( Color.Black)
			if params.Meter < 40 then
				self:settext(params.Meter)
			else
				self:settext("M")
			end
		end,
		UnsetCommand=function(self) self:settext(""):diffuse(color("#182025")) end,
		OnCommand=function(self)
			SCREENMAN:GetTopScreen():AddInputCallback(getInputHandler(self, 'PlayerNumber_P2'))
		end
	}
	
	Grid[#Grid+1] = LoadFont("Common Bold")..{
		Name="Meter_9"..RowNumber,
		InitCommand=function(self)
			local height = self:GetParent():GetChild("Blocks_"..RowNumber):GetHeight()
			self:horizalign(center)
			self:y(WideScale(358,282))
			self:x(WideScale(RowNumber * height/0.35 * BlockZoomY + 577,RowNumber * height/0.35 * BlockZoomY+430.5))
			self:zoom(0.75)
			if IsUsingWideScreen() then
					self:visible(P2)
				else
					self:visible(false)
					self:zoom(0)
			end
		end,
		SetCommand=function(self, params)
			-- diffuse and set each chart's difficulty meter
			self:diffuse( Color.Black)
			if params.Meter < 40 then
				self:settext(params.Meter)
			else
				self:settext("M")
			end
		end,
		UnsetCommand=function(self) self:settext(""):diffuse(color("#182025")) end,
		OnCommand=function(self)
			SCREENMAN:GetTopScreen():AddInputCallback(getInputHandler(self, 'PlayerNumber_P2'))
		end
	}
	
	----- The actual numbers -----
	Grid[#Grid+1] = LoadFont("Common Bold")..{
		Name="Meter_5"..RowNumber,
		InitCommand=function(self)
			local height = self:GetParent():GetChild("Blocks_"..RowNumber):GetHeight()
			self:horizalign(center)
			self:y(WideScale(360,284))
			self:x(WideScale(RowNumber * height/0.35 * BlockZoomY + 575,RowNumber * height/0.35 * BlockZoomY+428.5))
			self:zoom(0.75)
			if IsUsingWideScreen() then
					self:visible(P2)
				else
					self:visible(false)
					self:zoom(0)
			end
		end,
		SetCommand=function(self, params)
			-- diffuse and set each chart's difficulty meter
			self:diffuse( DifficultyColor(params.Difficulty) )
			if params.Meter < 40 then
				self:settext(params.Meter)
			else
				self:settext("M")
			end
		end,
		UnsetCommand=function(self) self:settext(""):diffuse(color("#182025")) end,
		OnCommand=function(self)
			SCREENMAN:GetTopScreen():AddInputCallback(getInputHandler(self, 'PlayerNumber_P2'))
		end
	}
	
	
	
end

t[#t+1] = Grid

return t