local player, pss, isTwoPlayers, bothWantBars, pos_data,
      target_score, personal_best, percentToYCoordinate, GetCurMaxPercentDancePoints = unpack(...)

local pn = ToEnumShortString(player)

local GetPossibleExScore = function(counts)
	local best_counts = {}
	
	local keys = { "W0", "W1", "W2", "W3", "W4", "W5", "Miss", "Held", "LetGo", "HitMine" }

	for key in ivalues(keys) do
		local value = counts[key]
		if value ~= nil then
			-- Initialize the keys	
			if best_counts[key] == nil then
				best_counts[key] = 0
			end

			-- Upgrade dropped holds/rolls to held.
			if key == "LetGo" or key == "Held" then
				best_counts["Held"] = best_counts["Held"] + value
			-- We never hit any mines.
			elseif key == "HitMine" then
				best_counts[key] = 0
			-- Upgrade to FA+ window.
			else
				best_counts["W0"] = best_counts["W0"] + value
			end
		end
	end
	
	local possible_ex_score, possible_total = CalculateExScore(player, best_counts)
	return possible_ex_score, possible_total
end

-- Converts a grade enum to an exponential scale, returning the corresponding Y point in the graph
local getYFromGradeEnum = function(gradeEnum)
	return percentToYCoordinate(THEME:GetMetric("PlayerStageStats", "GradePercent" .. ToEnumShortString(gradeEnum)))
end

-- ---------------------------------------------------------------

local af = Def.ActorFrame {

	-- insert the background actor frame
	LoadActor("./Graph-Background.lua", {player, pss, isTwoPlayers, bothWantBars, pos_data.graph, percentToYCoordinate}),

	-- BAR 1: Current Score
	Def.Quad{
		InitCommand=function(self)
			self:valign(1):halign(0)
				:zoomto(pos_data.bar.w, 1)
				:xy( pos_data.bar.spacing + pos_data.bar.offset, 0 )
		end,
		OnCommand=function(self)
			self:diffuse(Color.Blue)
		end,
		-- follow the player's score
		UpdateCommand=function(self)
			if not SL[pn].ActiveModifiers.ShowEXScore then
				local dp = pss:GetPercentDancePoints()
				self:zoomy(-percentToYCoordinate(dp))
			end
		end,
		ExCountsChangedMessageCommand=function(self, params)
			if SL[pn].ActiveModifiers.ShowEXScore then
				local dp = params.actual_points / params.actual_possible
				self:zoomy(-percentToYCoordinate(dp))
			end
		end
	},

	-- BAR 2: Personal Best Score
	Def.Quad{
		InitCommand=function(self)
			self:valign(1):halign(0)
				:zoomto(pos_data.bar.w, 1)
				:xy( pos_data.bar.offset + (pos_data.bar.spacing * 2) + pos_data.bar.w, 0 )
		end,
		OnCommand=function(self)
			self:diffuse(Color.Green)
		end,
		UpdateCommand = function(self)
			local currentDP = personal_best * GetCurMaxPercentDancePoints()
			self:zoomy(-percentToYCoordinate(currentDP))
		end,
		ExCountsChangedMessageCommand=function(self, params)
			if SL[pn].ActiveModifiers.ShowEXScore then
				local PercentMax, DPCurrMax = GetPossibleExScore(params.ExCounts)
				local currentDP = personal_best * GetCurMaxPercentDancePoints(DPCurrMax, params.actual_possible)
				self:zoomy(-percentToYCoordinate(currentDP))
			end
		end
	},

	-- BAR 3: Target Score
	Def.Quad{
		InitCommand=function(self)
			self:valign(1):halign(0)
				:zoomto(pos_data.bar.w, 1)
				:xy( pos_data.bar.offset + pos_data.bar.spacing * 3 + pos_data.bar.w * 2, 0 )
		end,
		OnCommand=function(self)
			self:diffuse(Color.Red)
		end,
		UpdateCommand = function(self)
			if not SL[pn].ActiveModifiers.ShowEXScore then
				local currentDP = target_score * GetCurMaxPercentDancePoints()
				self:zoomy(-percentToYCoordinate(currentDP))
			end
		end,
		ExCountsChangedMessageCommand=function(self, params)
			if SL[pn].ActiveModifiers.ShowEXScore then
				local PercentMax, DPCurrMax = GetPossibleExScore(params.ExCounts)
				local currentDP = target_score * GetCurMaxPercentDancePoints(DPCurrMax, params.actual_possible)
				self:zoomy(-percentToYCoordinate(currentDP))
			end
		end
	},

	-- Personal Best Border
	Border(pos_data.bar.w+4, -percentToYCoordinate(personal_best)+3, pos_data.BorderWidth)..{
		InitCommand=function(self)
			self:xy(pos_data.bar.offset + (pos_data.bar.spacing * 2) + (pos_data.bar.w/2) + pos_data.bar.w * 1, percentToYCoordinate(personal_best)/2)
		end,
	},

	-- Target Score Border
	Border(pos_data.bar.w+4, -percentToYCoordinate(target_score)+3, pos_data.BorderWidth)..{
		InitCommand=function(self)
			self:xy(pos_data.bar.offset + (pos_data.bar.spacing * 3) + (pos_data.bar.w/2) + pos_data.bar.w * 2, percentToYCoordinate(target_score)/2)
		end,
	},

	Border(pos_data.graph.w+4, pos_data.graph.h+4, 2)..{
		InitCommand=function(self)
			self:vertalign(bottom):horizalign(left)
			self:xy(pos_data.graph.w/2,-pos_data.graph.h/2)
		end,
	}
}

-- reuse "splode" assets (Gamplay in, combo milestones) for for grade changes
-- but don't add them to the FullWidth graph ActorFrame if the player wanted
-- their (arguably distracting) compatriots hidden from the combo
if not SL[pn].ActiveModifiers.HideComboExplosions then
	af[#af+1] = Def.ActorFrame{
		InitCommand=function(self) self:visible(false) end,
		GradeChangedCommand=function(self)
			self:visible(true)
			self:y( getYFromGradeEnum(pss:GetGrade()) )
			self:sleep(0.8):queuecommand("Init")
		end,

		LoadActor(THEME:GetPathG("","_VisualStyles/"..ThemePrefs.Get("VisualStyle").."/GameplayIn splode"))..{
			GradeChangedCommand=function(self)
				self:diffusealpha(0):diffuse(GetCurrentColor(true))
				self:rotationz(10):zoom(0):diffusealpha(0.9)
				self:linear(0.6):rotationz(0):zoom(0.5):diffusealpha(0)
			end
		},
		LoadActor(THEME:GetPathG("","_VisualStyles/"..ThemePrefs.Get("VisualStyle").."/GameplayIn splode"))..{
			GradeChangedCommand=function(self)
				self:diffusealpha(0):diffuse(GetCurrentColor(true))
				self:rotationy(180):rotationz(-10):zoom(0.2):diffusealpha(0.8)
				self:decelerate(0.6):rotationz(0):zoom(0.7):diffusealpha(0)
			end
		},
		LoadActor(THEME:GetPathG("","_VisualStyles/"..ThemePrefs.Get("VisualStyle").."/GameplayIn minisplode"))..{
			GradeChangedCommand=function(self)
				self:diffusealpha(0):diffuse(GetCurrentColor(true))
				self:rotationz(10):zoom(0):diffusealpha(1)
				self:decelerate(0.8):rotationz(0):zoom(0.4):diffusealpha(0)
			end
		}
	}
end


-- text labels for the bars
af[#af+1] = Def.ActorFrame{
	LoadFont("Common Normal")..{
		Text=THEME:GetString("TargetScoreGraph", "You"),
		InitCommand=function(self)
			self:xy( pos_data.bar.offset + pos_data.bar.spacing + (pos_data.bar.w/2), 20 ):shadowlength(1)
		end,
	},

	LoadFont("Common Normal")..{
		Text=THEME:GetString("TargetScoreGraph", "Personal"),
		InitCommand=function(self)
			self:xy( pos_data.bar.offset + (pos_data.bar.spacing * 2) + (pos_data.bar.w/2) + pos_data.bar.w, 20 ):shadowlength(1)
		end,
	},

	LoadFont("Common Normal")..{
		Text=THEME:GetString("TargetScoreGraph", "Target"),
		InitCommand=function(self)
			self:xy( pos_data.bar.offset + (pos_data.bar.spacing * 3) + (pos_data.bar.w/2) + pos_data.bar.w * 2, 20 ):shadowlength(1)
		end,
	}
}

return af