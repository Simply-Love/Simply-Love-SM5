local textcolor = "#FFFFFF";
if SimplyLoveColor() > 5 then
	textcolor = "#1E282F";
end

return LoadFont("_misoreg hires") .. {
	InitCommand=cmd(zoom, 0.65; diffuse,color(textcolor););
};