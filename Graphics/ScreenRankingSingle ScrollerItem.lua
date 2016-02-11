local HighScoreRow = Def.ActorFrame{
	-- setting ztest to true allows masking
	InitCommand=cmd(ztest, true),

	Def.Quad{
		InitCommand=cmd(zoomto, _screen.w,60 ),
		OnCommand=cmd(diffuse,Color.Black; diffusealpha,0.7)
	},

	Def.Banner{
		InitCommand=cmd(x,WideScale(-280,-320); halign,0; scaletoclipped,102,40; diffusealpha,0.2 ),
		SetCommand=function(self, params)
			if params.Song and params.Song:GetBannerPath() then
				self:LoadFromCachedBanner( params.Song:GetBannerPath() )
			end
		end
	},

	--the name of the song, on top of the graphical banner
	LoadFont("_miso")..{
		InitCommand=cmd(x,WideScale(-220,-280); halign,0; shadowlength,1; wrapwidthpixels,264; maxheight,58; maxwidth,280),
		SetCommand=function(self, params)
			if params.Song then
				self:settext( params.Song:GetDisplayFullTitle() )
			end
		end
	}
}

local MachineProfile = PROFILEMAN:GetMachineProfile()

-- How many difficulties do we want this ranking screen to show?  Defer to the Metrics.
local NumDifficulties = THEME:GetMetric("ScreenRankingSingle", "NumColumns")

-- Make a table to store the difficulties we are interested in displaying.
local DifficultiesToShow = {}

-- Loop through available Metrics, parsing out the shortened difficulty names.
for i=1,NumDifficulties do
	DifficultiesToShow[#DifficultiesToShow+1] = ToEnumShortString(THEME:GetMetric("ScreenRankingSingle", "ColumnDifficulty"..i))
end

local HighScore = Def.ActorFrame{
	SetCommand=function(self, params)
		if not params.Song then return end

		for index, steps in pairs(params.Entries) do
			if MachineProfile and steps then

				local hsl = MachineProfile:GetHighScoreList(params.Song, steps)

				-- hsl:GetHighScores() will return a table of HighScore objects ordered like {score#1, score#2, ...}
				-- we're only interested in the best score per difficulty per song, so we want hsl:GetHighScores()[1]
				local top_score = (hsl and (#hsl:GetHighScores() > 1)) and hsl:GetHighScores()[1]
				local difficulty = ToEnumShortString(steps:GetDifficulty())

				if top_score then

					local text =  top_score:GetName() .. "\n" .. FormatPercentScore( top_score:GetPercentDP() )
					self:GetChild("HighScore_"..difficulty):settext( text )

				else
					-- if there's no top_score for this particular difficulty of this particular chart
					-- hibernate the BitmapText actor to prevent it from being drawn and maybe mitigate framerate issues
					self:GetChild("HighScore_"..difficulty):hibernate( 100 )
				end
			end
		end
	end
}

-- Add a name and score for each difficulty we are interested in
-- These won't have actual text values assigned to them until the
-- cumbersome SetCommand applied to the parent AF above...
for key, difficulty in ipairs(DifficultiesToShow) do

	-- BitmapText actor for the name of the player and the high score itself
	HighScore[#HighScore+1] = Def.BitmapText{
		Font="_miso",
		Name="HighScore_"..difficulty,
		InitCommand=cmd(x,WideScale(140,40) + (key-1)*100; zoom,0.8; horizalign, center)
	}

end


-- add the HighScore to the primary AF
HighScoreRow[#HighScoreRow+1] = HighScore

-- return the primary AF
return HighScoreRow