function OptionRowEditorNoteskin()
	local skins = NOTESKIN:GetNoteSkinNames()
	return {
		Name = "Editor Noteskin",
		LayoutType = "ShowOneInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = false,
		Choices = skins,
		LoadSelections = function(self, list, pn)
			local skin = PREFSMAN:GetPreference("EditorNoteSkinP1") or
				PREFSMAN:GetPreference("EditorNoteSkinP2") or
				THEME:GetMetric("Common", "DefaultNoteSkinName")
			if not skin then return end

			local i = FindInTable(skin, skins) or 1
			list[i] = true
		end,
		SaveSelections = function(self, list, pn)
			for i = 1, #skins do
				if list[i] then
					PREFSMAN:SetPreference("EditorNoteSkinP1", skins[i])
					PREFSMAN:SetPreference("EditorNoteSkinP2", skins[i])
					break
				end
			end
		end,
	}
end

function OptionRowAllowFailingOutOfSet()
	local failTypes = {"Yes", "No"}
	
	return {
		Name = "Allow Fail Out Of Set",
		LayoutType = "ShowAllInRow",
		SelectType = "SelectOne",
		OneChoiceForAllPlayers = true,
		ExportOnChange = false,
		Choices = failTypes,
		LoadSelections = function(self, list, pn)
			local failType = ThemePrefs.Get("AllowFailingOutOfSet") or "Yes"
			local i = FindInTable(failType, failTypes) or 1
			list[i] = true
		end,
		SaveSelections = function(self, list, pn)
			for i=1, #failTypes do
				if list[i] then
					ThemePrefs.Set("AllowFailingOutOfSet", failTypes[i])
					ThemePrefs.Save()
					break
				end
			end
		end,
	}
end