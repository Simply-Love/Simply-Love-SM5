local c, tc;
local player = Var "Player";
local ShowComboAt = THEME:GetMetric("Combo", "ShowComboAt");

local NumberMinZoom = 0.75;
local NumberMaxZoom = 1.1;
local NumberMaxZoomAt = THEME:GetMetric("Combo", "NumberMaxZoomAt");


local t = Def.ActorFrame {
	
	-- load the 100 combo milestone right now
	-- it is hidden until the Milestone command is played
 	LoadActor(THEME:GetPathG("Combo","100Milestone"))..{
		Name="OneHundredMilestone";
		HundredMilestoneCommand=cmd(playcommand,"Milestone");
	};
	
 	LoadActor(THEME:GetPathG("Combo","1000Milestone"))..{
		Name="OneThousandMilestone";
		ThousandMilestoneCommand=cmd(playcommand,"Milestone");
	};
	
	
	LoadFont("_wendy small")..{
		Name="Number";
		OnCommand = THEME:GetMetric("Combo", "NumberOnCommand");
	};

	LoadFont("_wendy small")..{
		Name="Label";
		InitCommand=cmd(zoom,0.25);
		OnCommand = THEME:GetMetric("Combo", "LabelOnCommand");
	};


	InitCommand=function(self)
		self:draworder(101);
		c = self:GetChildren();
		c.Number:visible(false);
		c.Label:visible(false);
		self:visible(not SL[ToEnumShortString(player)].ActiveModifiers.HideCombo)
	end;

	ComboCommand=function(self, param)
		local iCombo = param.Misses or param.Combo;
		if not iCombo or iCombo < ShowComboAt then
			c.Number:visible(false);
			c.Label:visible(false);
			return;
		end

		local Label = c.Label;
		local bComboOrMiss = false;
		local bMiss = false;

		if param.Combo then
			c.Number:diffuseshift();
			Label:settext( "Combo" );
			
			bComboOrMiss = true;
			bMiss = false;
		elseif param.Misses then
			Label:settext( "Misses" );
			c.Number:stopeffect();
			
			bComboOrMiss = true;
			bMiss = true;
		end
		Label:visible(false);

		param.Zoom = scale( iCombo, 0, NumberMaxZoomAt, NumberMinZoom, NumberMaxZoom );
		param.Zoom = clamp( param.Zoom, NumberMinZoom, NumberMaxZoom );

		if bComboOrMiss then
			c.Number:visible(true);
			c.Number:zoom(param.Zoom);
			Label:visible(true);
		end;

		c.Number:settext( string.format("%i", iCombo) );		

		
		local targetColor;
		if param.FullComboW1 then
			c.Number:effectcolor1(color("#C8FFFF"));
			c.Number:effectcolor2(color("#6BF0FF"));
			
		elseif param.FullComboW2 then
			c.Number:effectcolor1(color("#FDFFC9"));
			c.Number:effectcolor2(color("#FDDB85"));

		elseif param.FullComboW3 then
			c.Number:effectcolor1(color("#C9FFC9"));
			c.Number:effectcolor2(color("#94FEC1"));

		elseif param.Combo then
			c.Number:stopeffect();
			-- c.Number2:stopeffect();
			targetColor = color("#FFFFFF");
		else
			targetColor = color("#FF0000");
		end
		c.Number:effectperiod(0.8);		
		Label:diffuse( color("#FFFFFF") );
		
	end;

	-- JudgmentMessageCommand=function(self, param)
		-- if param.Player ~= player then return end;
		-- if not param.TapNoteScore then return end;
		-- if not UseToastyMeter then return end;
		-- local tns = param.TapNoteScore;
	-- end;
};

return t;