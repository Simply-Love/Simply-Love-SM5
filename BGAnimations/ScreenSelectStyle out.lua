return Def.ActorFrame{
	OffCommand=cmd(queuecommand, "Style"; sleep, 0.8),
	StyleCommand=function(self)
		SL.Global.Gamestate.Style = GAMESTATE:GetCurrentStyle():GetName()

		local t
		if SL.Global.Gamestate.Style == "double" then
			t = {
				"dbk4/Jumper",
				"dbk5/Push and Rise v3",
				"dbk5/Que Veux Tu",
				"DDR 13th Mix X3/COME BACK TO MY HEART",
				"DDR 2013/New Gravity",
				"DDR Universe/Koibito",
				"DDR Universe/September '99",
				"DDR Universe/Love Is On Our Side",
				"PROJECT OBSIDIAN/Round and Round",
				"r21 Bringin' It Back/chocolate disco",
				"Sudziosis 4/Shady Business",
				"Sudziosis 5/Love Bird",
			}
		else
			t = {
				"PSU SOWNDS/Ain't Nobody (Loves Me Better)",
				"PSU SOWNDS/Happy",
				"PSU SOWNDS/Trap Queen",
				"PSU SOWNDS/Levels",
				"PSU SOWNDS/Rather Be",
				"PSU SOWNDS/Somebody Told Me",
				"PSU SOWNDS/Teenage Dream (Liam Keegan Remix)",
				"PSU SOWNDS/Cheerleader (Felix Jaehn Mix)",
				"PSU SOWNDS/Cake By The Ocean",
				"PSU SOWNDS/Heartbeat Song",
				"PSU SOWNDS/G.D.F.R",
				"PSU SOWNDS/I Really Like You",
				"PSU SOWNDS/Moves Like Jagger",
				"PSU SOWNDS/Stronger (What Doesn't Kill You)",
				"PSU SOWNDS/Summertime Sadness (Cedric Gervais Mix)",
				"PSU SOWNDS/Juicy Wiggle",
				"PSU SOWNDS/Peanut Butter Jelly",
			}
		end

		local s = SONGMAN:FindSong( t[ math.random(1,#t) ] )
		GAMESTATE:SetPreferredSong( s )
	end
}