local transform_function = function(self,offsetFromCenter,itemIndex,numitems)
	self:y( offsetFromCenter * 23 )
end

local af = Def.ActorFrame{
	InitCommand=function(self)
		self:xy(_screen.cx-170, _screen.cy + 40)
	end,

	---------------------------------------------------------------------
	-- Masks (here) are just Quads that serve to hide the rows
	-- of the CourseContentsList above and below where we want to see them.
	-- To see what I mean, try uncommenting the two calls to MaskSource()
	-- (one per Quad) and refreshing the screen.

	-- lower mask
	Def.Quad{
		InitCommand=function(self)
			self:xy(-44,98):zoomto(_screen.w/2, 40)
				:MaskSource()
		end
	},

	-- upper mask
	Def.Quad{
		InitCommand=function(self)
			self:vertalign(bottom)
				:xy(-44,-18):zoomto(_screen.w/2, 100)
				:MaskSource()
		end
	},
	---------------------------------------------------------------------

	-- gray background Quad
	Def.Quad{
		InitCommand=function(self)
			self:diffuse(color("#1e282f")):zoomto(320, 96)
				:xy(0, 30)

			if ThemePrefs.Get("RainbowMode") then
				self:diffusealpha(0.75)
			end
		end
	},
}

af[#af+1] = Def.CourseContentsList {
	-- ???
	MaxSongs=1000,
	-- ???
	NumItemsToDraw=8,

	CurrentTrailP1ChangedMessageCommand=function(self) self:playcommand("Set") end,
	CurrentTrailP2ChangedMessageCommand=function(self) self:playcommand("Set") end,

	InitCommand=function(self)
		self:xy(36,-4)
	end,

	-- ???
	SetCommand=function(self)
		self:SetFromGameState()
			:SetCurrentAndDestinationItem(0)
			:SetTransformFromFunction(transform_function)
			:PositionItems()

			:SetLoop(false)
			:SetPauseCountdownSeconds(1)
			:SetSecondsPauseBetweenItems( 0.2 )
			:SetDestinationItem( math.max(0,self:GetNumItems() - 4) )
	end,

	-- a generic row in the CourseContentsList
	Display=Def.ActorFrame {
		SetSongCommand=function(self, params)
			self:finishtweening()
				:zoomy(0)
				:sleep(0.125*params.Number)
				:linear(0.125):zoomy(1)
				:linear(0.05):zoomx(1)
				:decelerate(0.1):zoom(0.875)
		end,

		-- song title
		Def.BitmapText{
			Font="_miso",
			InitCommand=function(self)
				self:xy(-160, 0)
					:horizalign(left)
					:maxwidth(240)
			end,
			SetSongCommand=function(self, params)
				if params.Song then
					self:settext( params.Song:GetDisplayFullTitle() )
				else
					self:SetFromString( "??????????", "??????????", "", "", "", "" )
				end
			end
		},

		-- PLAYER_1 song difficulty
		Def.BitmapText{
			Font="_miso",
			Text="",
			InitCommand=function(self)
				self:xy(-170, 0):horizalign(right)
			end,
			SetSongCommand=function(self, params)
				if params.PlayerNumber ~= PLAYER_1 then return end

				self:settext( params.Meter ):diffuse( CustomDifficultyToColor(params.Difficulty) )
			end
		},

		-- PLAYER_2 song difficulty
		Def.BitmapText{
			Font="_miso",
			Text="",
			InitCommand=function(self)
				self:xy(114,0):horizalign(right)
			end,
			SetSongCommand=function(self, params)
				if params.PlayerNumber ~= PLAYER_2 then return end

				self:settext( params.Meter ):diffuse( CustomDifficultyToColor(params.Difficulty) )
			end
		}
	}
}

return af