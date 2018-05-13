-- doubts

local bgm_volume = 10
local time_in_scene, old_time = 0, 0
local scene_duration = 30

local bmt, cursor
local char_width = 12
local chars_per_line = 60
local font_zoom = 0.65
local terminal_width = char_width*chars_per_line*font_zoom

-- me, an intellectual: "fewer ./butterflies"
local command = "less ./butterflies"
local smitten = "QW5kIHNvLCBzdWRkZW5seSwgYWZ0ZXIgbmVhcmx5IGZpdmUgeWVhcnMgb2Ygb25seSBlbWFpbHMgYW5kIGluc3RhbnQgbWVzc2FnZXMsIHdlIHdlcmUgYWJsZSB0byBTa3lwZSBiZWNhdXNlIHRoZSBzdGF0ZSBvZiB0ZWNobm9sb2d5IHBlcm1pdHRlZCBpdCwgYW5kIEkgaGFkIGEgdm9pY2UgYW5kIGZhY2UgdG8gYXNzb2NpYXRlIHdpdGggYSBwZXJzb25hbHR5LiAgT3VyIGZyaWVuZHNoaXAgZXhwYW5kZWQgaW50byBuZXcgZGltZW5zaW9ucyBhdCB0aGF0IG1vbWVudC4KCkl0IHN0cmlrZXMgbWUgbm93LCB5ZWFycyBsYXRlciwgaG93IHBhdGllbnQgd2Ugd2VyZSwgaGF2aW5nIGV4Y2hhbmdlZCB3b3JkcyBvdmVyIHRoZSBpbnRlcm5ldCBmb3IgeWVhcnMgd2l0aG91dCBldmVyIGFza2luZyB0byBzZWUgb3IgaGVhciB0aGUgcGVyc29uIG9uIHRoZSBvdGhlciBlbmQuICBUaGVzZSBkYXlzLCBwZW9wbGUgZ2V0IGFuZ3J5IHdpdGggeW91IGZvciBub3QgaGF2aW5nIGFuIE9rQ3VwaWQgcGhvdG8gZGVtb25zdHJhYmx5IHJldmVhbGluZyB5b3VyIGN1cCBzaXplLgoKIldlcmUgeW91IGluc3RhbnRseSBzbWl0dGVuIGJ5IGhlciBiZWF1dHksIGJlaW5nIGZpbmFsbHkgYWJsZSB0byBzZWUgaGVyPyIKCkkgZG9uJ3Qga25vdy4gIEkgZGlkbid0IHJlYWxseSB0aGluayBvZiBpdCBsaWtlIHRoYXQgYXQgdGhlIHRpbWUsIGJlY2F1c2UgSSdkIGFscmVhZHkgYmVlbiBzbWl0dGVuIGJ5IGhlciB3b3JkcyBsb25nIGJlZm9yZSB0aGF0LiAgU2hlJ2QgZGVtb25zdHJhdGVkIGFuIHV0dGVybHkgY2FwdGl2YXRpbmcgY29tbWFuZCBvZiBsYW5ndWFnZSBmcm9tIHRoZSBzdGFydCwgYWJsZSB0byBiZSBwbGF5ZnVsIGFuZCB3aXR0eSBhbmQgZGVlcGx5IGluY2lzaXZlIGFsbCBhdCBvbmNlIGluIGEgc2luZ2xlIHNlbnRlbmNlLiAgSSBzd2VhciwgaGVyIHdvcmRzIGtlcHQgbWUgYWxpdmUgc29tZSBuaWdodHMu"

local Update = function(af, delta)
	if old_time <= 0 then
		old_time = GetTimeSinceStart()
	else
		time_in_scene = GetTimeSinceStart() - old_time
	end
end

local af = Def.ActorFrame{
	StartSceneCommand=function(self)
		self:visible(true):SetUpdateFunction(Update)
	end,
	InputEventCommand=function(self, event)
		if (time_in_scene >= scene_duration) or (bmt:GetText():len() >= smitten:len()) then
			if event.type == "InputEventType_FirstPress" and (event.GameButton=="Start" or event.GameButton=="Back") then
				self:GetParent():queuecommand("TransitionScene")
			end
		elseif time_in_scene > 0 and time_in_scene < scene_duration then
			if event.type == "InputEventType_FirstPress" then
				bmt:playcommand("Type")
			end
		end
	end
}

af[#af+1] = Def.Sound{
	File=THEME:GetPathB("ScreenRabbitHole", "overlay/17/Since.ogg"),
	StartSceneCommand=function(self) self:play() end,
	FadeOutAudioCommand=function(self)
		if bgm_volume >= 0 then
			local ragesound = self:get()
			bgm_volume = bgm_volume-1
			ragesound:volume(bgm_volume*0.1)
			self:sleep(0.1):queuecommand("FadeOutAudio")
		end
	end
}

-- cursor
af[#af+1] = Def.Quad{
	InitCommand=function(self)
		cursor = self
		self:align(0,0):xy(_screen.cx-terminal_width/2 + char_width/2 - 2, 50-6):zoomto(1,14)
			:diffuseblink():effectperiod(1):effectcolor1(0,0,0,1):effectcolor2(0.9,0.9,0.9,1)
	end,
	MoveCommand=function(self) self:addx( char_width*font_zoom) end,
	HideCommand=function(self) self:visible( false ) end
}

af[#af+1] = Def.BitmapText{
	File=THEME:GetPathB("ScreenRabbitHole", "overlay/_shared/monaco/_monaco 20px.ini"),
	InitCommand=function(self)
		bmt = self
		self:xy(_screen.cx-terminal_width/2, 50):align(0,0)
			:zoom(font_zoom)
	end,
	TypeCommand=function(self)
		if self:GetText():len() < command:len() then
			cursor:playcommand("Move")
			self:settext( command:sub(1, self:GetText():len()+1) )
		else
			local s = ""
			cursor:playcommand("Hide")
			for i=0, math.ceil(smitten:len()/chars_per_line) do
				s = s .. smitten:sub(i*chars_per_line+1, i*chars_per_line+chars_per_line) .. "\n"
			end
			self:settext( s )
		end
	end
}

return af
