local af = Def.ActorFrame{
InitCommand=function(self) self:sleep(5) end,

PlayRandomWRSoundMessageCommand=function(self)
	local Files = FILEMAN:GetDirListing(THEME:GetCurrentThemeDirectory() .. '/Sounds/WRSounds/', false, true)
	local Sounds = {}
	for file in ivalues(Files) do
		local extension = file:match('[.](.*)$')
		if extension == 'ogg' or extension == 'mp3' then
			Sounds[#Sounds+1] = file
		end
	end
	self:sleep(2)

	-- don't try to play a sound if the folder is empty.
	if #Sounds ~= 0 then
		RandomSound = Sounds[math.random(#Sounds)]
		SOUND:PlayOnce(RandomSound)
	end
end,

}

return af