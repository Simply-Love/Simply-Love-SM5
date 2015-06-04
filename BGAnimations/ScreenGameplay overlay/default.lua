local Players = GAMESTATE:GetHumanPlayers()

local t = Def.ActorFrame{

	-- thanks shake
	Def.ActorFrame{
		Name="SongMeter",
		InitCommand=cmd(x,_screen.cx; y,20; draworder,95; diffusealpha,0),
		OnCommand=cmd(decelerate,0.2; diffusealpha,1),

		Def.SongMeterDisplay {
			StreamWidth=_screen.w/2-10,
			Stream=Def.Quad{ InitCommand=cmd(zoomy,18;diffuse,DifficultyIndexColor(2) ) }
		},

		Border(_screen.w/2-10, 22, 2)
	},



	-- song info
	Def.ActorFrame{
		Name="SongInfoFrame",
		InitCommand=cmd(x,_screen.cx;y,20;draworder,95),

		LoadFont("_misoreg hires")..{
			Name="SongName",
			InitCommand=cmd(zoom,0.8; shadowlength,0.6; maxwidth,_screen.w/2.5 - 10; NoStroke),
			CurrentSongChangedMessageCommand=cmd(playcommand, "Update"),
			UpdateCommand=function(self)
				local title = ""

				song = GAMESTATE:GetCurrentSong()

				if song then
					title = song:GetDisplayFullTitle()
				end

				-- DVNO
				-- four capital letters
				-- printed in gold.
				if title == "DVNO" then
					local attribDVNO = {
						Length = 4;
						Diffuse = color("1,0.8,0,1");
					}
					self:AddAttribute(0,attribDVNO)
				end

				self:settext(title)
			end
		}
	},
}

for player in ivalues(Players) do

	t[#t+1] = LoadActor("LifeMeter.lua", player)

	-- colored background for player's chart's difficulty meter
	t[#t+1] = Def.Quad{
		InitCommand=function(self)
			self:zoomto(30, 30)
			self:xy( WideScale(27,84), 56 )
			
			if player == PLAYER_2 then
				self:x( _screen.w-WideScale(27,84) )
			end
		end,
		OnCommand=function(self)
			local currentSteps = GAMESTATE:GetCurrentSteps(player)
			if currentSteps then
				local currentDifficulty = currentSteps:GetDifficulty()
				self:diffuse(DifficultyColor(currentDifficulty))
			end
		end
	}

	-- player's chart's difficulty meter
	t[#t+1] = LoadFont("_wendy small")..{
		InitCommand=function(self)
			self:diffuse(Color.Black)
			self:zoom( 0.4 )
			self:xy( WideScale(27,84), 56)

			if player == PLAYER_2 then
				self:x( _screen.w-WideScale(27,84) )
			end
		end,
		CurrentSongChangedMessageCommand=cmd(queuecommand,"Begin"),
		BeginCommand=function(self)
			local steps = GAMESTATE:GetCurrentSteps(player)
			local meter = steps:GetMeter()

			if meter then
				self:settext(meter)
			end
		end
	}

	t[#t+1] = LoadFont("_wendy monospace numbers")..{
		Name=ToEnumShortString(player).."Score",
		Text="0.00",
		InitCommand=function(self)
			self:y(56)
			self:valign(1)
			self:halign(1)
			self:zoom(0.5)
			if player == PLAYER_1 then
				self:x( _screen.cx - _screen.w/4.3 )
			elseif player == PLAYER_2 then
				self:x( _screen.cx + _screen.w/2.85 )
			end
		end,
		OnCommand=function(self)
			self:visible( not SL[ToEnumShortString(player)].ActiveModifiers.HideScore )
		end,
		JudgmentMessageCommand=cmd(queuecommand, "RedrawScore"),
		RedrawScoreCommand=function(self)
			local dp = STATSMAN:GetCurStageStats():GetPlayerStageStats(player):GetPercentDancePoints()
			local percent = FormatPercentScore( dp ):sub(1,-2)
			self:settext(percent)
		end
	}
end


if GAMESTATE:IsPlayerEnabled(PLAYER_1) and GAMESTATE:IsPlayerEnabled(PLAYER_2) then
	t[#t+1] = Def.Actor{
		JudgmentMessageCommand=cmd(queuecommand, "Winning"),
		WinningCommand=function(self)
			local dpP1 = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_1):GetPercentDancePoints()
			local dpP2 = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_2):GetPercentDancePoints()

			if dpP1 > dpP2 then
				self:GetParent():GetChild("P1Score"):diffusealpha(1)
				self:GetParent():GetChild("P2Score"):diffusealpha(0.65)
			elseif dpP2 > dpP1 then
				self:GetParent():GetChild("P1Score"):diffusealpha(0.65)
				self:GetParent():GetChild("P2Score"):diffusealpha(1)
			end
		end
	}
end

t[#t+1] = LoadActor("BPMDisplay.lua")

return t