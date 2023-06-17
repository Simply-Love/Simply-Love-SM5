-- assume that all human players failed
local failed = true

-- loop through all available human players
for player in ivalues(GAMESTATE:GetHumanPlayers()) do
	-- if any of them passed, we want to display the "cleared" graphic
	if not STATSMAN:GetCurStageStats():GetPlayerStageStats(player):GetFailed() then
		failed = false
	end
end

if ThemePrefs.Get("VisualStyle") ~= "SRPG7" then
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
	local img = failed and THEME:GetPathG("","_VisualStyles/SRPG7/Banner-Failed.png") or THEME:GetPathG("","_VisualStyles/SRPG7/Banner-Passed.png")

	local af = Def.ActorFrame{
		InitCommand=function(self)
			self:xy(_screen.cx, 100)
		end,
		Def.Quad{
			InitCommand=function(self)
				-- 100 + 140 = 240. SL is 480 tall, so 240 is the center.
				self:FullScreen():xy(0, 140):diffuse(color("#000000")):diffusealpha(0.9)
			end,
			OnCommand=function(self)
				self:sleep(4.5)
						:decelerate(0.5):diffusealpha(0)
			end
		},

		-- Backgrounds
		Def.Quad{
			InitCommand=function(self)
				self:zoomto(0, 60):diffuse(color("#000000"))
			end,
			OnCommand=function(self)
				self:sleep(1)
						:decelerate(0.25):zoomto(_screen.w - 150, 60)
						:sleep(3)
						:decelerate(0.5):diffusealpha(0)
			end,
		},
		Def.Quad{
			InitCommand=function(self)
				local c = failed and Color.Red or Color.Yellow
				self:zoomto(0, 45):diffusecolor(c):diffusealpha(0.3):addy(7)
			end,
			OnCommand=function(self)
				local c = failed and color("#292929") or color("#292929")
				self:sleep(1)
						:decelerate(0.25):zoomto(_screen.w - 150, 45):diffusecolor(c)
						:sleep(3)
						:decelerate(0.5):diffusealpha(0)
			end,
		},
		Def.Quad{
			InitCommand=function(self)
				local c = failed and Color.Red or Color.Yellow
				self:zoomto(0, 30):diffusecolor(c):diffusealpha(0.3)
			end,
			OnCommand=function(self)
				local c = failed and color("#292929") or color("#292929")
				self:sleep(1)
						:decelerate(0.25):zoomto(_screen.w - 150, 30):diffusecolor(c)
						:sleep(3)
						:decelerate(0.5):diffusealpha(0)
			end,
		},

		-- Top line
		Def.Quad{
			InitCommand=function(self)
				local c = failed and color("#959c96") or color("#d19213")
				self:zoomto(0, 2):diffuse(c):addy(-30)
			end,
			OnCommand=function(self)
				self:sleep(1)
						:decelerate(0.25):zoomto(_screen.w - 150, 2)
						:sleep(3)
						:decelerate(0.5):diffusealpha(0)
			end,
		},
		-- Bottom line
		Def.Quad{
			InitCommand=function(self)
				local c = failed and color("#6e0000") or color("#d19213")
				self:zoomto(0, 2):diffuse(c):addy(30)
			end,
			OnCommand=function(self)
				self:sleep(1)
						:decelerate(0.25):zoomto(_screen.w - 400, 2)
						:sleep(3)
						:decelerate(0.5):diffusealpha(0)
			end,
		},

		-- Sprites
		Def.Sprite{
			Texture=img,
			InitCommand=function(self)
				self:zoom(0.5):zoomy(0)
			end,
			OnCommand=function(self)
				local c = failed and Color.Red or Color.Yellow
				local offset = failed and 75 or WideScale(75, 105)
				self:sleep(1)
						:linear(0.05):zoomy(0.5):diffuse(c)
						:decelerate(0.2):x(-_screen.w / 2 + offset):diffuse(color(0, 0, 0, 0))
						:sleep(3)
						:decelerate(0.5):diffusealpha(0)
			end,
		},
		Def.Sprite{
			Texture=img,
			InitCommand=function(self)
				self:rotationy(180):zoom(0.5):zoomy(0)
			end,
			OnCommand=function(self)
				local c = failed and Color.Red or Color.Yellow
				local offset = failed and 75 or WideScale(75, 105)
				self:sleep(1)
						:linear(0.05):zoomy(0.5):diffuse(c)
						:decelerate(0.2):x(_screen.w / 2 - offset):diffuse(color(0, 0, 0, 0))
						:sleep(3)
						:decelerate(0.5):diffusealpha(0)
			end,
		},
	}

	if failed then
		af[#af+1] = Def.Sprite{
			Texture=THEME:GetPathG("", "_VisualStyles/SRPG7/NoEscape.png"),
			InitCommand=function(self)
				self:zoom(0.3):zoomx(0.26):diffusealpha(0)
			end,
			OnCommand=function(self)
				self:sleep(1):diffusealpha(1)
						:linear(3.25):zoomx(0.3)
						:decelerate(0.5):diffusealpha(0)
				SOUND:PlayOnce(THEME:GetPathS("", "SRPG7-Failed.ogg"))
			end
		}
		af[#af+1] = Def.Sprite{
			Texture=THEME:GetPathG("", "_VisualStyles/SRPG7/Death.mp4"),
			InitCommand=function(self)
				self:zoom(0.45):y(220):blend("BlendMode_Add")
			end,
			OnCommand=function(self)
				self:sleep(4.5)
						:linear(0.5):diffusealpha(0)
			end,
		}
	else
		local image = THEME:GetPathG("", "_VisualStyles/SRPG7/MonsterVanquished.png")

		local bosses = {
			["e52ab3c368462981"]="RaidBossVanquished.png",
			["2cef87c3665147a5"]="RaidBossVanquished.png",
			["17a52e081e74857e"]="RaidBossVanquished.png",
			["33ff572412b63ac0"]="RaidBossVanquished.png",
			["100ea9df724484aa"]="RaidBossVanquished.png",
			["96bdaba7a0310912"]="RaidBossVanquished.png",
			["64d6272b10a0333d"]="RaidBossVanquished.png",
			["b537bc44519c5c08"]="RaidBossVanquished.png",
			["da61d81de440979c"]="RaidBossVanquished.png",
			["fe05440c9e2a75cc"]="RaidBossVanquished.png",
			["fbe6e5cd839f4d19"]="RaidBossVanquished.png",
			["28ebefeb4a4dc6f7"]="RaidBossVanquished.png",

			["da01b926476f9a8c"]="GodVanquished.png",
			["9a7a415331832c1a"]="GodVanquished.png",
			["9d8bd02b2620a03b"]="GodVanquished.png",
		}

		local found_boss = false
		for player in ivalues(GAMESTATE:GetHumanPlayers()) do
			local pn = ToEnumShortString(player)
			local chartHash = SL[pn].Streams.Hash
			if bosses[chartHash] ~= nil then
				image = THEME:GetPathG("", "_VisualStyles/SRPG7/"..bosses[chartHash])
				found_boss = true
				break
			end
		end

		if not found_boss and not GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentSong():GetLastSecond() > 16 * 60 then
			image = THEME:GetPathG("", "_VisualStyles/SRPG7/HorrorVanquished.png")
		end

		af[#af+1] = Def.Sprite{
			Texture=image,
			InitCommand=function(self)
				self:zoom(0.25):zoomx(0.2):diffusealpha(0):addy(5)
			end,
			OnCommand=function(self)
				self:sleep(1):diffusealpha(1):queuecommand("Next")
			end,
			NextCommand=function(self)
				self:linear(3.25):zoomx(0.25)
						:decelerate(0.5):diffusealpha(0)
				SOUND:PlayOnce(THEME:GetPathS("", "SRPG7-Passed.ogg"))
			end
		}
		af[#af+1] = Def.Sprite{
			Texture=THEME:GetPathG("", "_VisualStyles/SRPG7/Cleared.mp4"),
			InitCommand=function(self)
				self:zoom(0.9):y(260):blend("BlendMode_Add"):croptop(0.2):cropbottom(0.2):diffusealpha(0)
			end,
			OnCommand=function(self)
				self:linear(0.5):diffusealpha(1)
						:sleep(4)
						:linear(0.5):diffusealpha(0)
			end,
		}

	end

	return af
end