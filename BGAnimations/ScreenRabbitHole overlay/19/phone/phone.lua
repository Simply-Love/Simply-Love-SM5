-- I've gone for a walk in the snow.

local bgm_volume = 10
local _phone = { w=225, h=400 }

local af = Def.ActorFrame{
	OnCommand=function(self)
		self:sleep(6):queuecommand("Appear")
			:sleep(6)
			:smooth(1):diffuse(0,0,0,1)
			:queuecommand("Hide")
	end,
	HideCommand=function(self) self:hibernate(math.huge) end
}

-- sound
af[#af+1] = LoadActor("./buzz.ogg")..{
	OnCommand=function(self) self:sleep(0.5):queuecommand("Play") end,
	PlayCommand=function(self) self:play() end,
}

-- phone
af[#af+1] = Def.ActorFrame{

	-- wallpaper
	LoadActor("./tree.jpg")..{
		InitCommand=function(self) self:zoomto(200, 350):xy(_screen.cx, _screen.cy):diffuse(0,0,0,1) end,
		AppearCommand=function(self) self:sleep(0.25):smooth(0.75):diffuse(1,1,1,1) end,

	},

	Def.ActorFrame{
		InitCommand=function(self) self:diffuse(0,0,0,1) end,
		AppearCommand=function(self) self:smooth(0.75):diffuse(1,1,1,1) end,

		-- shell
		LoadActor("./phone.png")..{
			InitCommand=function(self) self:Center():zoom(0.45) end
		},

		-- time
		Def.BitmapText{
			File=THEME:GetPathB("ScreenRabbitHole", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
			Text="6:32",
			InitCommand=function(self) self:diffuse(1,1,1,1):xy(_screen.cx, _screen.cy-138):zoom(1.5):shadowlength(0.75) end
		},


		Def.ActorFrame{
			InitCommand=function(self) self:xy(_screen.cx, _screen.cy-60) end,
			-- notification bg
			Def.Quad{
				InitCommand=function(self) self:zoomto(_phone.w*0.765, 80):diffuse(0.8,0.8,0.8,0.925) end,
			},

			-- name bg
			Def.Quad{
				InitCommand=function(self) self:valign(0):y(-40):zoomto(_phone.w*0.765, 22):diffuse(0,0,0,0.8) end,
			},

			-- notification text
			Def.BitmapText{
				File=THEME:GetPathB("ScreenRabbitHole", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
				Text="1 new message:",
				InitCommand=function(self)
					self:zoom(0.8)
						:align(0,0)
						:x(-_phone.w/2 + 32)
						:y(-36)
				end
			},
			-- message text
			Def.BitmapText{
				File=THEME:GetPathB("ScreenRabbitHole", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
				Text="you'll find me out here\nor maybe I'll disappear\na walk in the snow",
				InitCommand=function(self)
					self:diffuse(Color.Black)
						:zoom(0.7)
						:halign(0)
						:x(-_phone.w/2 + 32)
						:y(8)
						:vertspacing(-2)
				end
			},
		}
	}
}

return af