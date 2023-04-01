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
            self:Load( THEME:GetPathG("", "Favorites-icons 2x1") )
            if pn == "P1" then
                self:setstate(0)
            else
                self:setstate(1)
            end
        end,
        SetCommand=function(self,params)
            if params.Song then
                local song = params.Song
                if song and FindInTable(song, SL[pn].Favorites) then 
                    self:visible(true)
                else
                    self:visible(false)
                end
                self:x(-18)
                if #GAMESTATE:GetHumanPlayers() > 1 then
                    self:zoom(0.4)
                    self:y(pn == "P1" and -6 or 6)
                else
                    self:zoom(0.5):y(0)
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