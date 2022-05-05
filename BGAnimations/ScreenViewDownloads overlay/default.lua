-- sick_wheel_mt is a metatable with global scope defined in ./Scripts/Consensual-sick_wheel.lua
local candidatesScroller = setmetatable({}, sick_wheel_mt)
local candidateItemMt = LoadActor("CandidateItemMT.lua")
local inputHandler = LoadActor("InputHandler.lua", candidatesScroller)

-- We except size of the SL.Downloads to be constant while on this screen.
local size = 0
for _, _ in pairs(SL.Downloads) do
	size = size + 1
end

local af = Def.ActorFrame{
	Name="DownloadsViewer",
	InitCommand=function(self) self:Center() end,
	OnCommand=function(self)
		local candidates = {}
		for uuid, downloadInfo in pairs(SL.Downloads) do
			table.insert(candidates, {
				index=#candidates,
				downloadInfo=downloadInfo,
				totalItems=size,
				uuid=uuid
			})
		end
		candidatesScroller.disable_wrapping = true
		candidatesScroller:set_info_set(candidates, 1)
		self:playcommand("UpdateScrollbar",  {numCandidates = size})
		SCREENMAN:GetTopScreen():AddInputCallback(inputHandler)
		self:queuecommand("RefreshStatus")
	end,

	candidatesScroller:create_actors("Candidates", 6, candidateItemMt, -240, -240),

	RefreshStatusCommand=function(self)
		local finished = 0
		local total = 0

		for _, downloadInfo in pairs(SL.Downloads) do
			if downloadInfo.Complete then
				finished = finished + 1
			end
			total = total + 1
		end

		self:GetChild("Completed"):settext(finished.."/"..total)

		for idx1, idx2 in ipairs(candidatesScroller.info_map) do
			candidatesScroller.items[idx1]:set(candidatesScroller.info_set[idx2])
		end

		-- Refresh the status if there is at least one pending download.
		if finished ~= total then
			self:sleep(0.1):queuecommand("RefreshStatus")
		end
	end
}

af[#af+1] = Def.BitmapText{
	Text=THEME:GetString("Common", "PopupDismissText"),
	Font="Common Normal",
	InitCommand=function(self)
		self:y(170)
	end,
}

af[#af+1] = Def.BitmapText{
	Name="Completed",
	Text="",
	Font="Common Normal",
	InitCommand=function(self)
		self:xy(220, 170):horizalign('HorizAlign_Right')
	end,
}

return af