-- If you pass a quest in SRPG6, it will display the quests passed on the evaluation screen

-- We only want to show this info if there's space (there won't be space in 2 player mode)
if #GAMESTATE:GetHumanPlayers() ~= 1 then return end

local player = ...
local pn = ToEnumShortString(player)
local af = Def.ActorFrame{
	Name="RPGQuest"..pn,
	InitCommand=function(self)
		self:visible(false)
		self:y(109)
		self:x(381 * (player == PLAYER_1 and 1 or -1))
	end,
	RpgQuestsCommand=function(self,params)
		self:visible(true)
		self:GetChild("QuestText"):playcommand("Set",params)
	end
}

-- Draw border Quad
af[#af+1] = Def.Quad {
	InitCommand=function(self)
		self:zoomto(157,143)
		self:diffuse(color("1,0.972,0.792,1"))
	end
}

-- Draw background Quad
af[#af+1] = Def.Quad {
	InitCommand=function(self)
		self:zoomto(155,141)
		self:diffuse(Color.Black)
	end
}

-- SRPG logo
af[#af+1] = Def.Sprite {
	Texture=THEME:GetPathG("", "_VisualStyles/SRPG6/logo_main (doubleres).png"),
	InitCommand=function(self)
		self:zoom(0.25)
		self:diffusealpha(0.2)
	end
}


local rowheight = 15


-- Score
af[#af+1] = LoadFont("Common Normal")..{
	Name="Score",
	InitCommand=function(self)
		self:zoom(0.8)
	end,
	RpgQuestsCommand=function(self,params)
		local score = params.box_score[1]
		local score_text = (score < 0 and "" or "+") ..  string.format("%.2f%%",score)
		self:settext(score_text)
		if score < 0 then 
				self:diffuse(Color.Red) 
		elseif score == 0 then 
			self:diffuse(Color.Blue) 
		else 
			self:diffuse(Color.Green) 
		end
		self:xy(-30,-60)		
	end
}

-- Rate
af[#af+1] = LoadFont("Common Normal")..{
	Name="Rate",
	InitCommand=function(self)
		self:zoom(0.8)
	end,
	RpgQuestsCommand=function(self,params)
		local rate = params.box_score[2]
		local rate_text = (rate < 0 and "" or "+") ..  string.format("%.2f",rate) .. "x"
		self:settext(rate_text)
		if rate < 0 then 
			self:diffuse(Color.Red) 
		elseif rate == 0 then 
			self:diffuse(Color.Blue) 
		else 
			self:diffuse(Color.Green) 
		end
		self:xy(30,-60)		
	end
}

-- Life level / BPM skill points
af[#af+1] = LoadFont("Common Normal")..{
	Name="Progress",
	InitCommand=function(self)
		self:zoom(0.8)
	end,
	RpgQuestsCommand=function(self,params)
		if #params.box_progress > 0 then
			local progress_text = params.box_progress[1]
			if #params.box_progress == 2 then progress_text = progress_text .. "    " .. params.box_progress[2] end
			self:settext(progress_text)
			self:y(-60+rowheight)
		end
	end
}

-- Column 1
af[#af+1] = LoadFont("Common Normal")..{
	Name="SkillPointsCol1",
	InitCommand=function(self)
		self:zoom(0.8)
	end,
	RpgQuestsCommand=function(self,params)
		-- 2 per row
		if #params.box_stats > 0 then
			local rows = math.ceil(#params.box_stats/2)
			local sp_text = params.box_stats[1]
			-- There's probably a better way to do this
			for i=2,rows do
				if params.box_stats[i*2-1] ~= nil then 
					sp_text = sp_text .. "\n" .. params.box_stats[i*2-1]
				end
			end
			self:settext(sp_text)
			self:vertspacing(-5)
			self:vertalign('VertAlign_Top')
			self:maxwidth(180)
			startrow = #params.box_progress > 0 and 2 or 1
			self:xy(-40,-65+rowheight*startrow)
			self:diffuse(color("0.501,0.501,0.501"))

		end
	end
} 

-- Column 2
af[#af+1] = LoadFont("Common Normal")..{
	Name="SkillPointsCol1",
	InitCommand=function(self)
		self:zoom(0.8)
	end,
	RpgQuestsCommand=function(self,params)
		-- 2 per row
		if #params.box_stats > 1 then
			local rows = math.ceil(#params.box_stats/2)
			local sp_text = params.box_stats[2]
			-- There's probably a better way to do this
			for i=2,rows do
				if params.box_stats[i*2] ~= nil then 
					sp_text = sp_text .. "\n" .. params.box_stats[i*2]
				end
			end
			self:settext(sp_text)
			self:vertspacing(-5)
			self:vertalign('VertAlign_Top')
			startrow = #params.box_progress > 0 and 2 or 1
			self:xy(40,-65+rowheight*startrow)
			self:diffuse(color("0.501,0.501,0.501"))

		end
	end
} 


af[#af+1] = LoadFont("Common Normal")..{
	Name="QuestText",
	InitCommand=function(self)
		self:zoom(0.8)
		--self:valign(1)
	end,
	RpgQuestsCommand=function(self,params)
		if #params.box_quests > 0 then
			text = params.box_quests[1]
			-- There's probably a better way to do this
			for i=2,#params.box_quests do
				text = text .. "\n" .. params.box_quests[i]
			end
			self:settext(text)
			self:vertalign('VertAlign_Top')
			self:vertspacing(-5)
			startrow = (#params.box_progress > 0 and 2 or 1) + math.ceil(#params.box_stats/2)
			self:y(-65+rowheight*startrow)
			self:maxwidth(180)
		end
	end
} 


return af