local player, pss, isTwoPlayers, bothWantBars, pos_data,
      target_score, personal_best, percentToYCoordinate, GetCurMaxPercentDancePoints = unpack(...)


return Def.ActorFrame {

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
			local dp = pss:GetPercentDancePoints()
			self:zoomy(-percentToYCoordinate(dp))
		end
	},

	-- BAR 2: Target Score
	Def.Quad{
		InitCommand=function(self)
			self:valign(1):halign(0)
				:zoomto(pos_data.bar.w, 1)
				:xy( pos_data.bar.offset + pos_data.bar.spacing * 2 + pos_data.bar.w, 0 )
		end,
		OnCommand=function(self)
			self:diffuse(Color.Red)
		end,
		UpdateCommand=function(self)
			local targetDP = target_score * GetCurMaxPercentDancePoints()
			self:zoomy(-percentToYCoordinate(targetDP))
		end
	},

	-- Target Border
	Border(pos_data.bar.w + pos_data.BorderWidth * 2, -percentToYCoordinate(target_score)+3, pos_data.BorderWidth)..{
		InitCommand=function(self)
			self:xy(pos_data.bar.offset + pos_data.bar.spacing * 2 + pos_data.bar.w + pos_data.bar.w/2, percentToYCoordinate(target_score)/2)
		end,
	},
}