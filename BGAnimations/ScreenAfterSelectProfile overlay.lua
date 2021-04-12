return Def.Actor{
	InitCommand=function(self)
		-- ScreenSelectProfile's Finish() method is hardcoded to assign DefaultProfileIDs
		-- which will interfere with SL's notion of NOT requiring all players to use profiles.
		-- If the player went out of their way to enable ScreenSelectProfile, they presumably want
		-- to be able to pick, and picking (to me) means having an option for not-using-a-profile.
		PREFSMAN:SetPreference("DefaultLocalProfileIDP1", "")
		PREFSMAN:SetPreference("DefaultLocalProfileIDP2", "")

		self:queuecommand("Transition")
	end,
	TransitionCommand=function(self)
		-- if any players were temporarily unjoined during ScreenSelectProfile's OffCommand
		-- in order to allow us to proceed past the screen's Finish() method, those players
		-- will have been stuffed into a table at SL.Global.PlayersToRejoin with the expectation
		-- that SL would silently/transparently rejoin them on the next screen without anyone
		-- needing to care about the smoke-and-mirrors nature of SM5 theming.
		--
		-- We're here on the next screen, so rejoin any players that were previously unjoined.
		if type(SL.Global.PlayersToRejoin) == "table" then
			for player in ivalues(SL.Global.PlayersToRejoin) do
				-- JoinPlayer() does not deduct credits
				GAMESTATE:JoinPlayer(player)
			end
		end
		-- reset this to nil now so values don't accidentally persist into the next game cycle
		SL.Global.PlayersToRejoin = nil

		-- and proceed to whatever the next screen should be
		SCREENMAN:SetNewScreen( Branch.AllowScreenSelectColor() )
	end
}