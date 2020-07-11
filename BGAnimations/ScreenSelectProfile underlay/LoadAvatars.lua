local args = ...
local af = args.af

local textures = {}

af[#af+1] = Def.Sprite{
	InitCommand=function(self)
		for profile in ivalues(args.profile_data) do
			if profile.dir and profile.displayname then
				local path = ActorUtil.ResolvePath(profile.dir .. "avatar", 1, true)
				          -- support avatars from Hayoreo's Digital Dance, which uses "Profile Picture.png" in profile dir
				          or ActorUtil.ResolvePath(profile.dir .. "profile picture", 1, true)
				          -- support SM5.3's avatar location to ease the eventual transition
				          or ActorUtil.ResolvePath("/Appearance/Avatars/" .. profile.displayname, 1, true)

				if path then
					-- limited to basic Bitmaps (png, jpg, jpeg, bpm, gif) for now
					-- maybe support movie files or animated sprite textures in the future
					if ActorUtil.GetFileType(path) == "FileType_Bitmap" then
						self:Load(path)
						textures[profile.displayname] = self:GetTexture()
					end
				end
			end
		end
		self:visible(false):hibernate(math.huge)
	end
}

return textures