local t = Def.ActorFrame{
	-- setting ztest to true allows masking
	InitCommand=cmd(runcommandsonleaves, cmd(ztest,true) ),
	OffCommand=cmd(accelerate,0.1; diffusealpha,0 ),

	Def.Quad{
		InitCommand=cmd(zoomto, _screen.w,60 ),
		OnCommand=cmd(diffuse,Color.Black; diffusealpha,0.7)
	},

	Def.Banner{
		InitCommand=cmd(x,WideScale(-280,-320); halign,0; scaletoclipped,128,40; diffusealpha,0.2 ),
		SetCommand=function(self, params)
			if params.Song then
				self:LoadFromSong( params.Song )
			end
		end
	},

	--the name of the song, on top of the graphical banner
	LoadFont("_misoreg hires")..{
		InitCommand=cmd(x,WideScale(-220,-280); halign,0; shadowlength,1; wrapwidthpixels,264; maxheight,58; maxwidth,280),
		SetCommand=function(self, params)
			if params.Song then
				self:settext( params.Song:GetDisplayFullTitle() )
			end
		end
	}
}


local Children

-- How many difficulties do we want this ranking screen to show?  Defer to the Metrics.
local NumDifficulties = THEME:GetMetric("ScreenRankingSingle", "NumColumns")

-- Make a table to store the difficulties we are interested in displaying.
local DifficultiesToShow = {}

-- Loop through available Metrics, parsing out the shortened difficulty names.
for i=1,NumDifficulties do
	DifficultiesToShow[#DifficultiesToShow+1] = ToEnumShortString(THEME:GetMetric("ScreenRankingSingle", "ColumnDifficulty"..i))
end

local Scores = Def.ActorFrame{
	InitCommand=function(self)
		Children = self:GetChildren()
	end
}

-- Add a name and score for each difficulty we are interested
-- These won't have actual text values assigned to them until the
-- cumbersome SetCommand below...
for key, difficulty in pairs(DifficultiesToShow) do

	-- the high score name
	Scores[#Scores+1] = LoadFont("_misoreg hires")..{
		Name="HighScoreName_"..difficulty.."_"..key,
		InitCommand=cmd(x,WideScale(140,40) + (key-1)*100; y,-8; zoom,0.8)
	}

	-- the high score
	Scores[#Scores+1] = LoadFont("_misoreg hires")..{
		Name="HighScore_"..difficulty.."_"..key,
		InitCommand=cmd(x,WideScale(140,40) + (key-1)*100; y,12; zoom,0.8)
	}
end

Scores.SetCommand=function(self,param)
	local profile = PROFILEMAN:GetMachineProfile()
	local song = param.Song

	if not song then return end

	for i, steps in pairs(param.Entries) do
		if profile and steps then
			local hsl = profile:GetHighScoreList(song, steps)
			local HighScores = hsl and hsl:GetHighScores()
			local difficulty = ToEnumShortString(steps:GetDifficulty())

			if HighScores and #HighScores > 0 then
				Children["HighScoreName_"..difficulty.."_"..i]:settext( HighScores[1]:GetName() )
				Children["HighScore_"..difficulty.."_"..i]:settext( FormatPercentScore( HighScores[1]:GetPercentDP() ) )
			else
				Children["HighScoreName_"..difficulty.."_"..i]:settext( "-----" )
				Children["HighScore_"..difficulty.."_"..i]:settext( FormatPercentScore( 0 ) )
			end
		end
	end
end

t[#t+1] = Scores

return t