VisualStyles = { definitions = {}, order = {} }

-- This is to help provide clarity for those
-- creating/editing visual styles. We throw a visible human readable error
local function throwVisualStyleError(message)
	lua.ReportScriptError("VisualStyle: " .. message)
end

-- Modules can use this before theme preferences are initialized.
function VisualStyles.Register(definition, root)
	if type(definition) ~= "table" or type(definition.id) ~= "string" or definition.id == "" then
		throwVisualStyleError("a style needs an id")
		return false
	end
	local id = definition.id
	if VisualStyles.definitions[id] then
		throwVisualStyleError("duplicate id " .. id)
		return false
	end
	local foreground = definition.colorOverBackground
	if foreground == nil then foreground = { default = Color.White, rainbowMode = Color.Black } end
	if type(foreground) ~= "table" then
		throwVisualStyleError(id .. ": colorOverBackground must be a table")
		return false
	end
	for mode, c in pairs(foreground) do
		if (mode ~= "default" and mode ~= "rainbowMode") or type(c) ~= "table" or #c ~= 4 then
			throwVisualStyleError(id .. ": invalid foreground color for " .. tostring(mode))
			return false
		end
		for i=1,4 do
			if type(c[i]) ~= "number" or c[i] ~= c[i] or c[i] < 0 or c[i] > 1 then
				throwVisualStyleError(id .. ": foreground colors need four RGBA values between 0 and 1")
				return false
			end
		end
	end
	foreground.default = foreground.default or Color.White
	local background = definition.background or { type = "default" }
	if type(background) ~= "table" or not ({ default=true, image=true, actor=true })[background.type] then
		throwVisualStyleError(id .. ": unknown background type")
		return false
	end
	if (background.file ~= nil and type(background.file) ~= "string") or
		(background.type ~= "default" and background.file == nil) then
		throwVisualStyleError(id .. ": background needs a file")
		return false
	end
	if definition.assets ~= nil and type(definition.assets) ~= "table" then
		throwVisualStyleError(id .. ": assets must be a table")
		return false
	end
	for name, file in pairs(definition.assets or {}) do
		if type(name) ~= "string" or type(file) ~= "string" then
			throwVisualStyleError(id .. ": asset names and files must be strings")
			return false
		end
	end
	if (definition.name ~= nil and type(definition.name) ~= "string") or
		(definition.choice ~= nil and type(definition.choice) ~= "string") then
		throwVisualStyleError(id .. ": name and choice must be strings")
		return false
	end
	root = root or THEME:GetCurrentThemeDirectory()
	-- It's important this starts w/ a slash for resolutions so LoadActor's
	-- transformation always works correctly.
	root = "/" .. root:gsub("^/+", "")
	if root:sub(-1) ~= "/" then root = root .. "/" end
	if definition.sounds ~= nil and type(definition.sounds) ~= "table" then
		throwVisualStyleError(id .. ": sounds must be a table")
		return false
	end
	for name, file in pairs(definition.sounds or {}) do
		if type(name) ~= "string" or type(file) ~= "string" then
			throwVisualStyleError(id .. ": sound names and files must be strings")
			return false
		end
		if not FILEMAN:DoesFileExist(root .. file) then
			throwVisualStyleError(id .. ": missing sound " .. file)
			return false
		end
	end
	if background.file and not FILEMAN:DoesFileExist(root .. background.file) then
		throwVisualStyleError(id .. ": missing background " .. background.file)
		return false
	end
	if background.fit ~= nil and background.fit ~= "cover" and background.fit ~= "contain" then
		throwVisualStyleError(id .. ": fit must be cover or contain")
		return false
	end
	if background.dim ~= nil and (type(background.dim) ~= "number" or background.dim < 0 or background.dim > 1) then
		throwVisualStyleError(id .. ": dim must be between 0 and 1")
		return false
	end
	if background.color ~= nil and (type(background.color) ~= "string" or not background.color:match("^#%x%x%x%x%x%x$")) then
		throwVisualStyleError(id .. ": background color must be #RRGGBB")
		return false
	end
	if definition.title ~= nil and type(definition.title) ~= "table" then
		throwVisualStyleError(id .. ": title must be a table")
		return false
	end
	local titleFields = { textY=true, textZoom=true, textRotation=true, logoY=true, logoZoom=true, logoRotation=true, infoY=true, infoZoom=true }
	for name, value in pairs(definition.title or {}) do
		if not titleFields[name] or type(value) ~= "number" or value ~= value or math.abs(value) == math.huge or
			(name:match("Zoom$") and value <= 0) then
			throwVisualStyleError(id .. ": invalid title setting " .. tostring(name))
			return false
		end
	end
	definition.colorOverBackground = foreground
	definition.background = background
	definition.root = root
	VisualStyles.definitions[id] = definition
	VisualStyles.order[#VisualStyles.order+1] = id
	return true
end

function VisualStyles.Discover(root)
	root = root or THEME:GetCurrentThemeDirectory() .. "Other/VisualStyles/"
	local directories = FILEMAN:GetDirListing(root, true, false)
	table.sort(directories)
	for _, directory in ipairs(directories) do
		local path = root .. directory .. "/"
		if FILEMAN:DoesFileExist(path .. "style.lua") then
			local chunk, err = loadfile(path .. "style.lua")
			if chunk then
				local ok, definition = pcall(chunk)
				if ok then VisualStyles.Register(definition, path)
				else throwVisualStyleError(directory .. ": " .. tostring(definition)) end
			else throwVisualStyleError(directory .. ": " .. tostring(err)) end
		end
	end
end

function GetVisualStyle()
	return VisualStyles.definitions[ThemePrefs.Get("VisualStyle")] or VisualStyles.definitions.Hearts
end

function VisualStyleSupportsRainbow()
	return GetVisualStyle().colorOverBackground.rainbowMode ~= nil
end

function GetColorOverBackground()
	local c = Color.White
	if THEME:GetCurThemeName() == PREFSMAN:GetPreference("Theme") and not HolidayCheer() then
		local foreground = GetVisualStyle().colorOverBackground
		c = ThemePrefs.Get("RainbowMode") and foreground.rainbowMode or foreground.default
	end
	return { c[1], c[2], c[3], c[4] }
end

-- Panels and inverse colors still need a light or dark contrast choice.
function VisualStyleUsesDarkText()
	local c = GetColorOverBackground()
	return c[1] * 0.299 + c[2] * 0.587 + c[3] * 0.114 < 0.5
end

-- Asset names match the existing graphics, such as SelectColor or GameplayIn splode.
function VisualStyles.Asset(id, name, optional)
	local style = VisualStyles.definitions[id]
	if not style then
		throwVisualStyleError("unknown style " .. tostring(id))
		return nil
	end
	local file = style.assets and style.assets[name]
	local path = ActorUtil.ResolvePath(style.root .. (file or name), 1, true)
	if not path then
		path = ActorUtil.ResolvePath("/" .. THEME:GetCurrentThemeDirectory():gsub("^/+", "") .. "Graphics/_VisualStyles/" .. id .. "/" .. name, 1, true)
	end
	if path or optional then return path end
	path = ActorUtil.ResolvePath("/" .. THEME:GetCurrentThemeDirectory():gsub("^/+", "") .. "Graphics/_VisualStyles/Hearts/" .. name, 1, true)
	if not path then throwVisualStyleError(id .. ": missing graphic " .. name) end
	return path
end

function VisualStyleAsset(name, optional)
	return VisualStyles.Asset(GetVisualStyle().id, name, optional)
end

function VisualStyleSound(name)
	local style = GetVisualStyle()
	local file = style.sounds and style.sounds[name]
	if file then return style.root .. file end
	if name == "menuMusic" then
		local hearts = VisualStyles.definitions.Hearts
		return THEME:GetPathS("", "_common menu music/in_two")
	end
	if name == "gameOverMusic" then return THEME:GetPathS("", "fold.ogg") end
end

VisualStyles.Discover()
