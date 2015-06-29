local EasterEggs = Def.ActorFrame{}


local song = GAMESTATE:GetCurrentSong()
local MainTitle = song:GetDisplayMainTitle()
local SubTitle = song:GetDisplaySubTitle()
local SongDir = song:GetSongDir()

-- filepath is nil by default
local filepath


-- attempt to set a filepath based on certain conditions...
if MainTitle == "Escape From The City" and SubTitle == "Ca$h Ca$h RMX" then
	filepath = SongDir.."EasterEgg.ogg"
end


-- if we have a filepath, load an ActorSound :)
if filepath then

	EasterEggs[#EasterEggs+1] = LoadActor(filepath)..{
		Name="EasterEggSound",
		OnCommand=function(self) self:play() end,
		OffCommand=function(self) self:stop() end
	}
	
end

return EasterEggs