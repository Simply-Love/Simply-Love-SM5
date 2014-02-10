t =  Def.ActorFrame {};

t[#t+1] = StandardDecorationFromFile( "Header", "Header" );
t[#t+1] = StandardDecorationFromFileOptional( "Footer", "Footer" );

return t; 