local P1 = GAMESTATE:IsHumanPlayer(PLAYER_1)
local P2 = GAMESTATE:IsHumanPlayer(PLAYER_2)	
local name1 = PROFILEMAN:GetPlayerName(0)
local name2 = PROFILEMAN:GetPlayerName(1)
local nsj = GAMESTATE:GetNumSidesJoined()

local avatar_dim  = 96
local avatar_path1 = GetPlayerAvatarPath(PLAYER_1)
local avatar_path2 = GetPlayerAvatarPath(PLAYER_2)

local Guest1 = ""
local Guest2 = ""

if name1 == "" then
	Guest1 = true
	else
	Guest1 = false
end

if name2 == "" then
	Guest2 = true
	else
	Guest2 = false
end

local file3 = THEME:GetPathB("ScreenSelectMusicDD","overlay/ProfileDisplay/default picture.png")

local function getInputHandler(actor, player)
	return (function(event)
		if event.GameButton == "Start" and event.PlayerNumber == player and not GAMESTATE:IsHumanPlayer(event.PlayerNumber) and not IsUsingWideScreen() then
			actor:visible(false)
		elseif event.GameButton == "Start" and event.PlayerNumber == player and not GAMESTATE:IsHumanPlayer(event.PlayerNumber) then
			actor:visible(true)
		end
	end)
end


local t = Def.ActorFrame{
	Name="DifficultyJawn",
	InitCommand=cmd(vertalign, top; draworder, 105),

--- background panes for player stats ------
Def.Quad{
		Name="ProfileBackground",
		InitCommand=function(self)
			self:visible(P1)
			self:xy(WideScale(_screen.cx-240,_screen.cx-294),WideScale(_screen.cy - 192,_screen.cy - 184))
			self:draworder(0)
			self:diffuse(color("#1e282f"))
				if IsUsingWideScreen() then
					self:zoomto(WideScale(160,267),WideScale(98,112))
					if Guest1 then
					self:y(WideScale(_screen.cy - 217,_screen.cy - 204.5))
					end
				elseif nsj == 1 then
					self:zoomto(320,82)
					self:horizalign(right)
					self:y(406)
					self:x(SCREEN_RIGHT)
				else
					self:visible(false)
				end
		end,
		OnCommand=function(self)
			SCREENMAN:GetTopScreen():AddInputCallback(getInputHandler(self, 'PlayerNumber_P1'))
		end
	},

Def.Quad{
		Name="ProfileBackground",
		InitCommand=function(self)
			self:visible(P2)
			self:xy(WideScale(_screen.cx+240,_screen.cx+294),WideScale(_screen.cy - 192,_screen.cy - 184))
			self:draworder(0)
			self:diffuse(color("#1e282f"))
			if IsUsingWideScreen() then
					self:zoomto(WideScale(160,267),WideScale(98,112))
					if Guest2 then
					self:y(WideScale(_screen.cy - 217,_screen.cy - 204.5))
					end
				elseif nsj == 1 then
					self:zoomto(320,82)
					self:y(406)
					self:horizalign(right)
					self:x(SCREEN_RIGHT)
				else
					self:visible(false)
				end
		end,
		OnCommand=function(self)
			SCREENMAN:GetTopScreen():AddInputCallback(getInputHandler(self, 'PlayerNumber_P2'))
		end
	},

 ---------------------------- Player 1's profile stats	-----------------------------
Def.BitmapText{
		Font="Miso/_miso",
		InitCommand=function(self)
			if IsUsingWideScreen() then
				self:diffuse(color("#FFFFFF"))
				self:visible(P1)
				self:horizalign(center)
				self:maxwidth(WideScale(159,266))
				self:x(WideScale(80,135))
				self:y(10)
				self:zoom(WideScale(0.75,0.9))
				if Guest1 then
					self:settext("Player 1's stats")
					self:x(WideScale(125,178))
				else
					self:settext(name1 .. "'s stats")
				end
			elseif nsj == 1 then
				self:diffuse(color("#FFFFFF"))
				self:visible(P1)
				self:horizalign(center)
				self:maxwidth(300)
				self:x(SCREEN_RIGHT - 119)
				self:y(372)
				self:zoom(0.8)
				if Guest1 then
					self:settext("Player 1's stats")
				else
					self:settext(name1 .. "'s stats")
				end
				
			else
				self:visible(false)
			end
		end,
		OnCommand=function(self)
			SCREENMAN:GetTopScreen():AddInputCallback(getInputHandler(self, 'PlayerNumber_P1'))
		end
	},
	
	
	
--- cute lil profile picture for the ladies ---	
Def.Sprite{
	Texture=avatar_path1 or file3,
	Name="ProfilePicture1",
	InitCommand=function(self)
		if IsUsingWideScreen() then
			self:visible(P1)
			self:zoomto(WideScale(72,91.2),WideScale(72,91.2))
			self:x(WideScale(36,46))
			self:y(WideScale(60,66))
			if Guest1 then 
				self:y(WideScale(36,46))
			end
		elseif nsj == 1 then
			self:visible(P1)
			self:zoomto(82,82)
			self:horizalign(left)
			self:x(SCREEN_RIGHT - 320)
			self:y(406)
		else
			self:visible(false)
		end
	end,
	OnCommand=function(self)
			SCREENMAN:GetTopScreen():AddInputCallback(getInputHandler(self, 'PlayerNumber_P1'))
		end
	},
	
	
--- Text to show that the player is on a guest profile rather than not having an avatar/profile picture
Def.BitmapText{
		Font="Miso/_miso",
		InitCommand=function(self)
			if IsUsingWideScreen() then
				self:diffuse(color("#FFFFFF"))
				self:visible(P1)
				self:horizalign(center)
				self:x(WideScale(39,47))
				self:y(WideScale(66,82))
				self:zoom(WideScale(0.75,0.9))
				if Guest1 then
					self:settext("GUEST")
				else
					self:visible(false)
				end
			elseif nsj == 1 then
				self:diffuse(color("#FFFFFF"))
				self:visible(P1)
				self:horizalign(center)
				self:x(SCREEN_RIGHT - 279)
				self:y(440)
				self:zoom(0.85)
				if Guest1 then
					self:settext("GUEST")
				else
					self:visible(false)
				end
				
			else
				self:visible(false)
			end
		end,
		OnCommand=function(self)
			SCREENMAN:GetTopScreen():AddInputCallback(getInputHandler(self, 'PlayerNumber_P1'))
		end
	},
	
	
---------------------------------- Player 2's profile stats	--------------------------------
Def.BitmapText{
		Font="Miso/_miso",
		InitCommand=function(self)
			if IsUsingWideScreen() then
				self:diffuse(color("#FFFFFF"))
				self:visible(P2)
				self:horizalign(center)
				self:maxwidth(WideScale(159,266))
				self:x(WideScale(560,725))
				self:y(10)
				self:zoom(WideScale(0.75,0.9))
				if Guest2 then
					self:settext("Player 2's stats")
					self:x(WideScale(590,772))
				else
					self:settext(name2 .. "'s stats")
				end
			elseif nsj == 1 then
				self:diffuse(color("#FFFFFF"))
				self:visible(P2)
				self:horizalign(center)
				self:maxwidth(300)
				self:x(SCREEN_RIGHT - 119)
				self:y(372)
				self:zoom(0.8)
				if Guest2 then
					self:settext("Player 2's stats")
				else
					self:settext(name2 .. "'s stats")
				end
			else
			self:visible(false)
			end
		end,
		OnCommand=function(self)
			SCREENMAN:GetTopScreen():AddInputCallback(getInputHandler(self, 'PlayerNumber_P2'))
		end
	},
	
	
--- cute lil profile picture for the ladies ---	
Def.Sprite{
	Texture=avatar_path2 or file3,
	Name="ProfilePicture2",
	InitCommand=function(self)
		if IsUsingWideScreen() then
			self:visible(P2)
			self:zoomto(WideScale(72,91.2),WideScale(72,91.2))
			self:x(WideScale(514,634))
			self:y(WideScale(60,66))
			if Guest2 then 
				self:y(WideScale(36,46))
			end
		elseif nsj == 1 then
			self:visible(P2)
			self:zoomto(82,82)
			self:horizalign(left)
			self:x(SCREEN_RIGHT - 320)
			self:y(406)
		else
		self:visible(false)
		end
	end,
	OnCommand=function(self)
			SCREENMAN:GetTopScreen():AddInputCallback(getInputHandler(self, 'PlayerNumber_P2'))
		end
	},
	
	--- Text to show that the player is on a guest profile rather than not having an avatar/profile picture
Def.BitmapText{
		Font="Miso/_miso",
		InitCommand=function(self)
			if IsUsingWideScreen() then
				self:diffuse(color("#FFFFFF"))
				self:visible(P2)
				self:horizalign(center)
				self:maxwidth(WideScale(159,266))
				self:x(WideScale(516,635))
				self:y(WideScale(66,82))
				self:zoom(WideScale(0.75,0.9))
				if Guest2 then
					self:settext("GUEST")
				else
					self:visible(false)
				end
			elseif nsj == 1 then
				self:diffuse(color("#FFFFFF"))
				self:visible(P2)
				self:horizalign(center)
				self:x(SCREEN_RIGHT - 279)
				self:y(440)
				self:zoom(0.8)
				if Guest2 then
					self:settext("GUEST")
				else
					self:visible(false)
				end
			else
			self:visible(false)
			end
		end,
		OnCommand=function(self)
			SCREENMAN:GetTopScreen():AddInputCallback(getInputHandler(self, 'PlayerNumber_P2'))
		end
	}
}



return t