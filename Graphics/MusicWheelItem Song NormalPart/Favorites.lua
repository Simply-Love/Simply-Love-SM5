-- This is used for tracking ITL points on the songwheel
-- TODO: 
-- Maybe load all points at screen load instead of every time the MusicWheelItem loads?
-- Screen needs to reload when new players join or else the layout is messed up
-- Doesn't display anything until you scroll the musicwheel at once

-- Notes
-- Works for 16:9, 16:10, 4:3 on 1,2 player and versus mode
-- I'm unsure whether it is readable on a 4:3 CRT
-- Design in 2 player mode could probably be improved

local player = ...
local pn = ToEnumShortString(player)

local ar = GetScreenAspectRatio()

local af = Def.ActorFrame {
	InitCommand=function(self)
	end,
	PlayerJoinedMessageCommand=function(self, params)
		if not PROFILEMAN:IsPersistentProfile(params.Player) then
			GAMESTATE:ResetPlayerOptions(params.Player)
			SL[ToEnumShortString(params.Player)]:initialize()
		end
		if pn == nil then
			player = params.Player
			pn = ToEnumShortString(player)
		end
	end,
    Def.Sprite{
        InitCommand=function(self)
            self:animate(false):visible(false)
            self:Load( THEME:GetPathG("", "fave-icon.png") )
        end,
        SetCommand=function(self,params)
            if params.Song then
                local song = params.Song
                if song and FindInTable(song, SL[pn].Favorites) then 
                    self:visible(true)
                else
                    self:visible(false)
                end

                self:diffuseshift():effectperiod(0.8)
                if pn == "P1" then
                    self:effectcolor1(Color.Blue)
                    self:effectcolor2(lerp_color(
                        0.70, color("#ffffff"), Color.Blue))
                else
                    self:effectcolor1(color("#ff7777"))
                    self:effectcolor2(lerp_color(
                        0.70, color("#ffffff"), color("#ff7777")))
                end
                self:x(-20)
                if #GAMESTATE:GetHumanPlayers() > 1 then
                    self:zoomto(15,15)
                    self:y(pn == "P1" and -6 or 6)
                else
                    self:zoomto(20,20):y(0)
                end
            else
                self:visible(false)
            end

        end,
        UnsetCommand=function(self)
            self:visible(false)
        end
    }
}


return af