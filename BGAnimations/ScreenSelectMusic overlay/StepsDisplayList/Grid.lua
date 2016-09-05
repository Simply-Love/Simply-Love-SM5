local GridColumns = 20
local GridRows = 5
local GridZoomX = IsUsingWideScreen() and 0.435 or 0.39
local BlockZoomY = 0.275
local StepsToDisplay, SongOrCourse, StepsOrTrails
local NumSongsInCourse = 8

local t = Def.ActorFrame{
	Name="StepsDisplayList",
	InitCommand=cmd(vertalign, top; draworder, 2; xy, _screen.cx-170, _screen.cy + 70),
	-- - - - - - - - - - - - - -

	OnCommand=cmd(queuecommand, "RedrawStepsDisplay"),
	CurrentSongChangedMessageCommand=cmd(queuecommand, "RedrawStepsDisplay"),
	CurrentCourseChangedMessageCommand=cmd(queuecommand, "RedrawStepsDisplay"),
	StepsHaveChangedCommand=cmd(queuecommand, "RedrawStepsDisplay"),

	-- - - - - - - - - - - - - -

	RedrawStepsDisplayCommand=function(self)

		SongOrCourse = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse()) or GAMESTATE:GetCurrentSong()

		if SongOrCourse then
			StepsOrTrails = (GAMESTATE:IsCourseMode() and SongOrCourse:GetAllTrails()) or SongUtil.GetPlayableSteps( SongOrCourse )

			if StepsOrTrails then

				StepsToDisplay = GetStepsToDisplay(StepsOrTrails)
				if GAMESTATE:IsCourseMode() == false then
					for RowNumber=1,GridRows do
						if StepsToDisplay[RowNumber] then
							-- if this particular song has a stepchart for this row, update the Meter
							-- and BlockRow coloring appropriately
							local meter = StepsToDisplay[RowNumber]:GetMeter()
							local difficulty = StepsToDisplay[RowNumber]:GetDifficulty()
							self:GetChild("Grid"):GetChild("Meter_"..RowNumber):playcommand("Set", {Meter=meter, Difficulty=difficulty})
							self:GetChild("Grid"):GetChild("Blocks_"..RowNumber):playcommand("Set", {Meter=meter, Difficulty=difficulty})
						else
							-- otherwise, set the meter to "?" and hide this particular colored BlockRow
							self:GetChild("Grid"):GetChild("Meter_"..RowNumber):playcommand("Unset")
							self:GetChild("Grid"):GetChild("Blocks_"..RowNumber):playcommand("Unset")

						end
					end
				else
					--clear the text
					for i=1, NumSongsInCourse do
						self:GetChild("Grid"):GetChild("CourseSongName"..i):playcommand("Unset")
						self:GetChild("Grid"):GetChild("CourseSongMeter"..i):playcommand("Unset")
					end
					--Get the current trail based on the Master Player Number, extract the song information from each trail entry
					--It shouldn't matter if it's P1 or P2 since Marathon mode locks you to the same difficulty
					local player = GAMESTATE:GetMasterPlayerNumber()
					local trail_entries = GAMESTATE:GetCurrentTrail(player):GetTrailEntries()

					for i=1, #trail_entries do
						local song = {}
						song["Title"] = trail_entries[i]:GetSong():GetDisplayMainTitle()
						song["DifficultyColor"] = DifficultyColor( trail_entries[i]:GetSteps():GetDifficulty() )
						song["Meter"] = trail_entries[i]:GetSteps():GetMeter()

						if i <= NumSongsInCourse then
							self:GetChild("Grid"):GetChild("CourseSongMeter"..i):playcommand("Set", {SongToDisplay=song})
						 	self:GetChild("Grid"):GetChild("CourseSongName"..i):playcommand("Set", {SongToDisplay=song})
						end
					end

					SM("# Songs: " .. #trail_entries)
				end
			end
		else
			StepsOrTrails, StepsToDisplay = nil, nil
			self:playcommand("Unset")
		end
	end,

	-- - - - - - - - - - - - - -

	-- background
	Def.Quad{
		Name="Background",
		InitCommand=function(self)
			self:diffuse(color("#1e282f"))
			self:zoomto(320, 96)
			if ThemePrefs.Get("RainbowMode") then
				self:diffusealpha(0.75)
			end
		end
	},
}


local Grid = Def.ActorFrame{
	Name="Grid",
	InitCommand=cmd(horizalign, left; vertalign, top; xy, 8, -52 ),
}


-- A grid of decorative faux-blocks that will exist
-- behind the changing difficulty blocks.
if GAMESTATE:IsCourseMode() == false then
	Grid[#Grid+1] = Def.Sprite{
		Name="BackgroundBlocks",
		Texture=THEME:GetPathB("ScreenSelectMusic", "overlay/StepsDisplayList/_block.png"),

		InitCommand=cmd(diffuse, color("#182025") ),
		OnCommand=function(self)
			local width = self:GetWidth()
			local height= self:GetHeight()
			self:zoomto(width * GridColumns * GridZoomX, height * GridRows * BlockZoomY)
			self:y( 3 * height * BlockZoomY )
			self:customtexturerect(0, 0, GridColumns, GridRows)
		end
	}


	for RowNumber=1,GridRows do
		Grid[#Grid+1] =	Def.Sprite{
			Name="Blocks_"..RowNumber,
			Texture=THEME:GetPathB("ScreenSelectMusic", "overlay/StepsDisplayList/_block.png"),

			InitCommand=cmd(diffusealpha,0),
			OnCommand=function(self)
				local width = self:GetWidth()
				local height= self:GetHeight()
				self:y( RowNumber * height * BlockZoomY)
				self:zoomto(width * GridColumns * GridZoomX, height * BlockZoomY)
			end,
			SetCommand=function(self, params)

				local meter = params.Meter

				-- our grid only supports charts with up to a 20-block difficulty meter
				-- but charts can have higher difficulties
				-- handle that here by setting a maximum number to worry about displaying
				if meter > GridColumns then
					meter = GridColumns
				end

				self:customtexturerect(0, 0, GridColumns, 1)
				self:cropright( 1 - (meter * (1/GridColumns)) )

				-- diffuse and set each chart's difficulty meter
				self:diffuse( DifficultyColor(params.Difficulty) )
			end,
			UnsetCommand=function(self)
				self:customtexturerect(0,0,0,0)
			end
		}

		Grid[#Grid+1] = Def.BitmapText{
			Name="Meter_"..RowNumber,
			Font="_wendy small",

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
			UnsetCommand=cmd(settext, ""; diffuse,color("#182025")),
		}
	end

else
	--TODO: Add the Grid Children for the Course song list here
	for i=1, NumSongsInCourse do 
		Grid[#Grid + 1] = Def.BitmapText {
			Name = "CourseSongMeter"..i,
			Font = "_wendy small",
			InitCommand=function(self)
				local height = self:GetHeight() + 20
				local offsetY = i > 4 and i-4 or i
				self:horizalign(right)
				self:y(height * offsetY) 
				local startX = IsUsingWideScreen() and -145 or -131
				self:x( i > 4 and startX + 150 or startX )
			end,
			SetCommand=function(self, params)
				if params.SongToDisplay then
					self:diffuse(params.SongToDisplay["DifficultyColor"])
					self:settext(params.SongToDisplay["Meter"])
					self:zoom(0.3)
				end

			end,
			UnsetCommand=cmd(settext, "")
		}
		Grid[#Grid + 1] = Def.BitmapText {
			Name = "CourseSongName"..i,
			Font = "_miso",
			InitCommand=function(self)
				local height = self:GetHeight() + 20
				local offsetY = i > 4 and i-4 or i
				self:horizalign(left)
				self:y(height * offsetY)
				local startX = IsUsingWideScreen() and -140 or -126
				self:x( i > 4 and startX + 150 or startX )
			end,
			SetCommand=function(self, params)
				if params.SongToDisplay then
					self:settext(params.SongToDisplay["Title"])
					self:zoom(WideScale(0.8,0.9))
				end

			end,
			UnsetCommand=cmd(settext, "")
		}
	end

end

t[#t+1] = Grid

return t