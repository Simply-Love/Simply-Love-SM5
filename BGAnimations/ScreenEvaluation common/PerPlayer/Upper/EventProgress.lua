-- File to handle Event specific (ITL/RPG) progress such as song scores, ranking points, quest completions, etc.

-- Unsure if it's possible to detect whether the chat module pane is active, so check that the file exists
local chatModule = FILEMAN:DoesFileExist(THEME:GetCurrentThemeDirectory() .. "Modules/TwitchChat.lua")

-- If there is no space for the ITL box, don't show it
if not IsUsingWideScreen() and (chatModule or #GAMESTATE:GetHumanPlayers() ~= 1) then return end

local player = ...
local pn = ToEnumShortString(player)

local panes = 0

-- Default position is on the other player's upper area where the grade should be
local boxStart = {}
local box = {}
local logo = {}
boxStart["x"] = 381 * (player == PLAYER_1 and 1 or -1)
boxStart["y"] = 109
box["x"] = 157
box["y"] = 143
logo["y"] = 40
logo["zoom"] = 0.15
local width = 180
local starty = -60

-- If that is taken by a player or the twitch chat module, put it to the side in widescreen mode
if IsUsingWideScreen() and (chatModule or #GAMESTATE:GetHumanPlayers() > 1) then
	boxStart["x"] = 210 * (player == PLAYER_1 and -1 or 1)
	boxStart["y"] = 274
	box["x"] = 120
	box["y"] = 180
	logo["y"] = 40
	logo["zoom"] = 0.25
	width = 140
	starty = -80
end

-- RPG
-- Display RPG progress such as song score, rate mod, skill points, quests, etc

-- Currently disabled to get ITL functionality out. Will work on it for RPG7
local af = Def.ActorFrame{
	Name="RPGQuest"..pn,
	InitCommand=function(self)
		self:visible(false)
		self:xy(boxStart["x"],boxStart["y"])
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
		self:zoomto(box["x"],box["y"])
		self:diffuse(color("1,0.972,0.792,1"))
	end
}

-- Draw background Quad
af[#af+1] = Def.Quad {
	InitCommand=function(self)
		self:zoomto(box["x"]-2,box["y"]-2)
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
		self:xy(-30,starty)		
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
		self:xy(30,starty)		
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
			self:y(starty+rowheight)
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
			self:maxwidth(width)
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
			self:maxwidth(width)
		end
	end
} 

-- ITL
-- Return ITL stats such as song score, TP/RP, etc.

local af2 = Def.ActorFrame{
	Name="ItlProgress"..pn,
	InitCommand=function(self)
		self:xy(boxStart["x"],boxStart["y"])
		self:visible(false)
	end,
	ItlDataReadyMessageCommand=function(self,params)
		-- Local stats first, this *should* happen after the currently played song is written to file, and before the api response is returned.
		if PROFILEMAN:IsPersistentProfile(player) and IsItlSong(player) and params.player == player then
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
		self:zoomto(box["x"],box["y"])
		self:diffuse(color("1,0.972,0.792,1"))
	end
}

-- Draw background Quad
af2[#af2+1] = Def.Quad {
	InitCommand=function(self)
		self:zoomto(box["x"]-2,box["y"]-2)
		self:diffuse(Color.Black)
	end
}

-- Use random logo to spice things up
local itlLogoDir = THEME:GetCurrentThemeDirectory() .. "Graphics/ITL Online 2023/"
logoFiles = findFiles(itlLogoDir,"png")
if #logoFiles > 0 then
	logoImage = logoFiles[math.random(#logoFiles)]
end

af2[#af2+1] = Def.Sprite {
	Texture=logoImage,
	InitCommand=function(self)
		self:zoom(logo["zoom"])
		self:diffusealpha(0.2)
		self:y(logo["y"])
	end
}

-- EX Score
af2[#af2+1] = LoadFont("Common Normal")..{
	Name="Score",
	InitCommand=function(self)
		self:zoom(0.8)
		self:xy(0,starty)
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
		self:xy(-30,starty+rowheight)
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
		self:xy(30,starty+rowheight)
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
		self:y(starty+rowheight*2)
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
		self:y(starty+rowheight*3)
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
		self:y(starty+rowheight*4)
	end,
	ItlStatsLocalCommand=function(self,params)
		self:settext("Songs played: " .. params.played)
	end
}

af2[#af2+1] = LoadFont("Common Normal")..{
	Name="QuestText",
	InitCommand=function(self)
		self:zoom(0.8)
		self:y(starty-10+rowheight*6)
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
			self:maxwidth(width)
		end
	end
} 

return af2