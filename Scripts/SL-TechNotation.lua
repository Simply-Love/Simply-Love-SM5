TechNotationVerboseKey = "Verbose"
TechNotationCondensedKey = "Condensed"

-- array style to keep ordering in ipairs
local tech_categories = {
	{
		tcc = "TechCountsCategory_Brackets",
		[TechNotationCondensedKey] = {
			symbol_light  = "b",
			symbol_medium = "B",
			symbol_heavy  = "B+"
		},
		[TechNotationVerboseKey] = {
			symbol_light  = "BR- ",
			symbol_medium = "BR ",
			symbol_heavy  = "BR+ "
		}
	},
	{
		tcc = "TechCountsCategory_Crossovers",
		[TechNotationCondensedKey] = {
			symbol_light  = "x",
			symbol_medium = "X",
			symbol_heavy  = "X+"
		},
		[TechNotationVerboseKey] = {
			symbol_light  = "XO- ",
			symbol_medium = "XO ",
			symbol_heavy  = "XO+ "
		}
	},
	{
		tcc = "TechCountsCategory_Footswitches",
		[TechNotationCondensedKey] = {
			symbol_light  = "f",
			symbol_medium = "F",
			symbol_heavy  = "F+"
		},
		[TechNotationVerboseKey] = {
			symbol_light  = "FS- ",
			symbol_medium = "FS ",
			symbol_heavy  = "FS+ "
		}
	},
	{
		tcc = "TechCountsCategory_Sideswitches",
		[TechNotationCondensedKey] = {
			symbol_light  = "s",
			symbol_medium = "S",
			symbol_heavy  = "S+"
		},
		[TechNotationVerboseKey] = {
			symbol_light  = "SS- ",
			symbol_medium = "SS ",
			symbol_heavy  = "SS+ "
		}
	},
	{
		tcc = "TechCountsCategory_Jacks",
		[TechNotationCondensedKey] = {
			symbol_light  = "j",
			symbol_medium = "J",
			symbol_heavy  = "J+"
		},
		[TechNotationVerboseKey] = {
			symbol_light  = "JA- ",
			symbol_medium = "JA ",
			symbol_heavy  = "JA+ "
		}
	},
	{
		tcc = "TechCountsCategory_Doublesteps",
		[TechNotationCondensedKey] = {
			symbol_light  = "d",
			symbol_medium = "D",
			symbol_heavy  = "D+"
		},
		[TechNotationVerboseKey] = {
			symbol_light  = "DS- ",
			symbol_medium = "DS ",
			symbol_heavy  = "DS+ "
		}
	}
}

--- Use tech counts provided by the game engine to generate a string describing techiques used in the steps.
--- Example output: "BR+ XO+ FS DS-"
--- @param steps table? to generate notation for.
--- @param pn string by `ToEnumShortString(player)`, steps could have different values for different player.
--- @param style string -- either `TechNotationCondensedKey` or `TechNotationVerboseKey`
--- @return string techString A string describing the tech used.
SLTechNotation_Format = function(steps, pn, style)
    if steps == nil then
        -- SM("No steps to check")
        return ""
    end

    style = style or TechNotationVerboseKey

    -- Modern tech parser output
    local tech = steps:GetTechCounts(pn)

    -- Legacy radar values, we only currently need this for the step count. In the future could have jumps / rolls?
    local radar = steps:GetRadarValues(pn)

    -- Total steps in the difficulty
    local stepcount = radar:GetValue("RadarCategory_Notes")

    -- Minimum occurrence of tech to be counted.
    -- Static in sense that it doesn't depend on other chart properties, like its length / stepcount
    local static_threshold = 2

    local light_threshold = 0.005 * stepcount
    local normal_threshold = 0.02 * stepcount
    local heavy_threshold = 0.05 * stepcount

    -- The beef, convert the tech parser results into text
    local found_tech_categories = {}
    for key, t in ipairs(tech_categories) do
        local tech_amount = tech:GetValue(t.tcc)
        local symbol = ""
        local tech_symbols = t[style]

        if tech_amount > heavy_threshold then
            symbol = tech_symbols.symbol_heavy
        elseif tech_amount > normal_threshold then
            symbol = tech_symbols.symbol_medium
        elseif tech_amount > static_threshold and tech_amount > light_threshold then
            symbol = tech_symbols.symbol_light
        end

        -- store both the tech amount and the symbol to be able to sort the table once we've gone through all the tech categories
        found_tech_categories[#found_tech_categories + 1] = {
            symbol = symbol,
            tech_amount = tech_amount
        }
    end

    -- sort by in descending order, heaviest tech should be listed first
    -- > function that receives two list elements and returns true when the first element must come before the second in the final order
    table.sort(found_tech_categories, function (a, b)
        return a.tech_amount > b.tech_amount
    end)

    local text = ""

    for key, value in ipairs(found_tech_categories) do
        text = text .. value.symbol
    end

    return text
end