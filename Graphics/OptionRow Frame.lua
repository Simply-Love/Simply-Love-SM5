-- left/right padding from screen edges
local padding = WideScale(12, 28)

-- OptionRow height and width
local row_height = 30
local row_width  = WideScale(582, 776) - (padding * 2)

-- width of OptionRow area to the left that contains the row title
local title_bg_width = 115

local proxy_offset = _screen.cx - WideScale(30,40)

-- -----------------------------------------------------------------------

local t = Def.ActorFrame{}

-- a row
t[#t+1] = Def.Quad {
	Name="RowBackgroundQuad",
	InitCommand=function(self)
		self:horizalign(left):x(padding)
		self:setsize(row_width , row_height)
	end
}

-- black quad behind the title
t[#t+1] = Def.Quad {
	Name="TitleBackgroundQuad",
	OnCommand=function(self)
		self:horizalign(left):x(padding)
		self:setsize(title_bg_width, row_height):diffuse(Color.Black)
		self:diffusealpha(DarkUI() and 0.8 or 0.25)
	end
}

-- -----------------------------------------------------------------------
-- Here's where the "magic" for visual previews in OptionRows happens.  D:
--
-- This feels pretty hackish.  But it works.  And is less work than writing my own options
-- system in pure Lua.
--
-- ScreenPlayerOptions overlay.lua has all the necessary NoteSkin actors, Judgment Font
-- actors, and Combo Font actors loaded but not showing.  That asset-loading code is over
-- in ./BGAnimations/ScreenPlayerOptions overlay/OptionRowPreviews/
--
-- Here, we're adding one ActorProxy per-player per-OptionRow and using them to draw
-- the NoteSkin, Judgment Font, Combo Font, etc. assets loaded elsewhere.  These
-- ActorProxies are what the player sees in each OptionRow.
--
------ WHAT DO ACTORPROXIES DO?
-- Out of the box, ActorProxies don't do or show anything, but they can be used to draw what
-- some other actor is already drawing.  This has the effect of visually duplicating one
-- actor into two (the actor + the ActorProxy).
--
-- ActorProxy actors are typically handy in scripted simfiles, where they can be used to
-- visually duplicate the entire Player ActorFrame or the LifeMeter or some other visual
-- element of ScreenGameplay that is defined outside the context of the simfile scripting.
--
-- From the Lua of a scripted simfile, you can't say "I want there to be five copies of the
-- playfield when the screen initializes" because by the time your simfile's Lua is
-- evaluated, the screen has already initialized and the Actors are in place.  ActorProxies
-- are generic.  You pass them a reference to an already-existing actor via SetTarget()
-- and they'll draw it.
--
-- As noted, this is more obviously handy in scripted simfiles.  In theming, if you need
-- two of some actor, you can usually just write your own theme code so that there are two
-- of that Actor.
--
------ WHAT ARE OPTIONROWS?
-- ScreenPlayerOptions uses the "OptionRow" system provided by the StepMania engine.  It's
-- a generic framework that allows players to scroll between multiple rows where each row has
-- multiple things to choose from.
--
------ HOW ARE OPTIONROWS LIMITED?
-- The OptionRow system only supports text as choices.  Not visual representations of
-- NoteSkins, not judgment graphic textures. Just text.  I really like being able to *show*
-- players what the NoteSkin looks like instead of just telling the name of it, but OptionRows
-- can only show text.
--
------ WHY USE OPTIONROWS IF THEY'RE SO LIMITED?
-- I like OptionRows because, as a system, it manages nearly all input handling out of the box,
-- including 3Key input (traditional DDR arcade cabs), 4Key input(ITG dedicabs), keyboard
-- input, etc. Handling input is complicated and tedious at best.
-- See ScreenSelectMusicCasual if you want an example.
--
------ HOW ARE YOU USING ACTORPROXIES TO DRAW VISUALS IN OPTIONROWS?
-- So, I stuffed one ActorProxy per-player into each OptionRow Frame and devised a hackish
-- system to have them draw NoteSkins in the NoteSkin row, and judgment textures in the
-- Judgment Font row, and etc.
--
-- Note that because this file (OptionRow Frame.lua) is generic and used to define the
-- background of *every* OptionRow, the PlayerOptions screen ends up getting a lot of
-- ActorProxies that it doesn't actually need.  The frame for the SpeedMod row has these
-- ActorProxies though it doesn't use them.  As does the SpeedModType.  As does the
-- background filter.  Etc.
--
-- I can't only add ActorProxies to rows that need them because this file is generic
-- and supposed to be used to tell StepMania what to make *all* OptionRows look like.
-- Once the screen and each OptionRow are initialized (OnCommand), it is possible to check
-- what this Frame's parent OptionRow's name is and, from there, call hibernate(math.huge)
-- on the ActorProxies we don't need.
--
-- If the parent OptionRow's name is "NoteSkin" or "JudgmentGraphic" or "ComboFont", we leave
-- it drawing and allow different Message commands broadcast from ./Scripts/SL-PlayerOptions.lua
-- to make this generic ActorProxy look like a NoteSkin or a JudgementGraphic or a ComboFont.
--
------ CONCLUSION
-- It's a hack, but it works.
--
-- It's less effort than writing my own options menu system in Lua.
-- It's also less effort than extending the engine's OptionRow system to handle more than text.
--
-- If you think this system/code is Bad and in need of a proper fix — I agree!  Please put
-- in the hours to implement a proper fix and the community will surely be better for it. :)
-- -----------------------------------------------------------------------

local rows_with_proxies = { "NoteSkin", "JudgmentGraphic", "ComboFont", "HoldJudgment", "MusicRate" }

for player in ivalues( GAMESTATE:GetHumanPlayers() ) do
	local pn = ToEnumShortString(player)

	local proxy = Def.ActorProxy{
		Name="VisualActorProxy" .. pn,
		OnCommand=function(self)
			local optrow = self:GetParent():GetParent():GetParent()

			if FindInTable(optrow:GetName(), rows_with_proxies) then
				-- if this OptionRow needs an ActorProxy for preview purposes, set the necessary parameters
				self:x(proxy_offset + (player==PLAYER_1 and WideScale(20, 0) or WideScale(220, 240)))
				self:zoom(0.4)
			else
				-- if this OptionRow doesn't need an ActorProxy, don't draw it and save processor cycles
				self:hibernate(math.huge)
			end
		end
	}

	-- RefreshActorProxy is broadcast by SaveSelections() for various OptionRow definitions
	-- in ./Scripts/SL-PlayerOptions.lua
	proxy.RefreshActorProxyMessageCommand=function(self, params)
		if player ~= params.Player then return end
		if not (params.Name and params.Value) then return end

		local optrow = self:GetParent():GetParent():GetParent()
		if optrow and optrow:GetName() == params.Name then

			local offscreen_actor_name
			if params.Name=="ComboFont" or params.Name=="MusicRate" then
				-- the BitmapTexts for ComboFont and MusicRate helper text need to be able to
				-- display different values per-player, so I prefixed the relevant Actors in
				--     ./BGA/ScreenPlayerOptions overlay/OptionRowPreviews/ComboFont.lua
				--     ./BGA/ScreenPlayerOptions overlay/OptionRowPreviews/MusicRate.lua
				-- with "P1_" or "P2_"
				offscreen_actor_name = ("%s_%s_%s"):format(pn, params.Name, params.Value)
			else
				offscreen_actor_name = ("%s_%s"):format(params.Name, params.Value)
			end

			-- attempt to find the offscreen actor added by ./BGAnimations/ScreenPlayerOptions overlay.lua
			local offscreen_actor = SCREENMAN:GetTopScreen():GetChild("Overlay"):GetChild(offscreen_actor_name)
			-- ensure that that actor exists before attempting to set it as the target of this ActorProxy
			if offscreen_actor then self:SetTarget( offscreen_actor ) end
		end
	end

	proxy.RefreshBPMRangeMessageCommand=function(self, params)
		local optrow = self:GetParent():GetParent():GetParent()
		if optrow and optrow:GetName() ~= "MusicRate" then return end
		if #GAMESTATE:GetHumanPlayers() <= 1 then
			self:visible(false)
			return
		end

		-- only show the MusicRate actorproxy when both players are joined
		-- and split BPMs are in effect
		self:visible( params[1] ~= params[2] )
	end

	table.insert(t, proxy)
end

return t