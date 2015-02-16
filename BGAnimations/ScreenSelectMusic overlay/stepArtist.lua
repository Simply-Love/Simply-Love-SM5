local t = Def.ActorFrame{}

for p=1,2 do

	local player = "PlayerNumber_P"..p;

	t[#t+1] = Def.ActorFrame{
		InitCommand=function(self)

			if player == PLAYER_1 then
				self:player(PLAYER_1)
				self:horizalign(left)
				self:y(_screen.cy + 43)
				if IsUsingWideScreen() then
					self:x(_screen.cx - 359)
				else
					self:x(_screen.cx - 343)
				end
			elseif player == PLAYER_2 then
				self:player(PLAYER_2)
				self:horizalign(right)
				self:y(_screen.cy + 97)
				if IsUsingWideScreen() then
					self:x(_screen.cx - 213)
				else
					self:x(_screen.cx - 208)
				end
			end

			if p == 1 and GAMESTATE:IsHumanPlayer(PLAYER_1) then
				self:queuecommand("AppearP1")
			end
			if p == 2 and GAMESTATE:IsHumanPlayer(PLAYER_2) then
				self:queuecommand("AppearP2")
			end
		end,

		AppearP1Command=cmd(visible, true; ease, 0.5, 275; addy, -30),
		AppearP2Command=cmd(visible, true; ease, 0.5, 275; addy,  30),

		PlayerJoinedMessageCommand=function(self, params)
			if p == 1 and params.Player == PLAYER_1 then
				self:queuecommand("AppearP1")
			elseif p == 2 and params.Player == PLAYER_2 then
				self:queuecommand("AppearP2")
			end
		end,

		-- colored background quad
		Def.Quad{
			InitCommand=function(self)
				self:zoomto(175, _screen.h/28)
				self:x(113)
				if p == 1 then
					self:diffuse(PlayerColor(PLAYER_1))
				end
				if p == 2 then
					self:diffuse(PlayerColor(PLAYER_2))
				end
			end,
			SetCommand=function(self)

				if GAMESTATE:IsHumanPlayer(player) then
					local currentSteps = GAMESTATE:GetCurrentSteps(player)
					if currentSteps then
						local currentDifficulty = currentSteps:GetDifficulty()
						self:diffuse(DifficultyColor(currentDifficulty))
					end
				end
			end
		},

		--STEPS label
		LoadFont("_misoreg hires")..{
			OnCommand=cmd(diffuse, color("0,0,0,1"); horizalign, left; x, 30; settext, "STEPS")
		},

		--stepartist text
		LoadFont("_misoreg hires")..{
			OnCommand=cmd(diffuse,color("#1e282f"); horizalign, left; x, 75; maxwidth, 115),
			SetCommand=function(self)
				local stepartist
				local cs = GAMESTATE:GetCurrentSteps(player)

				if cs then
					stepartist = cs:GetAuthorCredit()
				end

				if stepartist then
					if stepartist ~= "" then
						self:settext(stepartist)
					else
						self:settext("???")
					end
				end


				local song = GAMESTATE:GetCurrentSong()
				local course = GAMESTATE:GetCurrentCourse()
				self:visible(song ~= nil or course ~= nil)
			end
		},

		-- song and course changes
		CurrentSongChangedMessageCommand=cmd(playcommand,"Set"),
		CurrentCourseChangedMessageCommand=cmd(playcommand,"Set"),

		CurrentStepsP1ChangedMessageCommand=function(self)
			if player == PLAYER_1 then self:playcommand("Set") end
		end,
		CurrentTrailP1ChangedMessageCommand=function(self)
			if player == PLAYER_1 then self:playcommand("Set") end
		end,
		CurrentStepsP2ChangedMessageCommand=function(self)
			if player == PLAYER_2 then self:playcommand("Set") end
		end,
		CurrentTrailP2ChangedMessageCommand=function(self)
			if player == PLAYER_2 then self:playcommand("Set") end
		end
	}
end

return t