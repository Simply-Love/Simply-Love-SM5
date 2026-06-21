-- This actor doesn't seem to have any "easy" access to the particular Player it will be used for.
-- Getting the Player ActorFrame in the BeginCommand works, but feels a little hack-ish
-- and will likely break in whatever edge cases I'm not considering.
--
-- SM5.1's default theme uses ./Graphics/NoteColumn layers.lua to dynamically load HoldJudgments,
-- which seems to make use of SM5's NoteColumn system.  I can dig into that when this fails.

return Def.Sprite{
	BeginCommand=function(self)
		local label = nil

		-- self:GetParent():GetParent() is the main Player ActorFrame.
		local playerAf = self:GetParent() and self:GetParent():GetParent()
		-- We can't just check playerAf:GetName() here because the player actor
		-- frames don't have their names set on ScreenEdit.
		for _, player in ipairs(PlayerNumber) do
			local pn = ToEnumShortString(player)
			if playerAf and playerAf == GetPlayerAF(pn) then
				label = SL[pn].ActiveModifiers.HoldJudgment
				break
			end
		end

		label = label or "None 1x2.png"

		self:Load(THEME:GetPathG("", "_HoldJudgments/" .. label))
	end
}
