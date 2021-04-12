-- Lua QR Code module by @pgundlach and contributors to https://github.com/speedata/luaqrcode
-- barebones documentation available at https://speedata.github.io/luaqrcode/
local qrencode = loadfile(THEME:GetPathB("", "_modules/QR Code/qrencode.lua"))()

-- -----------------------------------------------------------------------
-- args passed in as an indexed table (an "array")
--
-- index 1 is the string to encode into a QR Code
--    for our purposes, this is the groovestats url
--
-- index 2 is the pixel size (both width and height since QR codes are square)
--    of the ActorMultiVertex returned from this file

local url, size = unpack(...)

-- provide default values in case either weren't passed in as args
 url =  url or ""
size = size or 150

-- use the qrencode module's qrcode function to generate a table
-- of vert data formatted for an ActorMultiVertex set to DrawMode_Quads
local verts = {}

-- pass in the url string, get back a tab_or_message as either
--   a table of 0 (white square) or 1 (black square) data
--   an error message
local ok, tab_or_message = qrencode.qrcode( url )

for c, column in ipairs(tab_or_message) do
	for m, module in ipairs(column) do
		local clr = (module > 0) and Color.Black or Color.White

		--                    {x    y    z}
		table.insert( verts, {{m-1, c-1, 0}, clr } )
		table.insert( verts, {{m,   c-1, 0}, clr } )
		table.insert( verts, {{m,   c,   0}, clr } )
		table.insert( verts, {{m-1, c,   0}, clr } )
	end
end

local pixel_size = size/#tab_or_message

-- -----------------------------------------------------------------------

local qr = Def.ActorFrame{}

-- white border around the QR code
qr[#qr+1] = Def.Quad{
	InitCommand=function(self)
		self:zoom(size + pixel_size * 2)
		self:addx(size/2):addy(size/2)
	end
}

-- QR code
qr[#qr+1] = Def.ActorMultiVertex{
	Name="QRCodeData",
	InitCommand=function(self)
		self:SetDrawState({Mode="DrawMode_Quads"})
		self:SetVertices(verts)
		self:zoom(pixel_size)
	end,
	HideCommand=function(self)
		-- To hide the QR, we just set all the vertices to a common color.
		for vert in ivalues(verts) do
			vert[2] = color("0.1,0.1,0.1")
		end
		self:SetVertices(verts)
	end
}

return qr

-- -----------------------------------------------------------------------
-- Hello!
--
-- GitHub doesn't provide an easy way to simply express thanks,
-- so I'm emailing you to do that.  Your luaqrcode repository
-- was incredibly helpful for a small open source project I
-- maintain that serves a niche gaming community.  It made
-- highlight feature of a recent release possible, in fact.
--
-- Our community is small but passionate, and many players
-- have expressed excitement over the new features the QR codes
-- allow for.  Your luaqrcode library made the implementation
-- details incredibly easy for me, one of few devs.  So from
-- both players and devs alike – thank you from the StepMania
-- community!
--
-- quietly
-- 30 May 2019

-- -----------------------------------------------------------------------
-- Hello quietly,
--
-- thank you for your mail, I really appreciate it. And keep
-- up the joy of maintaining an OpenSource project!
--
-- Regards
-- Patrick