rounded_rect = function(w, h, r, c)

	local t = Def.ActorFrame{}
	t[#t+1] =  Def.ActorMultiVertex{
		InitCommand=function(self)
			r = r or 5
			c = c or Color.White
			
			local verts = {}
			
			verts[#verts+1] = { {0, r, 0}, c }
			verts[#verts+1] = { {r, r, 0}, c }
			verts[#verts+1] = { {r, h-r, 0}, c }
			verts[#verts+1] = { {0, h-r, 0}, c }

			verts[#verts+1] = { {w-r, r, 0}, c }
			verts[#verts+1] = { {w, r, 0}, c }
			verts[#verts+1] = { {w, h-r, 0}, c }
			verts[#verts+1] = { {w-r, h-r, 0}, c }

			verts[#verts+1] = { {r, 0, 0}, c }
			verts[#verts+1] = { {w-r, 0, 0}, c }
			verts[#verts+1] = { {w-r, h, 0}, c }
			verts[#verts+1] = { {r, h, 0}, c }

			self:SetDrawState( {Mode="DrawMode_Quads"} )
				:SetVertices( verts )
		end
	}
	
	t[#t+1] = Def.ActorMultiVertex{
		InitCommand=function(self)
			
			r = r or 5
			c = c or Color.White
			
			local verts = {}
			
			verts[#verts+1] = { {r, r, 0}, c }
			verts[#verts+1] = { {0, r, 0}, c }
			verts[#verts+1] = { {r, 0, 0}, c }

			verts[#verts+1] = { {w-r, r, 0}, c }
			verts[#verts+1] = { {w, r, 0}, c }
			verts[#verts+1] = { {w-r, 0, 0}, c }

			verts[#verts+1] = { {w-r, h-r, 0}, c }
			verts[#verts+1] = { {w, h-r, 0}, c }
			verts[#verts+1] = { {w-r, h, 0}, c }

			verts[#verts+1] = { {r, h-r, 0}, c }
			verts[#verts+1] = { {0, h-r, 0}, c }
			verts[#verts+1] = { {r, h, 0}, c }

			self:SetDrawState( {Mode="DrawMode_Triangles"} )
				:SetVertices( verts )
		end
	}

	return t
end