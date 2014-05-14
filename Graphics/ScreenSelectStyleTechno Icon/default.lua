------------------------------------------------------------------------------------
-- ./Grahpics/ScreenSelectStyleTechno Icon/default.lua
------------------------------------------------------------------------------------

local gc = Var("GameCommand");
local iIndex = gc:GetIndex();
local choiceName = gc:GetName();
local gameName = GAMESTATE:GetCurrentGame():GetName();

local xshift = WideScale(42,52);
local yshift = WideScale(54,78);
local zoomFactor = WideScale(0.435,0.525);

local t = Def.ActorFrame {
	Name="Item"..iIndex;
	
	GainFocusCommand=cmd(finishtweening; linear,0.2; zoom,1 );
	LoseFocusCommand=cmd(linear,0.2; zoom,0.5);
};

t[#t+1] = Def.ActorFrame { 

	LoadFont("_wendy small")..{
		Name="StyleName"..iIndex;
		InitCommand=function(self)
			self:settext(THEME:GetString("ScreenSelectStyleTechno", choiceName));
				
			if choiceName == "Versus" then
				self:addx(-14);
			end;

			self:addy(60);
			self:zoom(0.5);
		end;
		EnabledCommand=cmd(diffusealpha,1);
		DisabledCommand=cmd(diffusealpha,0.25; );
	
	};
};

------------------------------------------------------------------------------------
-- ninePanel definition
------------------------------------------------------------------------------------

function drawNinePanelPad(color, offset)

	local af = Def.ActorFrame {
	
		InitCommand=cmd(addx,offset; addy, -yshift);
		EnabledCommand=cmd(diffusealpha,1);
		DisabledCommand=cmd(diffusealpha,0.25; );
	
		-- first row
		LoadActor("rounded-square.png")..{
			InitCommand=function(self)
				self:zoom(zoomFactor);
				self:x(zoomFactor * self:GetWidth());
				self:y(zoomFactor * self:GetHeight());
				self:diffuse(DifficultyIndexColor(color));
			end
		};
	
		LoadActor("rounded-square.png")..{
			InitCommand=function(self)
				self:zoom(zoomFactor);
				self:x(zoomFactor * self:GetWidth() * 2);
				self:y(zoomFactor * self:GetHeight());
				self:diffuse(DifficultyIndexColor(color));
			end
		};
	
		LoadActor("rounded-square.png")..{
			InitCommand=function(self)
				self:zoom(zoomFactor);
				self:x(zoomFactor * self:GetWidth() * 3);
				self:y(zoomFactor * self:GetHeight());
				self:diffuse(DifficultyIndexColor(color));
			end
		};
	
	
	
	
		-- second row
		LoadActor("rounded-square.png")..{
			InitCommand=function(self)
				self:zoom(zoomFactor);
				self:x(zoomFactor * self:GetWidth());
				self:y(zoomFactor * self:GetHeight() * 2);
				self:diffuse(DifficultyIndexColor(color));
			end
		};
	
		LoadActor("rounded-square.png")..{
			InitCommand=function(self)
				self:zoom(zoomFactor);
				self:x(zoomFactor * self:GetWidth() * 2);
				self:y(zoomFactor * self:GetHeight() * 2);
				self:diffuse(0.2,0.2,0.2,1);
			end
		};
	
		LoadActor("rounded-square.png")..{
			InitCommand=function(self)
				self:zoom(zoomFactor);
				self:x(zoomFactor * self:GetWidth() * 3);
				self:y(zoomFactor * self:GetHeight() * 2);
				self:diffuse(DifficultyIndexColor(color));
			end
		};
	
	
	
		-- third row
		LoadActor("rounded-square.png")..{
			InitCommand=function(self)
				self:zoom(zoomFactor);
				self:x(zoomFactor * self:GetWidth());
				self:y(zoomFactor * self:GetHeight() * 3);
				self:diffuse(DifficultyIndexColor(color));
			end
		};
	
		LoadActor("rounded-square.png")..{
			InitCommand=function(self)
				self:zoom(zoomFactor);
				self:x(zoomFactor * self:GetWidth() * 2);
				self:y(zoomFactor * self:GetHeight() * 3);
				self:diffuse(DifficultyIndexColor(color));
			end
		};
	
		LoadActor("rounded-square.png")..{
			InitCommand=function(self)
				self:zoom(zoomFactor);
				self:x(zoomFactor * self:GetWidth() * 3);
				self:y(zoomFactor * self:GetHeight() * 3);
				self:diffuse(DifficultyIndexColor(color));
			end
		};
	
	};
	
	
	return af;
end

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------




if choiceName == "Single" then -- 1 Player
	t[#t+1] = drawNinePanelPad(3, -xshift - 14);
	
elseif choiceName == "Versus" then -- 2 Players
	t[#t+1] = drawNinePanelPad(2,-xshift - WideScale(70,80));
	t[#t+1] = drawNinePanelPad(5, xshift - WideScale(70,80));
	
elseif choiceName == "Double" then -- Double
	t[#t+1] = drawNinePanelPad(4,-xshift - WideScale(60,70));
	t[#t+1] = drawNinePanelPad(4, xshift - WideScale(60,70));
	
end




return t;