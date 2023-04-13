-- This is used for tracking best rate mod in SRPG6 on the songwheel
-- TODO: 
-- Maybe load all rate mods at screen load instead of every time the MusicWheelItem loads?
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

local GottaGoFast=function(pn,rate)
	local shade = scale(rate,1.0,1.5,1,0)
	shade = string.format("%.3f",shade)
	local clr = "1,"..shade..","..shade..",1"
	if players == 2 and pn == "P2" then clr = shade..","..shade..",1,1" end
	return clr
end

ReadRpgFile = function(dir, song)
	local path = dir.. "SRPG6.rpg"	
	local f = RageFileUtil:CreateRageFile()
	local existing = ""
	local recordType
	local rate
	--local songrecord
	if FILEMAN:DoesFileExist(path) then
		-- Load the current contents of the file if it exists.
		if f:Open(path, 1) then
			existing = f:Read()
			f:Close()
			f:destroy()
			-- Check if the song record already exists
			-- remove some annoying characters that break lua string function for some reason???
			
			song = song:gsub("%W","_")


			songposition = string.find(existing,song)
			if songposition ~= nil then
				-- find position of next equals sign
				equals = string.find(existing,"=",songposition)
				-- find end of the line
				newline = string.find(existing,"\n",equals)
				-- if end of file, get the last 
				if newline == nil then newline = string.len(existing) end
				
				-- get the old rate and convert to number
				rate = string.sub(existing,equals+1,newline)
				rate = string.sub(rate,1,4)
				return rate
			end
		end
	end
end
	

local af = Def.ActorFrame {
	--Name="RPGP"..pn,
	InitCommand=function(self)
		local profile_slot = {
			[PLAYER_1] = "ProfileSlot_Player1",
			[PLAYER_2] = "ProfileSlot_Player2"
		}
		dir = PROFILEMAN:GetProfileDir(profile_slot[player])
	end,
	SetMessageCommand=function(self,params)
		if params.Type == "Song" and string.find(string.upper(params.Text), "STAMINA RPG 6") then
			local rate = ReadRpgFile(dir, params.Song:GetDisplayFullTitle())
			local song = params.Song
			local song = song:GetDisplayFullTitle()			
			--SM("Setting " .. pn .. " " .. params.Type .. " " .. params.Text .. " " .. song )
			if rate ~= nil then 
				self:playcommand("RpgRate",{pn=pn, rate=rate, song=song}) 
			else
				local song = ""
				if params.Song then song = params.Song:GetDisplayFullTitle() end
				--SM("Unsetting top " .. pn .. " " .. params.Type .. " " .. params.Text .. " " .. song)
				self:queuecommand("Unset") 
			end
		else
			local song = ""
			if params.Song then song = params.Song:GetDisplayFullTitle() end
			--SM("Unsetting bottom " .. pn .. " " .. params.Type .. " " .. params.Text .. " " .. song)
			self:queuecommand("Unset") 
		end
	end
}

af[#af+1] = Def.Quad {
	InitCommand=function(self)
		self:visible(false)
	end,
	RpgRateCommand=function(self)
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

af[#af+1] = LoadFont(ThemePrefs.Get("ThemeFont") .. " numbers")..{
	InitCommand=function(self)
		self:visible(false)
	end,
	RpgRateCommand=function(self,params)
		self:visible(true)
		local x,y,zoom,col
		if ar < 1.4 then -- caveman moment
			zoom = 0.1
			x = (player == PLAYER_1 and 27 or 9)
			y = -1
			col = -18
		else 
			zoom = scale(GetScreenAspectRatio(), 16/10, 16/9, 0.15, 0.2)
			y = scale(GetScreenAspectRatio(), 16/10, 16/9, -3, -3)
			x = (player == PLAYER_1 and scale(GetScreenAspectRatio(), 16/10, 16/9, 40, 48) or scale(GetScreenAspectRatio(), 16/10, 16/9, 13, 16))
			col = scale(GetScreenAspectRatio(), 16/10, 16/9, -23, -26)
		end

		self:zoom(zoom)
		self:xy(x,y)
		self:settext(params.rate)
		clr = GottaGoFast(pn,params.rate)
		self:diffuse(color(clr))
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
