local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers

--Let's see if we need to let  the player know that they are nice.
if ThemePrefs.Get("EnableTournamentMode") and ThemePrefs.Get("EnforceNoCmod") then
    return Def.ActorFrame{
        OnCommand=function(self)
            local song = GAMESTATE:GetCurrentSong()
            if song then
                if (song:GetDisplayFullTitle():lower():match("no cmod") or
                    song:GetTranslitFullTitle():lower():match("no cmod")) then
                    if mods.SpeedModType == "C" then
                        -- SL[pn].ActiveModifiers.SpeedModType = "M"

                        local topscreen = SCREENMAN:GetTopScreen():GetName()
                        local modslevel = topscreen  == "ScreenEditOptions" and "ModsLevel_Stage" or "ModsLevel_Preferred"
                        local playeroptions = GAMESTATE:GetPlayerState(player):GetPlayerOptions(modslevel)

                        playeroptions["MMod"](playeroptions, mods.SpeedMod)
                    end
                end
            end
        end
    }
end
