-- If you pass a quest in SRPG6, it will display the quests passed on the evaluation screen

-- We only want to show this info if there's space (there won't be space in 2 player mode)
if #GAMESTATE:GetHumanPlayers() ~= 1 then return end

local player = ...
local pn = ToEnumShortString(player)
local af = Def.ActorFrame{
	Name="RPGQuest"..pn,
	InitCommand=function(self)
		self:visible(false)
		self:y(110)
		self:x(380 * (player == PLAYER_1 and 1 or -1))
	end,
	RpgQuestsCommand=function(self,params)
		self:visible(true)
		self:GetChild("QuestText"):playcommand("Set",params)
	end
}

-- Draw border Quad
af[#af+1] = Def.Quad {
	InitCommand=function(self)
		self:zoomto(155,140)
		self:diffuse(color("1,0.972,0.792,1"))
	end
}

-- Draw background Quad
af[#af+1] = Def.Quad {
	InitCommand=function(self)
		self:zoomto(153,138)
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

af[#af+1] = LoadFont("Common Normal")..{
	Name="QuestText",
	Text="",
	InitCommand=function(self)
		self:zoom(0.8)
		--self:valign(1)
	end,
	RpgQuestsCommand=function(self,params)
		text = params.questsabbr[1]
		-- There's probably a better way to do this
		for i=2,#params.questsabbr do
			text = text .. "\n" .. params.questsabbr[i]
		end
		self:settext(text)		
		self:maxwidth(180)
	end
} 


return af