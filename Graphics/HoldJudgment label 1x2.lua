-- This actor doesn't seem to have any "easy" access to the particular Player it will be used for.
-- Getting the Player ActorFrame in the BeginCommand works, but feels a little hack-ish
-- and will likely break in whatever edge cases I'm not considering.
--
-- SM5.1's default theme uses ./Graphics/NoteColumn layers.lua to dynamically load HoldJudgments,
-- which seems to make use of SM5's NoteColumn system.  I can dig into that when this fails.

return Def.Sprite{
	BeginCommand=function(self)
		local label = "None"

		if self:GetParent() and self:GetParent():GetParent() then
			-- self:GetParent():GetParent() will return the main Player ActorFrame
			-- with a name like "PlayerP1" or "PlayerP2"
			-- we can use the "P1" or "P2" part of the string to index the SL table
			local pn = self:GetParent():GetParent():GetName():gsub("Player", "")
			label = SL[pn].ActiveModifiers.HoldJudgment or "None"
		end

		if label == "None" then
			self:visible(false)
			return
		end

		self:Load(THEME:GetPathG("", "_HoldJudgments/" .. label))
	end
}