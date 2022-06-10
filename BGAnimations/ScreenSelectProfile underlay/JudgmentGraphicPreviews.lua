local args = ...
local af = args.af

local already_loaded = {}

for profile in ivalues(args.profile_data) do
	if profile.judgment ~= nil and profile.judgment ~= "" then
		local name = StripSpriteHints(profile.judgment)
		if not FindInTable(name, already_loaded) then
			-- THEME:GetCurrentThemeDirectory() already has a trailing slash.
			local path = ("/%sGraphics/_judgments/%s"):format(THEME:GetCurrentThemeDirectory(), profile.judgment)
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

af[#af+1] = Def.Actor{ Name="JudgmentGraphic_None", InitCommand=function(self) self:visible(false) end }
