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
				"PSU SOWNDS/Look What You Made Me Do",
				"PSU SOWNDS/Shape of You",
				"PSU SOWNDS/Starboy",
				"PSU SOWNDS/Hello",
				"PSU SOWNDS/Hotline Bling",
				"PSU SOWNDS/Cheap Thrills (feat. Sean Paul",
				"PSU SOWNDS/24K Magic",
				"PSU SOWNDS/Rockstar",
				"PSU SOWNDS/Despacito (feat. Justin Bieber)",
				"PSU SOWNDS/Bad Blood",
				"PSU SOWNDS/Cake By The Ocean",
				"PSU SOWNDS/Black Beatles (feat. Gucci Mane)",
				"PSU SOWNDS/HUMBLE.",
				"PSU SOWNDS/Bad & Boujee",
				"PSU SOWNDS/I'm the One (feat. Justin Bieber, Quavo, & Chance the Rapper)",
				"PSU SOWNDS/That's What I Like",
				"PSU SOWNDS/Bodak Yellow",
			}
		end

		local s = SONGMAN:FindSong( t[ math.random(1,#t) ] )
		GAMESTATE:SetPreferredSong( s )
	end
}