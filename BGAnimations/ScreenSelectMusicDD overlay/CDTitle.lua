--Don't bother if this is Course mode
--if GAMESTATE:IsCourseMode() then return end

local currentsong = GAMESTATE:GetCurrentSong()
local HasCDTitle = currentsong:HasCDTitle()
local blank = THEME:GetPathG("", "_blank.png")
local CDTitlePath

if CDTitlePath == blank or CDTitlePath == nil then
	if HasCDTitle then
		CDTitlePath = GAMESTATE:GetCurrentSong():GetCDTitlePath()
	else
		CDTitlePath = blank
	end
	if CDTitlePath == nil then
		CDTitlePath = blank
	elseif HasCDTitle then
		CDTitlePath = GAMESTATE:GetCurrentSong():GetCDTitlePath()
	else
		CDTitlePath = blank
	end
end

t = Def.ActorFrame{
	InitCommand=function(self)	
	end,
	LoadActor(CDTitlePath)..{
		InitCommand=function(self) 
			local Height = self:GetHeight()
			local Width = self:GetWidth()
			local dim1, dim2=math.max(Width, Height), math.min(Width, Height)
			local ratio=math.max(dim1/dim2, 2)
			local toScale = Width > Height and Width or Height
			self:zoom(22/toScale * ratio)
			self:xy(SCREEN_CENTER_X+110,SCREEN_CENTER_Y-92)
			self:diffusealpha(0)
		end,
		OnCommand=function(self) 
			self:decelerate(0.4)
			self:diffusealpha(1) 
		end,
		OffCommand=function(self)
			self:decelerate(0.2)
			self:zoomx(0)
			self:zoomy(0)
		end,
		SetCommand=function(self)
			self:Draw(CDTitlePath)
		end,
		UpdateCDTitleMessageCommand=function(self)
			if CDTitlePath == blank or CDTitlePath == nil then
				if HasCDTitle then
					CDTitlePath = GAMESTATE:GetCurrentSong():GetCDTitlePath()
				else
					CDTitlePath = blank
				end
				if CDTitlePath == nil then
					CDTitlePath = blank
				elseif HasCDTitle then
					CDTitlePath = GAMESTATE:GetCurrentSong():GetCDTitlePath()
				else
					CDTitlePath = blank
				end
			end
			self:queuecommand("Set")
		end
	},
}

return t