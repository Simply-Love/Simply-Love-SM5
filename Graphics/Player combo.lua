local player = Var "Player"
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers

local available_fonts = GetComboFonts()
local combo_font = (FindInTable(mods.ComboFont, available_fonts) ~= nil and mods.ComboFont) or available_fonts[1] or nil

local worst_judgment = 1
local combo_active = false

if mods.HideCombo or combo_font == nil then
	return Def.Actor{ InitCommand=function(self) self:visible(false) end }
end

-- combo colors used in Casual and ITG
local colors = {}
colors.FullComboW1 = {color("#C8FFFF"), color("#6BF0FF")} -- blue combo
colors.FullComboW2 = {color("#FDFFC9"), color("#FDDB85")} -- gold combo
colors.FullComboW3 = {color("#C9FFC9"), color("#94FEC1")} -- green combo
colors.FullComboW4 = {color("#FFFFFF"), color("#FFFFFF")} -- white combo

-- combo colors used in FA+
if SL.Global.GameMode == "FA+" then
	colors.FullComboW1 = {color("#C8FFFF"), color("#6BF0FF")} -- blue combo
	colors.FullComboW2 = {color("#C8FFFF"), color("#6BF0FF")} -- blue combo
	colors.FullComboW3 = {color("#FDFFC9"), color("#FDDB85")} -- gold combo
	colors.FullComboW4 = {color("#C9FFC9"), color("#94FEC1")} -- green combo
end

local solidColors = {}
solidColors.FullComboW1 = color("#21CCE8")
solidColors.FullComboW2 = color("#e29c18")
solidColors.FullComboW3 = color("#66c955")
solidColors.FullComboW4 = color("#ffffff")

if SL.Global.GameMode == "FA+" then
	solidColors.FullComboW1 = color("1,0.2,0.406,1")
	solidColors.FullComboW2 = color("#21CCE8")
	solidColors.FullComboW3 = color("#e29c18")
	solidColors.FullComboW4 = color("#66c955")
end

-- ghetto quint support
colors.FullComboW0 = {color("#F7C0FE"), color("#E928FF")} -- magenta combo
solidColors.FullComboW0 = color("#E928FF") -- magenta
local quintin_tarandimo = mods.ShowFaPlusWindow and true or false -- do we want to show quint combo when the user doesnt have FA+ window enabled?

local ShowComboAt = THEME:GetMetric("Combo", "ShowComboAt")

local af = Def.ActorFrame{
	InitCommand=function(self)
		self:draworder(101)
	end,

	ComboCommand=function(self, params)
		local CurrentCombo = params.Misses or params.Combo

		-- if the combo has reached (or surpassed) the threshold to be shown, display the AF, otherwise hide it
		self:visible( CurrentCombo ~= nil and CurrentCombo >= ShowComboAt )
	end,
}

if not mods.HideComboExplosions then
	-- load the combo milestones actors into the Player combo; they will
	-- listen for the appropriate Milestone command from the engine
	af[#af+1] = LoadActor( THEME:GetPathG("Combo","100Milestone") )..{ Name="OneHundredMilestone" }
	af[#af+1] = LoadActor( THEME:GetPathG("Combo","1000Milestone") )..{ Name="OneThousandMilestone" }
end

-- Combo fonts should be monospaced so that each digit's alignment remains
-- consistent (i.e., not visually distracting) as the combo continually grows

local combo_bmt = LoadFont("_Combo Fonts/" .. combo_font .."/" .. combo_font)..{
	Name="Number",
	OnCommand=function(self)
		self:shadowlength(1):vertalign(middle):zoom(0.75)
		
		-- Combo count re-positioning if using vertical lookahead
		if mods.MeasureCounterVert and not mods.MeasureCounterUp and not mods.MeasureCounterLeft then
			self:addy(mods.MeasureCounterLookahead * 20)
		elseif mods.BrokenRun and not mods.MeasureCounterUp and not mods.MeasureCounterLeft then
			self:addy(16)
		end
	end,
	ComboCommand=function(self, params)
		self:settext( params.Combo or params.Misses or "" )
		self:playcommand("Color", params)
	end,
	JudgmentMessageCommand=function(self, params)
		if params.Player ~= player then return end
		if not params.TapNoteScore then return end
		if params.HoldNoteScore then return end
		
		local tns = ToEnumShortString(params.TapNoteScore)
		if tns == "AvoidMine" or tns == "HitMine" then return end
		
		if tns == "Miss" then
			worst_judgment = 1
		else
			worst_judgment = math.max(worst_judgment, string.sub(tns,2,2))
			if worst_judgment >= 4 then
				worst_judgment = 1
			end
		end

		-- ghetto quint support
		if not IsW0Judgment(params, player) then quintin_tarandimo = false end

	end,
	ColorCommand=function(self, params)
		-- Though this if/else chain may seem strange (why not reduce it to a single table for quick lookup?)
		-- the FullCombo params passed in from the engine are also strange, so this accommodates.
		--
		-- the params table will always contain a "Combo" value if the player is comboing notes successfully
		-- or a "Misses" value if the player is not hitting any notes and earning consecutive misses.
		--
		-- Once we are 20% through the song (this value is specifed in Metrics.ini in the [Player] section
		-- using PercentUntilColorCombo), the engine will start to include FullCombo parameters.
		--
		-- If the player has only earned W1 judgments so far, the params table will look like:
		-- { Combo=1001, FullComboW1=true, FullComboW2=true, FullComboW3=true, FullComboW4=true }
		--
		-- if the player has earned some combination of W1 and W2 judgments, the params table will look like:
		-- { Combo=1005, FullComboW2=true, FullComboW3=true, FullComboW4=true }
		--
		-- And so on. While the information is technically true (a FullComboW2 does imply a FullComboW3), the
		-- explicit presence of all those parameters makes checking truthiness here in the theme a little
		-- awkward.  We need to explicitly check for W1 first, then W2, then W3, and so on...
		
		if mods.ComboColors == "None" then
			if params.Combo then
				self:stopeffect():diffuse( Color.White )
			elseif params.Misses then
				self:stopeffect():diffuse( Color.Red ) -- Miss Combo; no effect, always just #ff0000
			end
		elseif mods.ComboMode == "FullCombo" then
			if mods.ComboColors == "Rainbow" and not combo_active and params.Combo then
				combo_active = true
				if params.FullComboW1 or params.FullComboW2 or params.FullComboW3 then
					self:rainbow()
				else
					self:diffuse(Color.White)
				end
			elseif mods.ComboColors == "RainbowScroll" and not combo_active and params.Combo then
				combo_active = true
				if params.FullComboW1 or params.FullComboW2 or params.FullComboW3 then
					self:rainbowscroll(true)
				else
					self:diffuse(Color.White):rainbowscroll(false)
				end
			elseif mods.ComboColors ~= "Rainbow" and mods.ComboColors ~= "RainbowScroll" then
				self:diffuseshift():effectperiod(0.8)

				-- ghetto quint support
				if params.FullComboW1 and quintin_tarandimo then
					if mods.ComboColors == "Glow" then
						self:effectcolor1(colors.FullComboW0[1]):effectcolor2(colors.FullComboW0[2])
					elseif mods.ComboColors == "Solid" then
						self:stopeffect():diffuse(solidColors.FullComboW0)
					end

				elseif params.FullComboW1 then
					if mods.ComboColors == "Glow" then
						self:effectcolor1(colors.FullComboW1[1]):effectcolor2(colors.FullComboW1[2])
					elseif mods.ComboColors == "Solid" then
						self:stopeffect():diffuse(solidColors.FullComboW1)
					end

				elseif params.FullComboW2 then
					if mods.ComboColors == "Glow" then
						self:effectcolor1(colors.FullComboW2[1]):effectcolor2(colors.FullComboW2[2])
					elseif mods.ComboColors == "Solid" then
						self:stopeffect():diffuse(solidColors.FullComboW2)
					end

				elseif params.FullComboW3 then
					if mods.ComboColors == "Glow" then
						self:effectcolor1(colors.FullComboW3[1]):effectcolor2(colors.FullComboW3[2])
					elseif mods.ComboColors == "Solid" then
						self:stopeffect():diffuse(solidColors.FullComboW3)
					end

				elseif params.FullComboW4 then
					if mods.ComboColors == "Glow" then
						self:effectcolor1(colors.FullComboW4[1]):effectcolor2(colors.FullComboW4[2])
					elseif mods.ComboColors == "Solid" then
						self:stopeffect():diffuse(solidColors.FullComboW4)
					end

				elseif params.Combo then
					self:stopeffect():diffuse( Color.White ) -- not a full combo; no effect, always just #ffffff

				elseif not params.Combo then
					self:stopeffect():rainbowscroll(false):diffuse( Color.Red ) -- Miss Combo; no effect, always just #ff0000
				end
			elseif params.Misses then
				combo_active = false
				self:stopeffect():diffuse( Color.Red ) -- Miss Combo; no effect, always just #ff0000
			end
		elseif mods.ComboMode == "CurrentCombo" then
			if mods.ComboColors == "Rainbow" and not combo_active and params.Combo then
				combo_active = true
				self:rainbow()
			elseif mods.ComboColors == "RainbowScroll" and not combo_active and params.Combo then
				combo_active = true
				self:rainbowscroll(true)
			elseif mods.ComboColors ~= "Rainbow" and mods.ComboColors ~= "RainbowScroll" then
				self:diffuseshift():effectperiod(0.8)
				if not params.Misses then
					if worst_judgment == 1 and quintin_tarandimo then
						if mods.ComboColors == "Glow" then
							self:effectcolor1(colors.FullComboW0[1]):effectcolor2(colors.FullComboW0[2])
						elseif mods.ComboColors == "Solid" then
							self:stopeffect():diffuse(solidColors.FullComboW0)
						end
					elseif worst_judgment == 1 then
						if mods.ComboColors == "Glow" then
							self:effectcolor1(colors.FullComboW1[1]):effectcolor2(colors.FullComboW1[2])
						elseif mods.ComboColors == "Solid" then
							self:stopeffect():diffuse(solidColors.FullComboW1)
						end
					elseif worst_judgment == 2 then
						if mods.ComboColors == "Glow" then
							self:effectcolor1(colors.FullComboW2[1]):effectcolor2(colors.FullComboW2[2])
						elseif mods.ComboColors == "Solid" then
							self:stopeffect():diffuse(solidColors.FullComboW2)
						end
					elseif worst_judgment == 3 then
						if mods.ComboColors == "Glow" then
							self:effectcolor1(colors.FullComboW3[1]):effectcolor2(colors.FullComboW3[2])
						elseif mods.ComboColors == "Solid" then
							self:stopeffect():diffuse(solidColors.FullComboW3)
						end
					end
				else
					self:stopeffect():diffuse( Color.Red ) -- Miss Combo; no effect, always just #ff0000
				end
			elseif not params.Combo then
				combo_active = false
				self:stopeffect():rainbowscroll(false):diffuse( Color.Red ) -- Miss Combo; no effect, always just #ff0000
			end
			
		end
	end
}

-- -----------------------------------------------------------------------
-- EasterEggs

if combo_font == "Source Code" then
	combo_bmt.ComboCommand=function(self, params)
		-- "Hexadecimal is a virus of incredible power and unpredictable insanity from Lost Angles."
		-- https://reboot.fandom.com/wiki/Hexadecimal
		self:settext( string.format("%X", tostring(params.Combo or params.Misses or 0)):lower() )
		self:diffuseshift():effectperiod(0.8):playcommand("Color", params)
	end
end

if combo_font == "Wendy (Cursed)" then
	combo_bmt.ColorCommand=function(self, params)
		if params.FullComboW3 then
			self:rainbowscroll(true)

		elseif params.Combo then
			-- combo broke at least once; stop the rainbow effect and diffuse white
			self:zoom(0.75):horizalign(center):rainbowscroll(false):stopeffect():diffuse( Color.White )

		elseif params.Misses then
			self:stopeffect():rainbowscroll(false):diffuse( Color.Red ) -- Miss Combo
			self:zoom(self:GetZoom() * 1.001)
			-- horizalign of center until the miss combo is wider than this player's notefield
			-- then, align so that it doesn't encroach into the other player's half of the screen
			if (#GAMESTATE:GetHumanPlayers() > 1) and ((self:GetWidth()*self:GetZoom()) > GetNotefieldWidth()) then
				self:horizalign(player == PLAYER_1 and right or left):x( (self:GetWidth()) * (player == PLAYER_1 and 1 or -1)  )
			end
		end
	end
end
-- -----------------------------------------------------------------------

af[#af+1] = combo_bmt

return af
