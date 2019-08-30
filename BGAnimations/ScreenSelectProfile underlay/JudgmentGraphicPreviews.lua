local args = ...
local af = args.af

local already_loaded = {}

for profile in ivalues(args.profile_data) do
	if profile.judgment ~= nil and profile.judgment ~= "" and not FindInTable(profile.judgment, already_loaded) then

		if FILEMAN:DoesFileExist(THEME:GetCurrentThemeDirectory().."/Graphics/_judgments/ITG/"..profile.judgment) then
			af[#af+1] = LoadActor(THEME:GetPathG("","_judgments/ITG/"..profile.judgment))..{
				Name="JudgmentGraphic_"..StripSpriteHints(profile.judgment),
				InitCommand=function(self)
					self:y(-50):animate(false)
					-- why is the original Love judgment asset so... not aligned?
					-- it throws the aesthetic off as-is, so fudge a little
					if profile.judgment == "Love 2x6.png" then self:y(-55) end
				end
			}
			table.insert(already_loaded, profile.judgment)

		elseif FILEMAN:DoesFileExist(THEME:GetCurrentThemeDirectory().."/Graphics/_judgments/FA+/"..profile.judgment) then
			af[#af+1] = LoadActor(THEME:GetPathG("","_judgments/FA+/"..profile.judgment))..{
				Name="JudgmentGraphic_"..StripSpriteHints(profile.judgment),
				InitCommand=function(self) self:y(-50):animate(false) end
			}
			table.insert(already_loaded, profile.judgment)

		elseif FILEMAN:DoesFileExist(THEME:GetCurrentThemeDirectory().."/Graphics/_judgments/StomperZ/"..profile.judgment) then
			af[#af+1] = LoadActor(THEME:GetPathG("","_judgments/StomperZ/"..profile.judgment))..{
				Name="JudgmentGraphic_"..StripSpriteHints(profile.judgment),
				InitCommand=function(self) self:y(-50):animate(false) end
			}
			table.insert(already_loaded, profile.judgment)
		end
	end
end

af[#af+1] = Def.Actor{ Name="JudgmentGraphic_None", InitCommand=function(self) self:visible(false) end }