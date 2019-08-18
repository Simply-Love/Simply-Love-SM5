local player = ...
local pn = ToEnumShortString(player)

-- get the number of stages that were played
local NumStages = SL.Global.Stages.PlayedThisGame
local durationPerSong = 4

local af = Def.ActorFrame{}

for i=1,NumStages do
	local StepsOrTrail
	local SongOrCourse = SL.Global.Stages.Stats[i].song
	local stats = SL[pn].Stages.Stats[i]

	-- stats might exist for one player but not the other due to latejoin
	if stats then
		StepsOrTrail = stats.steps

		local args = { Player=player, RoundsAgo=(NumStages-(i-1)), SongOrCourse=SongOrCourse, StepsOrTrail=StepsOrTrail }
		local list = LoadActor(THEME:GetPathB("", "_modules/HighScoreList.lua"), args)

		list.Name = "HighScoreList" .. i .. ToEnumShortString(player)

		list.InitCommand=function(self)
			self:zoom(0.95):y(_screen.cy+60)
			self:x(_screen.cx + 160 * (player==PLAYER_1 and -1 or 1))
		end
		list.OnCommand=function(self)
			self:visible(false)
			self:sleep(durationPerSong * (i-1)):queuecommand("Display")
		end
		list.DisplayCommand=function(self)
			self:visible(true)
			self:sleep(durationPerSong):queuecommand("Wait")
		end
		list.WaitCommand=function(self)
			self:visible(false)
			self:sleep(durationPerSong * (NumStages-1)):queuecommand("Display")
		end

		af[#af+1] = list
	end
end

return af