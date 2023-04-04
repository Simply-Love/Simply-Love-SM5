-- File to handle Event specific (ITL/RPG) progress such as song scores, ranking points, quest completions, etc.
-- We only want to show this info if there's space (there won't be space in 2 player mode)
if #GAMESTATE:GetHumanPlayers() ~= 1 then return end

local player = ...
local pn = ToEnumShortString(player)

local panes = 0

-- RPG
-- Display RPG progress such as song score, rate mod, skill points, quests, etc

-- Currently disabled to get ITL functionality out. Will work on it for RPG7
local af = Def.ActorFrame{
	Name="RPGQuest"..pn,
	InitCommand=function(self)
		self:visible(false)
		self:y(109)
		self:x(381 * (player == PLAYER_1 and 1 or -1))
	end,
	RpgQuestsCommand=function(self,params)
		panes = panes + 1
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

-- ITL
-- Return ITL stats such as song score, TP/RP, etc.

local af2 = Def.ActorFrame{
	Name="ItlProgress"..pn,
	InitCommand=function(self)
		self:y(109)
		self:x(381 * (player == PLAYER_1 and 1 or -1))
		self:visible(false)
	end,
	ItlDataReadyMessageCommand=function(self)
		-- Local stats first, this *should* happen after the currently played song is written to file, and before the api response is returned.
		if PROFILEMAN:IsPersistentProfile(player) and IsItlSong(player) then
			self:visible(true)
			local profile = PROFILEMAN:GetProfile(player)
			local profileName = profile:GetDisplayName()		
			tp, rp, played = CalculateITLStats(player)
			
			hash = SL[pn].Streams.Hash
			ItlData = SL[pn].ITLData

			songPoints = ItlData["hashMap"][hash]["points"]
			songRank = ItlData["hashMap"][hash]["rank"]			
			songScore = ItlData["hashMap"][hash]["ex"]
						
			self:playcommand("ItlStatsLocal", {songScore=songScore, tp=tp, rp=rp, played=played, profileName=profileName,folderName=folderName, songPoints=songPoints, songRank=songRank})
		end
	end,
	ItlBoxCommand=function(self,params)
		-- If connected to GrooveStats, it will show the stats from the api
		self:visible(true)
		self:playcommand("ItlStatsOnline", params)
	end
}

-- Draw border Quad
af2[#af2+1] = Def.Quad {
	InitCommand=function(self)
		self:zoomto(157,143)
		self:diffuse(color("1,0.972,0.792,1"))
	end
}

-- Draw background Quad
af2[#af2+1] = Def.Quad {
	InitCommand=function(self)
		self:zoomto(155,141)
		self:diffuse(Color.Black)
	end
}

-- ITC logo
-- TODO change to the ITL 2023 logo
af2[#af2+1] = Def.Sprite {
	Texture=THEME:GetPathG("", "itl2023.png"),
	InitCommand=function(self)
		self:zoom(0.25)
		self:diffusealpha(0.2)
	end
}

-- EX Score
af2[#af2+1] = LoadFont("Common Normal")..{
	Name="Score",
	InitCommand=function(self)
		self:zoom(0.8)
		self:xy(0,-60)
	end,
	ItlStatsLocalCommand=function(self,params)
		self:settext(tostring(("%.2f"):format(params.songScore / 100)).. "%")
	end,
	ItlStatsOnlineCommand=function(self,params)
		self:settext(string.format("%.2f%%",params.box_score["score"]) .. " (" .. string.format("%+.2f%%",params.box_score["delta"]) ..  ")")
		if params.box_score["delta"] > 0 then self:diffuse(Color.Green)
		elseif params.box_score["delta"] < 0 then self:diffuse(Color.Red)
		end
	end
}

-- Points
af2[#af2+1] = LoadFont("Common Normal")..{
	Name="Points",
	InitCommand=function(self)
		self:zoom(0.8)
		self:xy(-30,-60+rowheight)
	end,
	ItlStatsLocalCommand=function(self,params)
		-- API response doesn't return the song points value. Use local score only
		-- This should be correct most of the time 
		self:settext(params.songPoints .. " pts")		
	end
}

-- Rank
af2[#af2+1] = LoadFont("Common Normal")..{
	Name="Rank",
	InitCommand=function(self)
		self:zoom(0.8)
		self:xy(30,-60+rowheight)
	end,
	ItlStatsLocalCommand=function(self,params)
		-- API response doesn't return the song rank. Use local calculated rank only
		-- This should be correct most of the time 
		self:settext("#" .. params.songRank)
	end
}

-- RP
af2[#af2+1] = LoadFont("Common Normal")..{
	Name="RP",
	InitCommand=function(self)
		self:zoom(0.8)
		self:y(-60+rowheight*2)
	end,
	ItlStatsLocalCommand=function(self,params)
		self:settext("RP: " .. params.rp)		
	end,
	ItlStatsOnlineCommand=function(self,params)
		self:settext("RP: " ..params.box_rp["curr"] .. " (+" .. params.box_rp["delta"] ..  ")")
		if params.box_rp["delta"] > 0 then self:diffuse(Color.Green) end
	end
}

-- TP
af2[#af2+1] = LoadFont("Common Normal")..{
	Name="TP",
	InitCommand=function(self)
		self:zoom(0.8)
		self:y(-60+rowheight*3)
	end,
	ItlStatsLocalCommand=function(self,params)
		self:settext("TP: " .. params.tp)
	end,
	ItlStatsOnlineCommand=function(self,params)
		self:settext("TP: " .. params.box_tp["curr"] .. " (+" .. params.box_tp["delta"] ..  ")")
		if params.box_tp["delta"] > 0 then self:diffuse(Color.Green) end
	end
}

-- Songs played
af2[#af2+1] = LoadFont("Common Normal")..{
	Name="Songs",
	InitCommand=function(self)
		self:zoom(0.8)
		self:y(-60+rowheight*4)
	end,
	ItlStatsLocalCommand=function(self,params)
		self:settext("Songs played: " .. params.played)
	end
}

af2[#af2+1] = LoadFont("Common Normal")..{
	Name="QuestText",
	InitCommand=function(self)
		self:zoom(0.8)
		self:y(-65+rowheight*5)
	end,
	ItlStatsOnlineCommand=function(self,params)
		if #params.box_quests > 0 then
			text = "Quests:\n"
			text = text .. params.box_quests[1]
			-- There's probably a better way to do this
			for i=2,#params.box_quests do
				text = text .. "\n" .. params.box_quests[i]
			end
			self:settext(text)
			self:vertalign('VertAlign_Top')
			self:vertspacing(-5)
			self:maxwidth(180)
		end
	end
} 

return af2