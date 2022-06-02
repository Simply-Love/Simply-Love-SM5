-- assume that all human players failed
local failed = true

-- loop through all available human players
for player in ivalues(GAMESTATE:GetHumanPlayers()) do
	-- if any of them passed, we want to display the "cleared" graphic
	if not STATSMAN:GetCurStageStats():GetPlayerStageStats(player):GetFailed() then
		failed = false
	end
end

if ThemePrefs.Get("VisualStyle") ~= "SRPG6" then
	local img = failed and "failed text.png" or "cleared text.png"

	return Def.ActorFrame {
		Def.Quad{
			InitCommand=function(self) self:FullScreen():diffuse(Color.Black) end,
			OnCommand=function(self) self:sleep(0.2):linear(0.5):diffusealpha(0) end,
		},

		LoadActor(img)..{
			InitCommand=function(self) self:Center():zoom(0.8):diffusealpha(0) end,
			OnCommand=function(self) self:accelerate(0.4):diffusealpha(1):sleep(0.6):decelerate(0.4):diffusealpha(0) end
		}
	}
else
	local af = Def.ActorFrame {
		InitCommand=function(self)
			self:xy(_screen.cx, _screen.cy)
		end,
		Def.Quad{
			InitCommand=function(self)
				self:zoomto(_screen.w,  100):diffuse(Color.Black):diffusealpha(0):fadetop(0.2):fadebottom(0.2)
			end,
			OnCommand=function(self)
				self:linear(0.25):diffusealpha(0.7):sleep(2):linear(0.25):diffusealpha(0)
			end,
		},
	}

	if failed then
		af[#af+1] = Def.Sprite {
			Texture=THEME:GetPathG("", "_VisualStyles/SRPG6/YouDied.png"),
			InitCommand=function(self) self:zoom(0.36):diffusealpha(0) end,
			OnCommand=function(self)
				self:linear(0.25):diffusealpha(1):linear(2):zoom(0.38):linear(0.25):diffusealpha(0):zoom(0.39)
				SOUND:PlayOnce(THEME:GetPathS("", "SRPG6-YouDied.ogg"))
			end
		}
	else
		local image = THEME:GetPathG("", "_VisualStyles/SRPG6/EnemyFelled.png")
		if not GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentSong():GetLastSecond() > 16 * 60 then
			image = THEME:GetPathG("", "_VisualStyles/SRPG6/GreatEnemyFelled.png")
		end

		af[#af+1] = Def.Sprite {
			Texture=image,
			InitCommand=function(self) self:zoomx(0.4):zoomy(0.38):diffusealpha(0) end,
			OnCommand=function(self)
				self:linear(0.25):diffusealpha(0.15):decelerate(2):zoomx(0.44):linear(0.25):diffusealpha(0)
				SOUND:PlayOnce(THEME:GetPathS("", "SRPG6-EnemyFelled.ogg"))
			end
		}

		af[#af+1] = Def.Sprite {
			Texture=image,
			InitCommand=function(self) self:zoom(0.38):diffusealpha(0) end,
			OnCommand=function(self)
				self:linear(0.25):diffusealpha(1):linear(2):linear(0.25):diffusealpha(0)
			end
		}
	end

	return af
end