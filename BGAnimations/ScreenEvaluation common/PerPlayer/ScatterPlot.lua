-- if we're in CourseMode, bail now
-- the normal LifeMeter graph (Def.GraphDisplay) will be drawn
if GAMESTATE:IsCourseMode() then return Def.Actor{} end

-- arguments passed in from Graphs.lua
local args = ...
local player = args.player
local GraphWidth = args.GraphWidth
local GraphHeight = args.GraphHeight

-- sequential_offsets gathered in ./BGAnimations/ScreenGameplay overlay/JudgmentOffsetTracking.lua
local sequential_offsets = SL[ToEnumShortString(player)].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1].sequential_offsets

-- a table to store the AMV's vertices
local verts= {}
-- TotalSeconds is used in scaling the x-coordinates of the AMV's vertices
local FirstSecond = GAMESTATE:GetCurrentSong():GetFirstSecond()
local TotalSeconds = GAMESTATE:GetCurrentSong():GetLastSecond() - FirstSecond

-- variables that will be used and re-used in the loop while calculating the AMV's vertices
local Offset, CurrentSecond, TimingWindow, x, y, TempQuad

-- ---------------------------------------------
-- Standard colors, but with slight opacity.
local colors = {
	Competitive = {
		color("#21CCE8aa"),	-- blue
		color("#e29c18aa"),	-- gold
		color("#66c955aa"),	-- green
		color("#5b2b8eaa"),	-- purple
		color("#c9855eaa"),	-- peach?
		color("#ff0000aa")	-- red
	},
	ECFA = {
		color("#21CCE8aa"),	-- blue
		color("#ffffffaa"),	-- white
		color("#e29c18aa"),	-- gold
		color("#66c955aa"),	-- green
		color("#5b2b8eaa"),	-- purple
		color("#ff0000aa")	-- red
	},
	StomperZ = {
		color("#FFFFFFaa"),	-- white
		color("#e29c18aa"),	-- gold
		color("#66c955aa"),	-- green
		color("#21CCE8aa"),	-- blue
		color("#000000aa"),	-- black
		color("#ff0000aa")	-- red
	}
}

-- ---------------------------------------------
-- if players have disabled W4 or W4+W5, there will be a smaller pool
-- of judgments that could have possibly been earned
local num_judgments_available = (SL.Global.ActiveModifiers.DecentsWayOffs=="Decents Only" and 4) or (SL.Global.ActiveModifiers.DecentsWayOffs=="Off" and 3) or 5
local worst_window = SL.Preferences[SL.Global.GameMode]["TimingWindowSecondsW"..num_judgments_available]
-- ---------------------------------------------

-- the scater plot will use an ActorMultiVertex in "Quads" mode
-- this is more efficient than drawing n Def.Quads (one for each judgment)
-- because the entire AMV will be a single Actor rather than n Actors with n unique Draw() calls.
--
-- This AMV is probably less efficient than using an ActorFrameTexture with a single Quad
-- and EnablePreserveTexture(true) set, but I don't understand AFTs well enough.  I was having
-- problems with texture garbage showing up and sporadic crashes...
local amv = Def.ActorMultiVertex{
	OnCommand=function(self)
		self:x(-GraphWidth/2)
			:y(_screen.cy + 151 - GraphHeight/2 - 1)
			:SetDrawState{Mode="DrawMode_Quads"}

		for t in ivalues(sequential_offsets) do
            CurrentSecond = t[1]
            Offset = t[2]

            x = scale(CurrentSecond-FirstSecond, 0 , TotalSeconds, 0, GraphWidth)

            if Offset ~= "Miss" then
				-- DetermineTimingWindow() is defined in ./Scripts/SL-Helpers.lua
                TimingWindow = DetermineTimingWindow(Offset)
                y = scale(Offset, worst_window, -worst_window, 0, GraphHeight)

				table.insert( verts, {{x, y, 0}, colors[SL.Global.GameMode][TimingWindow]} )
				table.insert( verts, {{x+1.5, y, 0}, colors[SL.Global.GameMode][TimingWindow]} )
				table.insert( verts, {{x+1.5, y+1.5, 0}, colors[SL.Global.GameMode][TimingWindow]} )
				table.insert( verts, {{x, y+1.5, 0}, colors[SL.Global.GameMode][TimingWindow]} )
            else

				table.insert( verts, {{x, 0, 0}, color("#ff000077")} )
				table.insert( verts, {{x+1, 0, 0}, color("#ff000077")} )
				table.insert( verts, {{x+1, GraphHeight, 0}, color("#ff000077")} )
				table.insert( verts, {{x, GraphHeight, 0}, color("#ff000077")} )
            end
		end

		self:SetVertices(verts)
    end,
}

return amv