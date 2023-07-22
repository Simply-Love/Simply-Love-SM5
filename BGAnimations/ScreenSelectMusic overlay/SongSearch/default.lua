-- sick_wheel_mt is a metatable with global scope defined in ./Scripts/Consensual-sick_wheel.lua
local candidatesScroller = setmetatable({}, sick_wheel_mt)
local candidateItemMt = LoadActor("CandidateItemMT.lua")
local inputHandler = LoadActor("InputHandler.lua", candidatesScroller)

local paneHeight = 319
local paneWidth = 319
local borderWidth = 2

local textHeight = 15

local af = Def.ActorFrame {
	Name="SongSearch",
	InitCommand=function(self)
		self:visible(false)
	end,
	DisplaySearchResultsMessageCommand=function(self, params)
		self:visible(true)
		self:playcommand("AssessCandidates", params)
		-- We have to wait a little bit before adding the input handler.
		self:sleep(0.25):queuecommand("AddInputCallback")
	end,
	AddInputCallbackCommand=function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(inputHandler)
		for player in ivalues(PlayerNumber) do
			SCREENMAN:set_input_redirected(player, true)
		end
	end,
	DirectInputToEngineCommand=function(self)
		SCREENMAN:GetTopScreen():RemoveInputCallback(inputHandler)
		for player in ivalues(PlayerNumber) do
			SCREENMAN:set_input_redirected(player, false)
		end
		self:visible(false)
	end,
	-- slightly darken the entire screen
	Def.Quad {
		InitCommand=function(self)
			self:FullScreen():diffuse(Color.Black):diffusealpha(0.8)
		end
	},
}

local overlay = Def.ActorFrame {
	Name="Overlay",
	InitCommand=function(self)
		self:xy(_screen.cx, _screen.cy + 40)
	end,

	AssessCandidatesCommand=function(self, params)
		self:GetChild("SearchText"):playcommand("UpdateText", params)
		self:GetChild("NumResults"):playcommand("UpdateText", params)
		local candidates = {}
		for candidate in ivalues(params.candidates) do
			table.insert(candidates, {
				index=#candidates,
				songOrExit=candidate,
				totalItems=#params.candidates + 1
			})
		end
		table.insert(candidates, {
			index=#candidates,
			songOrExit="Exit",
			totalItems=#params.candidates + 1
		})
		-- candidatesScroller.disable_wrapping = true
		-- candidatesScroller.focus_pos = 1
		candidatesScroller:set_info_set(candidates, 1)
		self:playcommand("UpdateScrollbar",  {numCandidates = #params.candidates})
	end,

	-- White border
	Def.Quad {
		InitCommand=function(self)
			self:diffuse(Color.White)
			self:zoomto(paneWidth + borderWidth, paneHeight + borderWidth)
		end,
	},

	-- Main black body
	Def.Quad {
		InitCommand=function(self)
			self:diffuse(Color.Black)
			self:zoomto(paneWidth, paneHeight)
		end,
	},

	Def.Quad {
		InitCommand=function(self)
			self:diffuse(color("0.2,0.2,0.2"))
			self:zoomto(borderWidth, paneHeight - 10)
		end,
	},

	LoadFont("Common Normal").. {
		Text="Search Results For:",
		InitCommand=function(self)
			self:diffuse(Color.White)
			self:y(-paneHeight/2 - textHeight * 5)
		end,
	},

	LoadFont("Common Normal").. {
		Name="SearchText",
		InitCommand=function(self)
			self:diffuse(Color.White)
			self:y(-paneHeight/2 - textHeight * 3)
		end,
		UpdateTextCommand=function(self, params)
			self:settext("\""..params.searchText.."\"")
			self:AddAttribute(1, {Length=#self:GetText()-2; Diffuse=Color.Green})
		end,
	},

	LoadFont("Common Normal").. {
		Name="NumResults",
		InitCommand=function(self)
			self:diffuse(Color.White)
			self:maxwidth(paneWidth/2)
			self:y(-paneHeight/2 - textHeight)
		end,
		UpdateTextCommand=function(self, params)
			self:settext(#params.candidates.." Results Found")
		end
	},

	candidatesScroller:create_actors("Candidates", 12, candidateItemMt, -paneWidth/4, -paneHeight/2 - textHeight * 2.5)
}

local songDetails = {
	{ "Pack", function(song) return song:GetGroupName() end },
	{ "Song", function(song) return song:GetDisplayMainTitle() end },
	{ "Subtitle", function(song) return song:GetDisplaySubTitle() end },
	{ "Artist", function(song) return song:GetDisplayArtist() end },
	{ "BPMs", function(song)
		local bpms = song:GetDisplayBpms()
		if bpms[2]-bpms[1] == 0 then
			return string.format("%.0f", bpms[1])
		else
			return string.format("%.0f - %.0f", bpms[1], bpms[2])
		end
	end },
	{ "Difficulties", function(song)
		local stepsType = GAMESTATE:GetCurrentStyle():GetStepsType()
		local difficulties = {
			"Difficulty_Beginner",
			"Difficulty_Easy",
			"Difficulty_Medium",
			"Difficulty_Hard",
			"Difficulty_Challenge"
		}
		local outstring = ""
		for difficulty in ivalues(difficulties) do
			local steps = song:GetOneSteps(stepsType, difficulty)
			if steps then
				outstring = outstring .. steps:GetMeter() .. "   "
			end
		end
		return outstring
	end },
}

for i, details in ipairs(songDetails) do
	local name = details[1]
	local formatter = details[2]
	overlay[#overlay+1] = LoadFont("Common Normal").. {
		Name=name,
		Text=name..": ",
		InitCommand=function(self)
			local zoom = 0.8
			self:diffuse(color("#aaaaff")):zoom(zoom):maxwidth(145/zoom):horizalign(left)
			self:xy(10, -paneHeight/2 + textHeight * zoom * (i*2-1) + 8*(i*2-1))
		end,
		UpdateSearchResultMessageCommand=function(self, params)
			local songOrExit = params.songOrExit
			if type(songOrExit) == "string" then
				self:visible(false)
			else
				self:visible(true)
			end
		end,
	}

	overlay[#overlay+1] = LoadFont("Common Normal").. {
		Name=name.."Text",
		Text=name,
		InitCommand=function(self)
			local zoom = 0.8
			self:diffuse(Color.White):zoom(zoom):maxwidth(115/zoom):horizalign(left)
			self:xy(40, -paneHeight/2 + textHeight * zoom * (i*2) + 8*(i*2))
		end,
		UpdateSearchResultMessageCommand=function(self, params)
			local songOrExit = params.songOrExit
			if type(songOrExit) == "string" then
				self:visible(false)
			else
				self:visible(true)
				self:settext(formatter(songOrExit))
			end
		end
	}
end

af[#af+1] = overlay


return af
