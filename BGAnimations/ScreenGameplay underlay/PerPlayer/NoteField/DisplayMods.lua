local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers
local options = GAMESTATE:GetPlayerState(player):GetPlayerOptions("ModsLevel_Preferred")

if SL.Global.GameMode == "Casual" or GAMESTATE:IsCourseMode() then return end

-- For tournament packs that have No CMOD rules 
local song = GAMESTATE:GetCurrentSong()
local song_dir = song:GetSongDir()
local group = string.lower(song:GetGroupName())
local tourneyPack = false
local tourneyPacks = {"itl", "rip"}
for pack in ivalues(tourneyPacks) do
	if string.find(group,pack) ~= nil then tourneyPack = true end
end

-- Rounding for X mod
local round = function(number)
	local str = string.format("%.2f",number)
	if str:sub(-3) == ".00" 	then return string.format("%.f",number) end
	if str:sub(-1) == "0" 		then return string.format("%.1f",number) end	
	return str	
end

local life = GetLifeDifficulty()
local LifeDiff = nil
if life ~= 4 then
	LifeDiff = "Life " .. life
end

local Perspective 
if options:Overhead() 	then Perspective = "Overhead" 	end
if options:Hallway() 	then Perspective = "Hallway" 	end
if options:Distant() 	then Perspective = "Distant" 	end
if options:Incoming() 	then Perspective = "Incoming" 	end
if options:Space() 		then Perspective = "Space" 		end

local SpeedMod = mods.SpeedModType .. mods.SpeedMod .. " " .. Perspective
if mods.SpeedModType == "X" then SpeedMod = round(mods.SpeedMod) .. "x " .. Perspective end

local turnMods = {"Left","Right","Mirror","Shuffle","SuperShuffle"}
local turnMod 
for turn in ivalues(turnMods) do
	if options[turn](options) then turnMod = turn end
end

local NoMines = options:NoMines()

local FAPlus = SL.Global.GameMode == "FA+" and "FA+" or "ITG"
if SL.Global.GameMode == "ITG" then 
	if mods.ShowFaPlusWindow then
		if mods.SmallerWhite then FAPlus = "FA+ (10ms)" else FAPlus = "FA+ (15ms)" end
	end
else 
	if mods.SmallerWhite then FAPlus = FAPlus .. " (10ms)" else FAPlus = FAPlus .. " (15ms)" end
end

local disabledWindows = options:GetDisabledTimingWindows()
local disabled
if #disabledWindows > 0 then
	disabled = "No "
	local tns = "TapNoteScore" .. (SL.Global.GameMode=="ITG" and "" or SL.Global.GameMode)
	for i=1,#disabledWindows do
		disabled = disabled .. (i == 1 and (THEME:GetString(tns,disabledWindows[i]:sub(-2))) or ("/" .. THEME:GetString(tns,disabledWindows[i]:sub(-2))))
	end
end

local values = {}

if LifeDiff then
	table.insert(values,LifeDiff)
end
table.insert(values,SpeedMod)
table.insert(values,mods.Mini .. " Mini")
table.insert(values,turnMod)
table.insert(values,FAPlus)
table.insert(values,disabled)
if NoMines then table.insert(values,"Mines Off") end


local af = Def.ActorFrame{
    InitCommand = function(self)
        self:xy(GetNotefieldX(player), SCREEN_HEIGHT/4*1.3)
    end,
	OnCommand=function(self)
		self:sleep(5):decelerate(0.5):diffusealpha(0)
	end
}

for i,text in ipairs(values) do
	af[#af+1] = Def.Quad {
		InitCommand=function(self)
			self:diffuse(Color.Black):diffusealpha(0.8)
			self:zoomto(125,15)
			self:y(15*(i-1))
		end
	}
	af[#af+1] = LoadFont("Common Normal")..{
		Text=text,
		InitCommand=function(self)
			self:y(15*(i-1))
			self:zoom(0.8)
			self:maxwidth(125)
		end,
	}
end

-- Tourney specific only
-- for tournament packs with rules, give a more obvious warning when cmod is on when it is not allowed
local subtitle = song:GetDisplaySubTitle()
if tourneyPack 
	and string.find(string.upper(subtitle), "(NO CMOD)") 
	and GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred"):CMod() then
		af[#af+1] = Def.ActorFrame{
			InitCommand=function(self)
				self:y(15+15*#values)
			end,
			Name="CModWarning",
			Def.Quad{
				Name="BGCmodWarning",
				InitCommand=function(self)
					self:diffuse(0,0,0,0.8)
						:x(0)
						:setsize(90, 30)
				end,
			},
			Def.BitmapText {
				Name="CModWarningText",
				Font="Common Normal",
				Text="CMod On",
				InitCommand=function(self)
					self:zoom(1.5)
						:diffuse(1,0,0,1)
						:horizalign(center)						
				end,
			}
		}
		
end


return af