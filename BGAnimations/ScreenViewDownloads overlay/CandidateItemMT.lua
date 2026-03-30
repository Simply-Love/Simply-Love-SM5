local paneHeight = 319
local paneWidth = 319

local barWidth = 350
local separatorWidth = 480

local bytesToSize = function(bytes)
	local suffixes = { "bytes", "KiB", "MiB" }
	local index = 1
	local divisor = 1

	while bytes >= 1024 and index < 3 do
		bytes = math.floor(bytes / 1024)
		divisor = divisor * 1024
		index = index + 1
	end
	return suffixes[index], divisor
end

return {
	__index = {
		create_actors = function(self, name)
			self.name=name

			local af = Def.ActorFrame{
				Name=name,

				InitCommand=function(subself)
					self.container = subself
					subself:MaskDest()
					subself:diffusealpha(0)
				end,
			}

			-- Download Name
			af[#af+1] = Def.BitmapText{
				Font=ThemePrefs.Get("ThemeFont") .. " Normal",
				Name="DownloadName",
				InitCommand=function(subself)
					self.download_name = subself
					subself:y(0):diffusealpha(0):maxwidth(480):horizalign('HorizAlign_Left')
				end,
			}

			af[#af+1] = Def.Quad{
				Font=ThemePrefs.Get("ThemeFont") .. " Normal",
				Name="ProgressBar",
				InitCommand=function(subself)
					self.progress_bar = subself
					subself:zoomto(1, 20):horizalign('HorizAlign_Left'):xy(0, 25):diffusealpha(0)
				end,
			}

			af[#af+1] = LoadActor("swoosh.png")..{
				Name="Swoosh",
				InitCommand=function(subself)
					self.swoosh = subself
					subself:zoomto(1, 20):horizalign('HorizAlign_Left'):xy(0, 25):diffusealpha(0):customtexturerect(0,0,1,1):texcoordvelocity(-1, 0)
				end,
			}

			af[#af+1] = Def.Quad{
				Font=ThemePrefs.Get("ThemeFont") .. " Normal",
				Name="Endpoint",
				InitCommand=function(subself)
					self.endpoint = subself
					subself:zoomto(3, 20):xy(barWidth, 25):diffuse(Color.Red):diffusealpha(0)
				end,
			}

			af[#af+1] = Def.BitmapText{
				Font=ThemePrefs.Get("ThemeFont") .. " Normal",
				Name="Message",
				InitCommand=function(subself)
					self.message = subself
					subself:y(25):diffusealpha(0):maxwidth(barWidth):horizalign('HorizAlign_Left'):diffuse(Color.Red)
				end,
			}

			-- Percentage
			af[#af+1] = Def.BitmapText{
				Text="0%",
				Font=ThemePrefs.Get("ThemeFont") .. " Normal",
				Name="Percentage",
				InitCommand=function(subself)
					self.percentage = subself
					subself:xy(barWidth + 50, 25):diffusealpha(0):horizalign('HorizAlign_Right')
				end,
			}

			af[#af+1] = Def.BitmapText{
				Text="99/100",
				Font=ThemePrefs.Get("ThemeFont") .. " Normal",
				Name="DownloadAmount",
				InitCommand=function(subself)
					self.download_amount = subself
					subself:xy(barWidth + 60, 25):diffusealpha(0):horizalign('HorizAlign_Left')
				end,
			}

			af[#af+1] = Def.Quad{
				Font=ThemePrefs.Get("ThemeFont") .. " Normal",
				Name="Separator",
				InitCommand=function(subself)
					self.separator = subself
					subself:zoomto(separatorWidth, 1):xy(separatorWidth/2, 40):diffusealpha(0)
				end,
			}

			return af
		end,

		transform = function(self, item_index, num_items, has_focus)
			self.container:finishtweening()
			self.container:accelerate(0.1)
			self.container:y(55 * item_index)
			self.container:diffusealpha(1)
		end,

		set = function(self, info)
			if info == nil then
				self.download_name:diffusealpha(0)
				self.message:diffusealpha(0)
				self.progress_bar:diffusealpha(0)
				self.swoosh:diffusealpha(0)
				self.download_amount:diffusealpha(0)
				self.separator:diffusealpha(0)
				self.endpoint:diffusealpha(0)
				return
			end

			self.uuid = info.uuid

			local downloadInfo = info.downloadInfo

			local errorMessage = downloadInfo.ErrorMessage
			local totalBytes = downloadInfo.TotalBytes
			local currentBytes = downloadInfo.CurrentBytes

			local suffix, divisor = bytesToSize(totalBytes)
			local percent = totalBytes == 0 and 0 or math.floor(currentBytes/totalBytes * 100)

			self.download_name:settext((info.index+1)..". "..downloadInfo.Name):diffusealpha(1)
			if downloadInfo.Complete then
				if errorMessage ~= nil then
					self.message:settext("Error: "..errorMessage):diffusealpha(1):diffuse(Color.Red)
				else
					self.message:settext("Done!"):diffusealpha(1):diffuse(Color.Green)
				end
			else
				self.message:diffusealpha(0)
			end

			self.progress_bar:zoomx(barWidth * percent / 100):diffusealpha(downloadInfo.Complete and 1 or 0.8)
			self.swoosh:zoomtowidth(barWidth * percent / 100):diffusealpha(downloadInfo.Complete and 0 or 1)
			self.separator:diffusealpha(1)
			self.endpoint:diffusealpha(1)

			self.percentage:settext(percent.."%"):diffusealpha(1)
			self.download_amount:settext(math.floor(currentBytes/divisor).."/"..math.floor(totalBytes/divisor).." "..suffix):diffusealpha(1)
		end
	}
}