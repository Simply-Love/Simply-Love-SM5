local args = ...
local g = args[1]

local imgs = { "wow", "determined", "worried" }

local af = Def.ActorFrame{
	InitCommand=function(self)
		self:visible(false):diffusealpha(0)
			:xy(_screen.cx, _screen.h-64)
		g.Dialog.ActorFrame = self
	end,
	ShowCommand=function(self) self:visible(true):linear(0.333):diffusealpha(1) end,
	HideCommand=function(self)
		g.Dialog.Index = 1
		g.Dialog.BoxColor = nil
		g.DialogIsActive = false
		self:visible(false)
	end,

	LoadActor("./box.png")..{ InitCommand=function(self) self:zoom(0.245) end }
}

-- facial expressions
for i,img in ipairs(imgs) do
	af[#af+1] = LoadActor("./Elli " .. img .. " (doubleres).png")..{
		InitCommand=function(self)
			self:zoom(0.235):halign(0):visible(false):xy(-296, -2)
		end,
		ShowCommand=function(self, params) self:visible(g.Dialog.Faces[g.Dialog.Index] == img) end
	}
end

-- the speaker's name and name box
af[#af+1] = Def.ActorFrame{
	Name="NameBoxAF",
	InitCommand=function(self)
		self:xy(-250,-56)
	end,
	ShowCommand=function(self) self:visible( #g.Dialog.Faces > 0 ) end,

	-- name box stroke
	Def.Quad{
		Name="Stroke",
		InitCommand=function(self)
			self:zoomto(104,36):diffuse(0.15,0.15,0.15,1)
		end
	},
	-- name box
	Def.Quad{
		Name="Box",
		InitCommand=function(self)
			self:zoomto(100,32):diffuse(color("#995544"))
		end,
	},

	--name
	Def.BitmapText{
		File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
		Text=g.Dialog.Speaker,
		InitCommand=function(self) self:zoom(1.1) end
	}
}

af[#af+1] = Def.BitmapText{
	File=THEME:GetPathB("ScreenHereInTheDarkness", "overlay/_shared/helvetica neue/_helvetica neue 20px.ini"),
	InitCommand=function(self) self:cropright(1) end,
	OnCommand=function(self)
		self:align(0,0):xy(-200, -30)
			:diffuse(Color.Black)
			:wrapwidthpixels(480/self:GetZoom())
	end,

	ClearTextCommand=function(self)
		self:settext(""):cropright(1)
	end,
	UpdateTextCommand=function(self)
		g.Dialog.IsTweening = true

		if g.Dialog.Words[g.Dialog.Index] then
			self:settext( g.Dialog.Words[g.Dialog.Index] )
				:linear(0.75):cropright(0):queuecommand("FinishUpdateText")
		else
			self:queuecommand("ClearText")
		end
	end,
	FinishUpdateTextCommand=function(self) g.Dialog.IsTweening = false end
}

return af