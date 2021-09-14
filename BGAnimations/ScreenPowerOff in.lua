return Def.ActorFrame {
	OnCommand=function(self)
		Warn([[
The following is a harmless warning, designed to be parsed from the Stepmania
logs by the startup script to power off the computer afterwards. If you just
happen to use this theme outside Mäkkylä without that script, well, too bad.
Sorry about the menu option that doesn't do anything for you!
]])

		-- Random UUID is the actual thing meant to be parsed. Just in case someone
		-- happens to make a stepchart to a song called "LETS POWER OFF" and that
		-- ends up in the logs.

		-- Yes there is maybe an actual way to communicate to outside world with
		-- Stepmania. Writing a file would work but eeeeehh I don't want to figure
		-- out how what is the path of ~/.stepmania-5.1 from Lua.
		Warn("LETS POWER OFF: 5b5c513e-7067-4a14-89de-1fa007d93a33")	

		SCREENMAN:SetNewScreen("ScreenExit")
	end
}
