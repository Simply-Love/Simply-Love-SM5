-- assume that all human players failed
local failed = true
SL.Global.Restarts = 0

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

		local bosses = {
			["e25513cb3c801604"]="LegendFelled.png",
			["be1811d125b4b9d5"]="LegendFelled.png",
			["945ec467c0b8fd94"]="LegendFelled.png",
			["e410d5bf872d5f37"]="LegendFelled.png",
			["e61476eec77277ca"]="LegendFelled.png",
			["21a111709f4416b3"]="LegendFelled.png",
			["ccb5ff37f938b057"]="LegendFelled.png",
			["65910d53c611f328"]="LegendFelled.png",
			["12031d8f99c8b88c"]="LegendFelled.png",
			["24a05523a0131b20"]="LegendFelled.png",
			["24a05523a0131b20"]="LegendFelled.png",

			["2184afe998acc7a5"]="GodSlain.png",
			["bd80236dc1de432f"]="GodSlain.png",
			["f56588cee23985ed"]="GodSlain.png",
			["eb20a2c5f6674882"]="GodSlain.png",
		}

		local found_boss = false
		for player in ivalues(GAMESTATE:GetHumanPlayers()) do
			local pn = ToEnumShortString(player)
			local chartHash = SL[pn].Streams.Hash
			if bosses[chartHash] ~= nil then
				image = THEME:GetPathG("", "_VisualStyles/SRPG6/"..bosses[chartHash])
				found_boss = true
				break
			end
		end

		if not found_boss and not GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentSong():GetLastSecond() > 16 * 60 then
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