-- assume that all human players failed
local failed = true

-- loop through all available human players
for player in ivalues(GAMESTATE:GetHumanPlayers()) do
	-- if any of them passed, we want to display the "cleared" graphic
	if not STATSMAN:GetCurStageStats():GetPlayerStageStats(player):GetFailed() then
		failed = false
	end
end

if ThemePrefs.Get("VisualStyle") ~= "SRPG10" then
	local img = failed and "failed text.png" or "cleared text.png"

	return Def.ActorFrame{
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
	local totalTime = failed and 3 or 1
	local af = Def.ActorFrame{
		InitCommand=function(self)
			self:Center()
		end,
		OnCommand=function(self)
			self:sleep(totalTime - 0.5):linear(0.5):diffusealpha(0)
			if failed then
				SOUND:PlayOnce(THEME:GetPathG("", "_VisualStyles/SRPG10/Eval/Failed.ogg"))
			else
				SOUND:PlayOnce(THEME:GetPathG("", "_VisualStyles/SRPG10/Eval/Passed.ogg"))
			end
		end,
	}

	if failed then
		af[#af+1] = Def.Sprite{
			Texture=THEME:GetPathG("", "_VisualStyles/SRPG10/Eval/Paint.png"),
			InitCommand=function(self)
				self:zoomto(SCREEN_WIDTH + 350, SCREEN_HEIGHT + 200	)
			end,
			OnCommand=function(self)
				self:decelerate(0.75):zoomto(SCREEN_WIDTH+250, SCREEN_HEIGHT)
			end,
		}

		af[#af+1] = Def.Quad{
			InitCommand=function(self) self:zoomto(SCREEN_WIDTH, SCREEN_HEIGHT):diffuse(Color.Black):diffusealpha(0.8) end,
			OnCommand=function(self) self:sleep(1.5):linear(0.375):diffusealpha(1) end,
		}

		af[#af+1] = Def.Sprite{
			Texture=THEME:GetPathG("", "_VisualStyles/SRPG10/Eval/Red Lines.png"),
			InitCommand=function(self)
				self:zoom(480 / 1080):diffusealpha(0)
			end,
			OnCommand=function(self)
				self:accelerate(0.1):diffusealpha(1)
			end,
		}

		af[#af+1] = Def.Sprite{
			Texture=THEME:GetPathG("", "_VisualStyles/SRPG10/Eval/Expedition Failed.png"),
			InitCommand=function(self)
				self:zoom(480 / 1080):diffusealpha(0)
			end,
			OnCommand=function(self)
				self:linear(0.375):diffusealpha(1)
			end,
		}
	else
		af[#af+1] = Def.Sprite{
			Texture=THEME:GetPathG("", "_VisualStyles/SRPG10/Eval/PassBG.png"),
			InitCommand=function(self)
				self:zoom(480 / 1080)
			end,
		}

		af[#af+1] = Def.Sprite{
			Texture=THEME:GetPathG("", "_VisualStyles/SRPG10/Eval/Gold Leaf Background.png"),
			InitCommand=function(self)
				self:zoom(480 / 1080)
			end,
			OnCommand=function(self)
				self:decelerate(0.1):zoom(0.5)
			end,
		}

		af[#af+1] = Def.Sprite{
			Texture=THEME:GetPathG("", "_VisualStyles/SRPG10/Eval/Victory.png"),
			InitCommand=function(self)
				self:zoom(0.5)
			end,
			OnCommand=function(self)
				self:decelerate(0.1):zoom(0.3)
			end,
		}
	end

	return af
end