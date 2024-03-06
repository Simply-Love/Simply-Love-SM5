-- File to handle Event specific (ITL/RPG) progress such as song scores, ranking points, quest completions, etc.
-- if not IsServiceAllowed(SL.GrooveStats.AutoSubmit) or GAMESTATE:IsCourseMode() then return end

-- Unsure if it's possible to detect whether the chat module pane is active, so check that the file exists
local chatModule = FILEMAN:DoesFileExist(THEME:GetCurrentThemeDirectory() .. "Modules/TwitchChat.lua")

-- If there is no space for the ITL box, don't show it
if not IsUsingWideScreen() and (chatModule or #GAMESTATE:GetHumanPlayers() ~= 1) then return end

local player = ...
local pn = ToEnumShortString(player)

-- TODO: Create RPG body.

local CreateITLBody = function(itlData)
	local score = itlData["score"]
	local scoreDelta = itlData["scoreDelta"]
	local currentPoints = itlData["currentPoints"]
	local pointDelta = itlData["pointDelta"]
	local currentRankingPointTotal = itlData["currentRankingPointTotal"]
	local rankingDelta = itlData["rankingDelta"]
	local currentSongPointTotal = itlData["currentSongPointTotal"]
	local totalSongDelta = itlData["totalSongDelta"]
	local currentExPointTotal = itlData["currentExPointTotal"]
	local totalExDelta = itlData["totalExDelta"]
	local currentPointTotal = itlData["currentPointTotal"]
	local totalDelta = itlData["totalDelta"]

	return string.format(
		"EX Score: %.2f%% (%+.2f%%)\n"..
		"Points: %d (%+d)\n\n"..
		"Ranking Points: %d (%+d)\n"..
		"Song Points: %d (%+d)\n"..
		"EX Points: %d (%+d)\n"..
		"Total Points: %d (%+d)",
		score, scoreDelta, currentPoints, pointDelta,
		currentRankingPointTotal, rankingDelta,
		currentSongPointTotal, totalSongDelta,
		currentExPointTotal, totalExDelta,
		currentPointTotal, totalDelta
	)
end

-- Takes in an actor and both scales the text to fit within the box and
-- colorizes the text.
--
-- We colorize the following:
-- - Numbers (including decimals) in red if negative, green if positive.
-- - Quoted strings in green.
local ScaleAndColorizeBody = function(self, text, height, width, rowHeight, defaultColor)
	-- We don't want text to run out through the bottom.
	-- Incrementally adjust the zoom while adjust wrapwdithpixels until it fits.
	-- Not the prettiest solution but it works.
	for zoomVal=1.0, 0.1, -0.05 do
		self:zoom(zoomVal)
		self:wrapwidthpixels(width/(zoomVal))
		self:settext(text):visible(true)
		if self:GetHeight() * zoomVal <= height - rowHeight*1.5 then
			break
		end
	end

	local offset = 0
	while offset <= #text do
		-- Search for all numbers (decimals included).
		-- They may include the +/- prefixes and also potentially %/x as suffixes.
		local i, j = string.find(text, "[-+]?[%d]*%.?[%d]+[%%x]?", offset)
		-- No more numbers found. Break out.
		if i == nil then
			break
		end
		-- Extract the actual numeric text.
		local substring = string.sub(text, i, j)

		local clr = defaultColor

		-- Except negatives should be red.
		if substring:sub(1, 1) == "-" then
			clr = Color.Red
		-- And positives should be green.
		elseif substring:sub(1, 1) == "+" then
			clr = Color.Green
		end

		self:AddAttribute(i-1, {
			Length=#substring,
			Diffuse=clr
		})

		offset = j + 1
	end

	offset = 0

	while offset <= #text do
		-- Search for all quoted strings.
		local i, j = string.find(text, "\".-\"", offset)
		-- No more found. Break out.
		if i == nil then
			break
		end
		-- Extract the actual quoted text.
		local substring = string.sub(text, i, j)

		self:AddAttribute(i-1, {
			Length=#substring,
			Diffuse=Color.Green
		})

		offset = j + 1
	end
end

local ItlPink = color("1,0.2,0.406,1")

-- Default position is on the other player's upper area where the grade should be
local posX = 381 * (player == PLAYER_1 and 1 or -1)
local posY = 109

local paneWidth = 156
local paneHeight = 144
local borderWidth = 2

local RowHeight = 25

local hasData = false

-- If that space is taken by a player or the twitch chat module,
-- put it to the side in widescreen mode.
if IsUsingWideScreen() and (chatModule or #GAMESTATE:GetHumanPlayers() > 1) then
	posX = 211 * (player == PLAYER_1 and -1 or 1)
	posY = 274
	paneWidth = 118
	paneHeight = 180
	RowHeight = 45
end

local af = Def.ActorFrame{
	Name="EventProgress"..pn,

	InitCommand=function(self)
		self:xy(posX, posY)
		self:visible(false)
	end,

	SetDataCommand=function(self, params)
		if params.itlData then
			hasData = true
			local itlString = CreateITLBody(params.itlData)
			ScaleAndColorizeBody(
				self:GetChild("BodyText"),
				itlString,
				paneHeight - borderWidth,
				paneWidth - borderWidth,
				RowHeight,
				ItlPink)

			self:GetChild("Header"):settext(params.itlData["name"]:gsub("ITL Online", "ITL"))

			-- Ensure the header text fits within the box.
			for zoomVal=0.5, 0.1, -0.05 do
				self:GetChild("Header"):zoom(zoomVal)
				self:GetChild("Header"):wrapwidthpixels((paneWidth-6)/(zoomVal))
				if self:GetChild("Header"):GetHeight() * zoomVal <= RowHeight*2 then
					break
				end
			end
		end
	end,

	MaybeShowCommand=function(self)
		self:visible(hasData)
	end,

	-- Draw border Quad
	Def.Quad {
		InitCommand=function(self)
			self:zoomto(paneWidth, paneHeight)
			self:diffuse(Color.White):diffusealpha(0.1)
		end
	},

	-- Draw background Quad
	Def.Quad {
		InitCommand=function(self)
			self:zoomto(paneWidth - borderWidth, paneHeight - borderWidth)
			self:diffuse(Color.Black):diffusealpha(0.85)
		end
	},

	-- Header Text
	LoadFont("Wendy/_wendy small").. {
		Name="Header",
		Text="",
		InitCommand=function(self)
			self:zoom(0.5)
			self:y(-paneHeight/2 + 15)
		end
	},

	-- Main Body Text
	LoadFont("Common Normal").. {
		Name="BodyText",
		Text="",
		InitCommand=function(self)
			self:valign(0)
			self:wrapwidthpixels(paneWidth)
			self:y(-paneHeight/2 + RowHeight * 3/2)
		end,
	},
}

return af