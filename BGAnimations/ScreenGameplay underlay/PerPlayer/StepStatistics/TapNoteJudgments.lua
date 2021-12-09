local args = ...
local player = args[1]
local has_labels = args[2]

local IsUltraWide = (GetScreenAspectRatio() > 21/9)
local NoteFieldIsCentered = (GetNotefieldX(player) == _screen.cx)

local StepsOrTrail = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)
local total_tapnotes = StepsOrTrail:GetRadarValues(player):GetValue( "RadarCategory_Notes" )

-- determine how many digits are needed to express the number of notes in base-10
local digits = (math.floor(math.log10(total_tapnotes)) + 1)
-- display a minimum 4 digits for aesthetic reasons
digits = math.max(4, digits)

-- generate a Lua string pattern that will be used to leftpad with 0s
local pattern = ("%%0%dd"):format(digits)


local TNS = {
	Types = { 'W1', 'W2', 'W3', 'W4', 'W5', 'Miss' },
	Judgments = { W1=0, W2=0, W3=0, W4=0, W5=0, Miss=0 },
	Names = {},
}

local tns_string = "TapNoteScore" .. (SL.Global.GameMode=="ITG" and "" or SL.Global.GameMode)
-- get TNS names appropriate for the current GameMode, localized to the current language
for i, judgment in ipairs(TNS.Types) do
	TNS.Names[#TNS.Names+1] = THEME:GetString(tns_string, judgment)
end

local leadingZeroAttr
local row_height = 35

local windows = SL.Global.ActiveModifiers.TimingWindows

-- -----------------------------------------------------------------------

local af = Def.ActorFrame{}
af.Name="TapNoteJudgments"
af.InitCommand=function(self)
	self:zoom(0.8)
	self:x( SL_WideScale(152,204) * (player==PLAYER_1 and -1 or 1))

	if NoteFieldIsCentered and IsUsingWideScreen() then
		self:x( 156 * (player==PLAYER_1 and -1 or 1))
	end

	-- adjust for smaller panes when ultrawide and both players joined
	if IsUltraWide and #GAMESTATE:GetHumanPlayers() > 1 then
		self:x( 154 * (player==PLAYER_1 and 1 or -1))
	end
end


for index, window in ipairs(TNS.Types) do

	-- TNS value
	-- i.e. how many W1s the player has earned so far, how many W2s, etc.
	af[#af+1] = LoadFont("Wendy/_ScreenEvaluation numbers")..{
		Text=(pattern):format(0),
		InitCommand=function(self)
			self:zoom(0.5)
			self:y((index-1)*row_height - 280)
			self:halign( PlayerNumber:Reverse()[player] )

			-- flip alignment when ultrawide and both players joined
			if IsUltraWide and #GAMESTATE:GetHumanPlayers() > 1 then
				self:halign( PlayerNumber:Reverse()[OtherPlayer[player]] )
			end

			if SL.Global.ActiveModifiers.TimingWindows[index] or index==#TNS.Types then
				self:diffuse( SL.JudgmentColors[SL.Global.GameMode][index] )
				leadingZeroAttr = { Length=(digits-1), Diffuse=Brightness(self:GetDiffuse(), 0.35) }
				self:AddAttribute(0, leadingZeroAttr )
			else
				self:diffuse(Brightness({1,1,1,1},0.25))
			end
		end,
		JudgmentMessageCommand=function(self, params)
			if params.Player ~= player then return end
			if params.HoldNoteScore then return end

			if params.TapNoteScore and ToEnumShortString(params.TapNoteScore) == window then
				TNS.Judgments[window] = TNS.Judgments[window] + 1
				self:settext( (pattern):format(TNS.Judgments[window]) )

				leadingZeroAttr = {
					Length=(digits - (math.floor(math.log10(TNS.Judgments[window]))+1)),
					Diffuse=Brightness(SL.JudgmentColors[SL.Global.GameMode][index], 0.35)
				}
				self:AddAttribute(0, leadingZeroAttr )
			end
		end
	}

	-- TNS label
	-- no need to add BitmapText actors for TimingWindows that were turned off
	if has_labels then
		if windows[index] or index==#TNS.Names then

			af[#af+1] = LoadFont("Common Normal")..{
				Text=TNS.Names[index]:upper(),
				InitCommand=function(self)
					self:zoom(0.833):maxwidth(72)
					self:halign( PlayerNumber:Reverse()[player] )
					if player==PLAYER_1 then
						self:x( 80 + (digits-4)*16)
					else
						self:x(-80 - (digits-4)*16)
					end
					self:y((index-1) * row_height - 279)
					self:diffuse( SL.JudgmentColors[SL.Global.GameMode][index] )

					-- flip alignment when ultrawide and both players joined
					if IsUltraWide and #GAMESTATE:GetHumanPlayers() > 1 then
						self:halign( PlayerNumber:Reverse()[OtherPlayer[player]] )
						self:x(self:GetX() * -1)
					end
				end,
			}
		end
	end

end

return af