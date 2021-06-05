local args = ...
local af = args.af

local already_loaded = {}

-- get a table like { "ITG", "FA+" }
local judgment_dirs = FILEMAN:GetDirListing(THEME:GetCurrentThemeDirectory().."/Graphics/_judgments/", true, false)

for profile in ivalues(args.profile_data) do
	if profile.judgment ~= nil and profile.judgment ~= "" and not FindInTable(profile.judgment, already_loaded) then

		for dir in ivalues(judgment_dirs) do

			path = GetJudgmentGraphicsPath(profile.judgment, dir)
			if FILEMAN:DoesFileExist(path) then

				af[#af+1] = Def.Sprite{
					Name="JudgmentGraphic_"..StripSpriteHints(profile.judgment),
					Texture=path,
					InitCommand=function(self)
						self:y(-50):animate(false)
					end
				}

				table.insert(already_loaded, profile.judgment)
				break
			end
		end
	end
end

af[#af+1] = Def.Actor{ Name="JudgmentGraphic_None", InitCommand=function(self) self:visible(false) end }
