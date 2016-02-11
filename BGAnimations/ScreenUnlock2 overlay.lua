local path = getenv("NewlyUnlockedSong")
local t =  Def.ActorFrame{}

if path then
	
	local song = SONGMAN:FindSong(path)
	
	if song then
		
		-- attempt to find the banner for the song
		bannerpath = song:GetBannerPath()
		
		-- if a banner was found...
		if bannerpath then
			
			-- ... then display it!
			t[#t+1] = Def.Banner{
				Name="RewardBanner",
				InitCommand=cmd(xy, _screen.cx, _screen.cy-55; ),
				OnCommand=function(self)
					self:LoadFromSong(song)
					-- apply these after loading the banner
					self:setsize(418, 164)
					self:zoom(0.6)
				end
			}
		end
		
		-- regardless of banner or not-banner, display some reward text
		t[#t+1] = LoadFont("_miso")..{
			Name="RewardText",
			InitCommand=cmd(xy, _screen.cx, 110; zoom,1.25),
			OnCommand=function(self)
				self:settext("You have unlocked: "..path)
			end
		}

		-- this is a sound to be played upon a successful unlock
		t[#t+1] = LoadActor( THEME:GetPathS("", "_unlock.ogg")	)..{ Name="songUnlocked"; }	
		
		-- play that sound
		t.OnCommand=function(self)
			if song then
				self:GetChild("songUnlocked"):play()
			end
		end
	end	


-- otherwise, nothing was unlocked, and the path variable is nil	
else
	
	t[#t+1] = LoadFont("_miso")..{
		Name="FailureText",
		Text="Not quite...",
		InitCommand=cmd(xy, _screen.cx,_screen.cy-50; zoom,1.4)
	}

	-- this is a sound to be played upon a failure to unlock
	t[#t+1] = LoadActor( THEME:GetPathS("", "_unlockFail.ogg") )..{ Name="songNotUnlocked" }
	
	-- play that sound
	t.OnCommand=function(self)
		self:GetChild("songNotUnlocked"):play()
	end
end

return t