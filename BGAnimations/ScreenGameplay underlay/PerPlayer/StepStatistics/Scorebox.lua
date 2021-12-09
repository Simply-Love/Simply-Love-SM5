local player = ...
local pn = ToEnumShortString(player)
local n = player==PLAYER_1 and "1" or "2"

local border = 5
local width = 162
local height = 80

local cur_style = 0
local num_styles = 2

local loop_seconds = 5
local transition_seconds = 1

local all_data = {}

-- Initialize the all_data object.
for i=1,num_styles do
	local data = {
		["has_data"]=false,
		["scores"]={}
	}
	local scores = data["scores"]
	for i=1,5 do
		scores[#scores+1] = {
			["rank"]="",
			["name"]="",
			["score"]="",
			["isSelf"]=false,
			["isRival"]=false
		}
	end
	all_data[#all_data + 1] = data
end

-- Checks to see if any data is available.
local HasData = function(idx)
	return all_data[idx+1] and all_data[idx+1].has_data
end

local SetScoreData = function(data_idx, score_idx, rank, name, score, isSelf, isRival)
	all_data[data_idx].has_data = true

	local score_data = all_data[data_idx]["scores"][score_idx]
	score_data.rank = tostring(rank)
	score_data.name = name
	score_data.score = tostring(score)
	score_data.isSelf = isSelf
	score_data.isRival = isRival
end

local LeaderboardRequestProcessor = function(res, master)
	if res == nil then
		SetScoreData(1, 1, "", "Timed Out", "", false, false)
		master:queuecommand("Check")
		return
	end

	local playerStr = "player"..n
	local data = res["status"] == "success" and res["data"] or nil

	-- First check to see if the leaderboard even exists.
	if data and data[playerStr] then
		if data[playerStr]["gsLeaderboard"] then
			local numEntries = 0
			for entry in ivalues(data[playerStr]["gsLeaderboard"]) do
				numEntries = numEntries + 1
				SetScoreData(1, numEntries,
								tostring(entry["rank"]),
								entry["name"],
								string.format("%.2f", entry["score"]/100),
								entry["isSelf"],
								entry["isRival"])
			end

			if numEntries == 0 then
				if data[playerStr]["isRanked"] then
					SetScoreData(1, 1, "", "No Scores", "", false, false)
				else
					if not data[playerStr]["rpg"] and not data[playerStr]["rpg"]["rpgLeaderboard"] then
						SetScoreData(1, 1, "", "Chart Not Ranked", "", false, false)
					end
				end
			end
		end

		if data[playerStr]["rpg"] then
			local numEntries = 0
			if data[playerStr]["rpg"]["rpgLeaderboard"] then
				for entry in ivalues(data[playerStr]["rpg"]["rpgLeaderboard"]) do
					numEntries = numEntries + 1
					SetScoreData(2, numEntries,
									tostring(entry["rank"]),
									entry["name"],
									string.format("%.2f", entry["score"]/100),
									entry["isSelf"],
									entry["isRival"])
				end
			end
			if numEntries == 0 then
				SetScoreData(2, 1, "", "No Scores", "", false, false)
			end
		end
 	end
	 master:queuecommand("Check")
end

local af = Def.ActorFrame{
	Name="ScoreBox"..pn,
	InitCommand=function(self)
		self:xy(70 * (player==PLAYER_1 and 1 or -1), -115)
	end,
	CheckCommand=function(self)
		self:queuecommand("Loop")
	end,
	LoopCommand=function(self)
		local start = cur_style

		cur_style = (cur_style + 1) % num_styles
		while cur_style ~= start do
			-- Make sure we have the next set of data.
			if HasData(cur_style) then
				break
			end
			cur_style = (cur_style + 1) % num_styles
		end
		-- Loop only if there's something new to loop to.
		if start ~= cur_style then
			SM("Looping")
			self:sleep(loop_seconds):queuecommand("Loop")
		end
	end,

	RequestResponseActor("Leaderboard", loop_seconds, 0, 0)..{
		OnCommand=function(self)
			local sendRequest = false
			local data = {
				action="groovestats/player-leaderboards",
				maxLeaderboardResults=5,
			}
			if SL[pn].ApiKey ~= "" then
				data["player"..n] = {
					chartHash=SL[pn].Streams.Hash,
					apiKey=SL[pn].ApiKey
				}
				sendRequest = true
			end

			if sendRequest then
				self:GetParent():GetChild("Name1"):settext("Loading...")
				MESSAGEMAN:Broadcast("Leaderboard", {
					data=data,
					args=self:GetParent(),
					callback=LeaderboardRequestProcessor
				})
			end
		end
	},

	-- Outline
	Def.Quad{
		Name="Outline",
		InitCommand=function(self)
			self:diffuse(color("#007b85")):setsize(width + border, height + border)
		end,
		LoopCommand=function(self)
			if cur_style == 0 then
				self:linear(transition_seconds):diffuse(color("#007b85"))
			elseif cur_style == 1 then
				self:linear(transition_seconds):diffuse(color("#aa886b"))
			end
		end
	},
	-- Main body
	Def.Quad{
		Name="Outline",
		InitCommand=function(self)
			self:diffuse(color("#454545")):setsize(width, height)
		end,
	},
	-- GrooveStats Logo
	Def.Sprite{
		Texture=THEME:GetPathG("", "GrooveStats.png"),
		Name="GrooveStatsLogo",
		InitCommand=function(self)
			self:zoom(0.8):diffusealpha(0.4)
		end,
		LoopCommand=function(self)
			if cur_style == 0 then
				self:linear(transition_seconds):diffusealpha(0.4)
			elseif cur_style == 1 then
				self:linear(transition_seconds):diffusealpha(0)
			end
		end
	},
	-- SRPG Logo
	Def.Sprite{
		Texture=THEME:GetPathG("", "_VisualStyles/SRPG5/logo_main (doubleres).png"),
		Name="SRPG5Logo",
		InitCommand=function(self)
			self:diffusealpha(0.4):zoom(0.24):addy(-1):diffusealpha(0)
		end,
		LoopCommand=function(self)
			if cur_style == 0 then
				self:linear(transition_seconds):diffusealpha(0)
			elseif cur_style == 1 then
				self:linear(transition_seconds):diffusealpha(0.4)
			end
		end
	},

}

for i=1,5 do
	local y = -height/2 + 16 * i - 8
	local zoom = 0.87
	-- Rank 1 gets a crown.
	if i == 1 then
		af[#af+1] = Def.Sprite{
			Name="Rank"..i,
			Texture=THEME:GetPathG("", "crown.png"),
			InitCommand=function(self)
				self:zoom(0.07):xy(-width/2 + 12, y):diffusealpha(0)
			end,
			LoopCommand=function(self)
				self:linear(transition_seconds/2):diffusealpha(0):queuecommand("Set")
			end,
			SetCommand=function(self)
				local score = all_data[cur_style+1]["scores"][i]
				if score.rank ~= "" then
					self:linear(transition_seconds/2):diffusealpha(1)
				end
			end
		}
	else
		af[#af+1] = LoadFont("Common Normal")..{
			Name="Rank"..i,
			Text="",
			InitCommand=function(self)
				self:diffuse(Color.White):xy(-width/2 + 20, y):maxwidth(20):horizalign(right):zoom(zoom)
			end,
			LoopCommand=function(self)
				self:linear(transition_seconds/2):diffusealpha(0):queuecommand("Set")
			end,
			SetCommand=function(self)
				local score = all_data[cur_style+1]["scores"][i]
				self:settext(score.rank)
				self:linear(transition_seconds/2):diffusealpha(1)
			end
		}
	end

	af[#af+1] = LoadFont("Common Normal")..{
		Name="Name"..i,
		Text="",
		InitCommand=function(self)
			self:diffuse(Color.White):xy(-width/2 + 25, y):maxwidth(110):horizalign(left):zoom(zoom)
		end,
		LoopCommand=function(self)
			self:linear(transition_seconds/2):diffusealpha(0):queuecommand("Set")
		end,
		SetCommand=function(self)
			local score = all_data[cur_style+1]["scores"][i]
			local clr = Color.White
			if score.isSelf then
				clr = color("#a1ff94")
			elseif score.isRival then
				clr = color("#c29cff")
			end
			self:settext(score.name)
			self:linear(transition_seconds/2):diffusealpha(1):diffuse(clr)
		end
	}

	af[#af+1] = LoadFont("Common Normal")..{
		Name="Score"..i,
		Text="",
		InitCommand=function(self)
			self:diffuse(Color.White):xy(-width/2 + 160, y):horizalign(right):zoom(zoom)
		end,
		LoopCommand=function(self)
			self:linear(transition_seconds/2):diffusealpha(0):queuecommand("Set")
		end,
		SetCommand=function(self)
			local score = all_data[cur_style+1]["scores"][i]
			local clr = Color.White
			if score.isSelf then
				clr = color("#a1ff94")
			elseif score.isRival then
				clr = color("#c29cff")
			end
			self:settext(score.score)
			self:linear(transition_seconds/2):diffusealpha(1):diffuse(clr)
		end
	}
end
return af