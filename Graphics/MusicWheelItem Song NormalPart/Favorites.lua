local player = ...
local pn = ToEnumShortString(player)

local af = Def.ActorFrame {
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
            self:animate(false):visible(false):x(-20)
            self:Load( THEME:GetPathG("", "fave-icon.png") )
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
        end,
        SetCommand=function(self, params)
            if params.Song then
                local song = params.Song
                if song and FindInTable(song, SL[pn].Favorites) then 
                    self:visible(true)
                else
                    self:visible(false)
                end
                if #GAMESTATE:GetHumanPlayers() > 1 then
                    self:zoomto(15,15)
                    self:y(pn == "P1" and -8 or 8)
                else
                    self:zoomto(20,20):y(0)
                end
            end
        end,
    }
}

return af
