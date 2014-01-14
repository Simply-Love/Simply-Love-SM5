local t = Def.ActorFrame{};

-- A hack to load custom options off local profiles, if there are any
t[#t+1] = LoadActor("loadProfilesHack");

-- Banner
t[#t+1] = LoadActor("banner");

-- Song Description (Artist, BPM, Duration)
t[#t+1] = LoadActor("songDescription");

-- StepArtist Boxes
t[#t+1] =  LoadActor("stepArtist");

-- Difficulty Blocks
t[#t+1] = LoadActor("difficultyBlocks");

-- Step Data (Number of steps, jumps, holds, etc.)
t[#t+1] = LoadActor("panedisplay");

-- the fadeout that informs users to press START if they want options
t[#t+1] = LoadActor("fadeOut");

return t;