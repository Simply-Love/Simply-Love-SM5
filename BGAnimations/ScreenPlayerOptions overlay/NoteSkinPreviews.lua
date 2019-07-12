local t = ...

local game_name = GAMESTATE:GetCurrentGame():GetName()
local column = {
	dance = "Up",
	pump = "UpRight",
	techno = "Up",
	kb7 = "Key1"
}

local GetNoteSkinActor = function(ns)

	local status, noteskin_actor = pcall(NOTESKIN.LoadActorForNoteSkin, NOTESKIN, column[game_name] or "Up", "Tap Note", ns)

	if noteskin_actor then
		return noteskin_actor..{
			Name="NoteSkin_"..ns,
			InitCommand=function(self) self:visible(false) end
		}
	else
		SM( Screen.String("NoteSkinErrors"):format(ns) )

		return Def.Actor{
			Name="NoteSkin_"..ns,
			InitCommand=function(self) self:visible(false) end
		}
	end
end

-- Add noteskin actors to the primary AF and hide them immediately.
-- We'll refer to these later via ActorProxy in ./Graphics/OptionRow Frame.lua
for noteskin in ivalues( CustomOptionRow("NoteSkin").Choices ) do
	t[#t+1] = GetNoteSkinActor(noteskin)
end