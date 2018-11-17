local character = " !\"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz";

local function GetCode(str)
	for i = 1,string.len(character) do
		if string.sub(character,i,i) == str then
			return i;
		end
	end
end

local function Create(str)
	local tbl = {};
	for i = 1,string.len(str) do
		tbl[i] = {};
		tbl[i][1] = GetCode(string.sub(str,i,i));
		tbl[i][2] = math.random(string.len(character));
	end
	return tbl;
end

local function ShuffleText(tbl)
	local text = '';
	local size = 0;
	for i,v in pairs(tbl) do
		if size < table.getn(tbl)/3 then
			if v[1] ~= v[2] then
				v[2] = math.mod(v[2]+1,string.len(character));
				size = size + 1;
			end
			text = text .. string.sub(character,v[2],v[2]);
		else
			text = text .. '-';
		end
	end
	return text;
end

local Current = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong();
local tbl1 = Create(Current:GetTranslitFullTitle());
local tbl2 = Create(Current:GetTranslitArtist());

for i,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
	if GAMESTATE:IsPlayerEnabled(pn) then
		local Options = GAMESTATE:GetPlayerState(pn):GetPlayerOptions('ModsLevel_Song');
		Options:Blind(1,1e10);
	end
end

return Def.ActorFrame{
	OnCommand=function()
		local style = ToEnumShortString(GAMESTATE:GetCurrentStyle():GetStyleType());
		if style == "OnePlayerOneSide" then
			local P1 = SCREENMAN:GetTopScreen():GetChild('PlayerP1');
			local P2 = SCREENMAN:GetTopScreen():GetChild('PlayerP2');
			if P1 then P1:x(SCREEN_CENTER_X); end
			if P2 then P2:x(SCREEN_CENTER_X); end
		end
	end,

	Def.Quad{
		OnCommand=cmd(x,SCREEN_CENTER_X;y,SCREEN_CENTER_Y;zoomto,SCREEN_WIDTH,SCREEN_HEIGHT;diffuse,0,0,0,1;linear,0.5;diffusealpha,0),
	},

	Def.BitmapText{
		Font="Common Normal",
		OnCommand=cmd(x,SCREEN_RIGHT-80;y,SCREEN_BOTTOM-60;horizalign,'right';vertalign,'bottom';playcommand,'Update'),
		UpdateCommand=function(self)
			local text = ShuffleText(tbl1) ..'\n'.. ShuffleText(tbl2);
			self:settext(text);
			self:sleep(0.008);
			self:queuecommand('Update');
		end,
	},

};