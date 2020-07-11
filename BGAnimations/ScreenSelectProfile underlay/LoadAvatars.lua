local args = ...
local af = args.af

local textures = {}

af[#af+1] = Def.Sprite{
	InitCommand=function(self)
		for profile in ivalues(args.profile_data) do
			if profile.dir and profile.displayname then
				local path = GetAvatarPath(profile.dir, profile.displayname)

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