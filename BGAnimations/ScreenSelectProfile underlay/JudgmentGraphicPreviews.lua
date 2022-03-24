local args = ...
local af = args.af

local already_loaded = {}

-- get a table like { "ITG", "FA+" }
local judgment_dirs = FILEMAN:GetDirListing(THEME:GetCurrentThemeDirectory().."Graphics/_judgments/", true, false)

for profile in ivalues(args.profile_data) do
	if profile.judgment ~= nil and profile.judgment ~= "" then
		local name = StripSpriteHints(profile.judgment)
		if not FindInTable(name, already_loaded) then
			for dir in ivalues(judgment_dirs) do

				-- THEME:GetCurrentThemeDirectory() already has a trailing slash.
				local path = ("/%sGraphics/_judgments/%s/%s"):format(THEME:GetCurrentThemeDirectory(), dir, profile.judgment)
				if FILEMAN:DoesFileExist(path) then

					af[#af+1] = Def.Sprite{
						Name="JudgmentGraphic_"..name,
						Texture=path,
						InitCommand=function(self)
							self:y(-50):animate(false)
						end
					}

					table.insert(already_loaded, name)
					break
				end
			end
		end
	end
end

af[#af+1] = Def.Actor{ Name="JudgmentGraphic_None", InitCommand=function(self) self:visible(false) end }
