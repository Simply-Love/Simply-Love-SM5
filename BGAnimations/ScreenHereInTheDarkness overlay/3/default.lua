-- the season was spring
-- and that day it was raining
-- the day I met Her
--
-- Her hair, and mine, too
-- were dense with humidity
-- and the scent of rain
--
-- the earth continued
-- quietly turning with us
-- aboard, unknowing
--
-- our bodies losing
-- heat peacefully to other
-- spaces, darknesses
--
-- on that day I was
-- picked up by Her; that is why
-- I am now Her cat

local haiku = {
	{
		{
			1.915,
			3.830,
			"here in the darkness"
		},
		{
			5.745,
			7.660,
			"that knows no end, the earth turns"
		},
		{
			{
				10.213,
				11.489,
				"quiet"
			},
			{
				11.489,
				12.766,
				"like"
			},
			{
				12.447,
				14.200,
				"our"
			},
			{
				13.404,
				14.681,
				"hearts"
			},
	 	},
	},
	{
		{
			17.234,
			19.149,
			"hoping that one day",
		},
		{
			21.064,
			22.979,
			"all the turning will make sense"
		},
		{
			{
				24.894,
				26.170,
				"in getting"
			},
			{
				26.809,
				28.085,
				"us"
			},
			{
				28.723,
				30.000,
				"here"
			}
		}
	}
}

local timing = {}
for i=1,#haiku do
	for line=1, #haiku[i] do
		if type(haiku[i][line][3]) ~= "string" then
			for word=1, #haiku[i][line] do
				table.insert(timing, {haiku[i][line][word][1], haiku[i][line][word][2]})
			end
		else
			table.insert(timing, {haiku[i][line][1], haiku[i][line][2]})
		end
	end
end

-----------------------------------------------------------------

local y_offset = 25
local x_offset = 60
local line_height   = 19
local haiku_spacing = 80
local fadein_time   = 2
local font_path = THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini")

local refs = {}

-----------------------------------------------------------------

local index = 1
local time_at_start, uptime

local Update = function(self, dt)
	if time_at_start == nil then return end

	uptime = GetTimeSinceStart() - time_at_start

	if timing[index] and uptime >= timing[index][1] - 0.25 then
		refs[index]:smooth( timing[index][2]-timing[index][1] ):diffusealpha(1)
		index = index + 1
	end
end
-----------------------------------------------------------------

local af = Def.ActorFrame{}
af.InitCommand=function(self) self:SetUpdateFunction( Update ) end
af.OnCommand=function(self) time_at_start = GetTimeSinceStart() end
af.InputEventCommand=function(self, event)
	if event.type == "InputEventType_FirstPress" and (event.GameButton=="Start" or event.GameButton=="Back") then
		self:smooth(1):diffuse(0,0,0,1):queuecommand("NextScreen")
	end
end
af.NextScreenCommand=function(self)
	SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
end


af[#af+1] = LoadActor("./quietly-turning.ogg")..{
	OnCommand=function(self) self:play() end
}

af[#af+1] = LoadActor("./earth.png")..{
	InitCommand=function(self) self:halign(0):valign(1):xy(0,_screen.h):zoom(0.5):diffusealpha(0) end,
	OnCommand=function(self) self:sleep(1):smooth(2):diffusealpha(1) end
}

for i=1,#haiku do
	for line=1, #haiku[i] do

		-- add a line, word by word
		if type(haiku[i][line][3]) ~= "string" then

			local line_width = 0

			for word=1, #haiku[i][line] do
				af[#af+1] = Def.BitmapText{
					File=font_path,
					Text=haiku[i][line][word][3],
					InitCommand=function(self)
						table.insert(refs, self)

						self:align(0,0):zoom(0.85):diffusealpha(0)
						self:x((_screen.cx-100) + i*x_offset + line_width)
						self:y(((line-1)*line_height) + (y_offset+(i-1)*haiku_spacing))

						-- accumulate current line_width as more words are added to the line
						-- 5px of whitespace between each word works well enough here
						line_width = line_width + (self:GetWidth() * self:GetZoom()) + 5
					end,
				}
			end

		-- add a line
		else
			af[#af+1] = Def.BitmapText{
				File=font_path,
				Text=haiku[i][line][3],
				InitCommand=function(self)
					table.insert(refs, self)

					self:align(0,0):zoom(0.85):diffusealpha(0)
					self:x((_screen.cx-100) + i*x_offset)
					self:y(((line-1)*line_height) + (y_offset+(i-1)*haiku_spacing))
				end,
			}
		end
	end
end

return af