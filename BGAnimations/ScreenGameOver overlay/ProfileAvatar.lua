local player, x_pos = unpack(...)

-- pixel dimension (height, width) to scale avatar to
local avatar_dim  = 110
local avatar_path = GetPlayerAvatarPath(player)

-- player avatar was found; show that
if avatar_path ~= nil then
	return Def.Sprite{
		Texture=avatar_path,
		InitCommand=function(self) self:align(0,0):zoomto(avatar_dim, avatar_dim):xy(x_pos-avatar_dim*0.5, 12) end
	}

-- no player avatar found, show a fallback avatar instead
else
	return Def.ActorFrame{
		InitCommand=function(self) self:xy(x_pos-avatar_dim*0.5, 12) end,

		Def.Quad{
			InitCommand=function(self)
				self:align(0,0):zoomto(avatar_dim,avatar_dim):diffuse(color("#283239aa"))
			end
		},
		-- fallback visual (SL visual theme)
		LoadActor(THEME:GetPathG("", "_VisualStyles/".. ThemePrefs.Get("VisualStyle") .."/SelectColor"))..{
			InitCommand=function(self)
				self:align(0,0):zoom(0.12):diffusealpha(0.9):xy(15, 10)
				if ThemePrefs.Get("VisualStyle") == "SRPG8" then
					self:zoom(0.4):xy(5, 0)	
				end
			end
		},
		-- fallback text ("no avatar")
		LoadFont("Common Normal")..{
			Text=THEME:GetString("ProfileAvatar","NoAvatar"),
			InitCommand=function(self)
				self:valign(0):zoom(0.9):diffusealpha(0.9):xy(56, 88)
			end,
			SetCommand=function(self, params)
				if params == nil then
					self:settext(THEME:GetString("ScreenSelectProfile", "GuestProfile"))
				else
					self:settext(THEME:GetString("ScreenSelectProfile", "NoAvatar"))
				end
			end
		}
	}
end