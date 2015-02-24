return Def.Actor{
	InitCommand=cmd(queuecommand,"Capture"),
	CaptureCommand=function(self)

		local Wheel = SCREENMAN:GetTopScreen():GetChild("MusicWheel")
		local Items = Wheel:GetChild("MusicWheelItem")
		local Highlight = Wheel:GetChild("Highlight")

		-- the parent MusicWheel has already had diffuselapha(0) applied via Metrics
		-- see: MusicWheelOnCommand under [ScreenSelectMusic]
		--
		-- So, the parent is hidden, but we want to now apply a diffusealpha(0) to
		-- each child MusicWheelItem.  This is admittedly hackish, but I haven't found
		-- a better way to do this yet.
		for key, item in ipairs(Items) do
			item:diffusealpha(0)
		end

		-- unhide the parent MusicWheel first
		-- the children MusicWheelItems will still be hidden
		Wheel:diffusealpha(1)

		-- the MusicWheel is interesting in that it appears to index its children (MusicWheelItems)
		-- like this (from top to bottom of the screen): 1, 2, 3, 4, 5, 6, 12, 11, 10, 9, 8, 7

		-- so, sleep the first (top) half of the Items in a linearly incrementing fashion
		for i=1, #Items/2 do
			Items[i]:sleep(i/20)
		end

		-- decrement through the second (bottom) half of the Items
		-- incrementing the sleep time as we go.  This is awkward and weird, yes, but
		-- it is necessary to achieve the illusion of MusicWheelItems cascading into appearance
		-- top to bottom given the peculiar indexing pattern they demonstrate.
		local j = #Items/2 + 1
		for i=#Items, j, -1 do
			Items[i]:sleep(j/20)
			j = j+1
		end
		Highlight:sleep(j/20)

		-- with appropriate sleep times applied, tween into appearance
		for key, item in ipairs(Items) do
			item:linear(0.12)
			item:diffusealpha(1)
		end

		Highlight:linear(0.2)
		Highlight:diffuseshift()
		Highlight:effectcolor1(0.8,0.8,0.8,0.3)
		Highlight:effectcolor2(0.8,0.8,0.8,0.05)
		Highlight:diffusealpha(1)
	end
}