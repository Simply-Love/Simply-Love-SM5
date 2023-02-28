-- This is used for tracking ITL points on the songwheel
-- TODO: 
-- Maybe load all points at screen load instead of every time the MusicWheelItem loads?
-- Screen needs to reload when new players join or else the layout is messed up
-- Doesn't display anything until you scroll the musicwheel at once

-- Notes
-- Works for 16:9, 16:10, 4:3 on 1,2 player and versus mode
-- I'm unsure whether it is readable on a 4:3 CRT
-- Design in 2 player mode could probably be improved

local player = ...
local pn = ToEnumShortString(player)
local players = #GAMESTATE:GetHumanPlayers()

local dir 

local ar = GetScreenAspectRatio()

local af = Def.ActorFrame {
	--Name="ITLP"..pn,
	InitCommand=function(self)
		local profile_slot = {
			[PLAYER_1] = "ProfileSlot_Player1",
			[PLAYER_2] = "ProfileSlot_Player2"
		}
		dir = PROFILEMAN:GetProfileDir(profile_slot[player])
	end,
	SetCommand=function(self,params)
		if params.Type == "Song" and string.find(string.upper(params.Text), "ITL ONLINE 2022") then
			local song = params.Song
			local hash = itlPathToHash(song:GetSongDir(), player)
			if hash ~= nil then
				local score = itlRead(hash, player)
				self:playcommand("ItlPoints",{pn=pn, clearType=score.clearType, points=score.points, maxPoints=score.max})
			else
				local song = ""
				if params.Song then song = params.Song:GetDisplayFullTitle() end
				--SM("Unsetting top " .. pn .. " " .. params.Type .. " " .. params.Text .. " " .. song)
				self:playcommand("Unset") 
			end
		else
			local song = ""
			if params.Song then song = params.Song:GetDisplayFullTitle() end
			--SM("Unsetting bottom " .. pn .. " " .. params.Type .. " " .. params.Text .. " " .. song)
			self:playcommand("Unset") 
		end
	end
}

af[#af+1] = Def.Quad {
	InitCommand=function(self)
		self:visible(false)
	end,
	ItlPointsCommand=function(self)
		if players == 2 and player == PLAYER_1 then
			self:zoomto(40,20)
			self:diffuse(Color("Black"))
			self:visible(true)
			self:x(-20)
		end
	end,
	UnsetCommand=function(self)
		self:visible(false)
	end
}

af[#af+1] = Def.Quad {
	InitCommand=function(self)
		self:visible(false)
	end,
	ItlPointsCommand=function(self, params)		
		clr = color("#0000CC")
		if params.clearType > 1 then
			clr = SL.JudgmentColors["FA+"][6-params.clearType]
		end
		self:diffuse(clr)
		self:zoomto(30,2)
		self:x(48)
		self:visible(true)
		if players == 2 and player == PLAYER_1 then
			self:zoomto(40,20)
			self:diffuse(Color("Black"))
			self:visible(true)
			self:x(-20)
		end
	end,
	UnsetCommand=function(self)
		self:visible(false)
	end
}

af[#af+1] = LoadFont("Wendy/_wendy monospace numbers")..{
	InitCommand=function(self)
		self:visible(false)
	end,
	ItlPointsCommand=function(self, params)
		self:visible(true)
		local x,y,zoom,col
		if ar < 1.4 then
			zoom = 0.1
			x = (player == PLAYER_1 and 27 or 9)
			y = -1
			col = -18
		else 
			zoom = scale(GetScreenAspectRatio(), 16/10, 16/9, 0.13, 0.15)
			y = scale(GetScreenAspectRatio(), 16/10, 16/9, -10, -10)
			x = (player == PLAYER_1 and scale(GetScreenAspectRatio(), 16/10, 16/9, 40, 48) or scale(GetScreenAspectRatio(), 16/10, 16/9, 13, 16))
			col = scale(GetScreenAspectRatio(), 16/10, 16/9, -23, -26)
		end
		
		self:zoom(zoom)
		self:xy(x,y)
		self:settext(params.points)
		clr = color("#0000CC")
		if params.clearType > 1 then
			clr = SL.JudgmentColors["FA+"][6-params.clearType]
		end
		self:diffuse(clr)
		if players == 2 then 
			self:addx((pn == "P1" and col*3 or col*1)) 
			self:zoom(0.1)
		end
	end,
	UnsetCommand=function(self)
		self:visible(false)
	end
}

af[#af+1] = LoadFont("Wendy/_wendy monospace numbers")..{
	InitCommand=function(self)
		self:visible(false)
	end,
	ItlPointsCommand=function(self, params)
		self:visible(true)
		local x,y,zoom,col
		if ar < 1.4 then
			zoom = 0.1
			x = (player == PLAYER_1 and 27 or 9)
			y = -1
			col = -18
		else 
			zoom = scale(GetScreenAspectRatio(), 16/10, 16/9, 0.13, 0.15)
			y = scale(GetScreenAspectRatio(), 16/10, 16/9, 5, 5)
			x = (player == PLAYER_1 and scale(GetScreenAspectRatio(), 16/10, 16/9, 40, 48) or scale(GetScreenAspectRatio(), 16/10, 16/9, 13, 16))
			col = scale(GetScreenAspectRatio(), 16/10, 16/9, -23, -26)
		end
		
		self:zoom(zoom)
		self:xy(x,y)
		self:settext(params.maxPoints)
		clr = color("#0000CC")
		if params.clearType > 1 then
			clr = SL.JudgmentColors["FA+"][6-params.clearType]
		end
		self:diffuse(clr)
		if players == 2 then 
			self:addx((pn == "P1" and col*3 or col*1)) 
			self:zoom(0.1)
		end
	end,
	UnsetCommand=function(self)
		self:visible(false)
	end
}

return af
