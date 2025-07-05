local sqlite3 = sqlite3 -- Provided by lsqlite3

local function Cache_DBG(message)
	-- lua.Info(message)
end

local function CacheInitialize()
	local db = sqlite3.open("simplylove.db")
	db:exec("CREATE TABLE meta (schema_version INTEGER PRIMARY KEY);")

	db:exec([[
		CREATE TABLE score_cache (
			player TEXT NOT NULL,
			hash TEXT NOT NULL,
			score TEXT NOT NULL,
			score_type TEXT NOT NULL,
			score_source TEXT NOT NULL,
			score_color TEXT,
			UNIQUE(
				player,
				hash,
				score_source,
				score_type
			) ON CONFLICT REPLACE
		);
	]])

	Cache_DBG("Created tables")
	return db
end

local Db = CacheInitialize()

---@param player string
---@param hash string
---@param score string
---@param score_type string
---@param score_source string
---@param score_color string?
local function CacheSet(player, hash, score, score_type, score_source, score_color)
	Cache_DBG(string.format("CacheSet %s %s %s %s %s %s", player, hash, score, score_type, score_source, score_color or "nil"))
	local stmt = Db:prepare("INSERT INTO score_cache(player, hash, score, score_type, score_source, score_color) VALUES (?, ?, ?, ?, ?, ?)")
	stmt:bind_values(player, hash, score, score_type, score_source, score_color)
	stmt:step()
	stmt:finalize()
end

---@param player string
---@param hash string
---@param score_type string
---@param score_source string
---@return string?, string?
local function CacheGet(player, hash, score_type, score_source)
	Cache_DBG(string.format("CacheGet %s %s %s %s", player, hash, score_type, score_source))
	local stmt = Db:prepare("SELECT score, score_color FROM score_cache WHERE player=? AND hash=? AND score_type=? AND score_source=?")
	stmt:bind_values(player, hash, score_type, score_source)
	local ret_step = stmt:step()
	if ret_step ~= sqlite3.ROW then
		return nil, nil
	end
	local score = stmt:get_value(0)
	local score_color = stmt:get_value(1)
	stmt:finalize()
	return score, score_color
end

---@param player string
---@param hash string
---@param score string
function CacheSetGSEX(player, hash, score)
	CacheSet(player, hash, score, "ex", "groovestats", nil)
end

---@param player string
---@param hash string
---@return string?, string?
function CacheGetGSEX(player, hash)
	return CacheGet(player, hash, "ex", "groovestats")
end

---@param player string
---@param hash string
---@param score string
---@param color string
function CacheSetLocalEX(player, hash, score, color)
	CacheSet(player, hash, score, "ex", "local", color)
end

---@param player string
---@param hash string
---@return string?, string?
function CacheGetLocalEX(player, hash)
	return CacheGet(player, hash, "ex", "local")
end

---@param player string
---@param hash string
---@param score string
function CacheSetGSITG(player, hash, score)
	CacheSet(player, hash, score, "itg", "groovestats", nil)
end

---@param player string
---@param hash string
---@return string?, string?
function CacheGetGSITG(player, hash)
	return CacheGet(player, hash, "itg", "groovestats")
end

---@param player string
---@param hash string
---@param score string
---@param color string
function CacheSetLocalITG(player, hash, score, color)
	CacheSet(player, hash, score, "itg", "local", color)
end

---@param player string
---@param hash string
---@return string?, string?
function CacheGetLocalITG(player, hash)
	return CacheGet(player, hash, "itg", "local")
end