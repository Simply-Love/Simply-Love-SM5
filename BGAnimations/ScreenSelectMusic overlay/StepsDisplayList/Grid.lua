-- this difficulty grid doesn't support CourseMode
-- CourseContentsList.lua should be used instead
if GAMESTATE:IsCourseMode() then return end
-- ----------------------------------------------

local num_rows    = 5
local num_columns = 20

local GridZoomX = IsUsingWideScreen() and 0.435 or 0.39
local BlockZoomY = 0.275

local GetStepsToDisplay = LoadActor("./StepsToDisplay.lua")

local t = Def.ActorFrame{
	Name="StepsDisplayList",
	InitCommand=function(self) self:vertalign(top):xy(_screen.cx-170, _screen.cy + 70) end,

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
						self:GetChild("Grid"):GetChild("Blocks_"..i):playcommand("Set", {Meter=meter, Difficulty=difficulty})
					else
						-- otherwise, set the meter to an empty string and hide this particular colored BlockRow
						self:GetChild("Grid"):GetChild("Meter_"..i):playcommand("Unset")
						self:GetChild("Grid"):GetChild("Blocks_"..i):playcommand("Unset")
					end
				end
			end
		else
			self:playcommand("Unset")
		end
	end,

	-- - - - - - - - - - - - - -

	-- background
	Def.Quad{
		Name="Background",
		InitCommand=function(self)
			self:diffuse(color("#1e282f")):zoomto(320, 96)
			if ThemePrefs.Get("RainbowMode") then
				self:diffusealpha(0.9)
			end
		end
	},
}


local Grid = Def.ActorFrame{
	Name="Grid",
	InitCommand=function(self) self:horizalign(left):vertalign(top):xy(8, -52 ) end,
}


-- A grid of decorative faux-blocks that will exist
-- behind the changing difficulty blocks.
Grid[#Grid+1] = Def.Sprite{
	Name="BackgroundBlocks",
	Texture=THEME:GetPathB("ScreenSelectMusic", "overlay/StepsDisplayList/_block.png"),

	InitCommand=function(self) self:diffuse(color("#182025")) end,
	OnCommand=function(self)
		local width = self:GetWidth()
		local height= self:GetHeight()
		self:zoomto(width * num_columns * GridZoomX, height * num_rows * BlockZoomY)
		self:y( 3 * height * BlockZoomY )
		self:customtexturerect(0, 0, num_columns, num_rows)
	end
}

for RowNumber=1,num_rows do

	Grid[#Grid+1] =	Def.Sprite{
		Name="Blocks_"..RowNumber,
		Texture=THEME:GetPathB("ScreenSelectMusic", "overlay/StepsDisplayList/_block.png"),

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

	Grid[#Grid+1] = LoadFont("Common Bold")..{
		Name="Meter_"..RowNumber,
		InitCommand=function(self)
			local height = self:GetParent():GetChild("Blocks_"..RowNumber):GetHeight()
			self:horizalign(right)
			self:y(RowNumber * height * BlockZoomY)
			self:x( IsUsingWideScreen() and -140 or -126 )
			self:zoom(0.3)
		end,
		SetCommand=function(self, params)
			-- diffuse and set each chart's difficulty meter
			self:diffuse( DifficultyColor(params.Difficulty) )
			self:settext(params.Meter)
		end,
		UnsetCommand=function(self) self:settext(""):diffuse(color("#182025")) end,
	}
end

t[#t+1] = Grid

return t