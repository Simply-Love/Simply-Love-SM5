WIP Theme for SM5 that uses Simply Love as a base, but hopefully over time I can fix some problems I had with it along with adding even more features.

# ---------------- Notable changes ----------------

- Removal of visual themes
- Removal of different game modes (ITG only) [Kind of]
- No more difficulty "blocks". Difficulty numbers are displayed, but enlarged and accompanied by a highlight cursor to indicate which difficulty you've selected. Both cursors are colored based on player.
- The chart pane on screen select music (the thing that lists steps, holds, etc) has the difficulty number removed as well. Don't need the redundancy of having the difficulty shown in 3 different ways. Also gives more space for additional info in the future.
- Density graphs always present on screen select music along with a generalized breakdown if any.
- The generalized breakdown now also displays the total measure count instead if the breakdown string is too long.
- Step artist field extended and text made slightly smaller to fit more information before it gets squished into oblivion.
- Difficulties are colored by their actual difficulty, but are slightly lighter to avoid eye strain.
- CDTitle support added.
- Massive removal of bloat from the theme bringing it down from ~120mbs to just about 15mbs.
- Preview music no longer loops so you can actually hold a conversation with someone inbetween songs without having to leave the song folder.
- Song title present at the bottom of the mod menu. (Just in case you forget what you picked after the music stops looping)
- Style indicator at the top right on evaluation (to distinguish between single and double)
- The per column note tracking will stop counting up once you fail. (This makes determining pad issues a lot easier.)
- Player stats added that includes things like steps per set/lifetime, songs in set/lifetime, average bpm, and average difficulty.
- Added Player Stats support to 4:3 displays (Only in 1 player mode)
- Average difficulty will now account for rate mods : )
- Each player can have their own unique profile picture and if one isn't present then a default image will appear in place.
- Each player gets their own difficulty selection instead of being shared. (Unless in 4:3)
- Music wheel is centered and each player's assets are on their own side instead of arbitrarily having P2 cover up the wheel when playing. (Only on widescreen)
- Added a song search function. (In the sort menu)
- Sorting by difficulty is currently a custom sort handled by entering a number so that you can get every chart of that difficulty instead of only Expert, Hard, etc. (This will be changed in the future)

# ---------------- How to use a profile picture ----------------

- Add a new image at the root of your save folder of your profile.
- (Example: \Save\LocalProfiles\00000000\Profile Picture.png)

The image must:
- Have a 1:1 aspect ratio for best appearance. (Image will be resized as such).
- Be titled "Profile Picture" or "Avatar"

## Aspect Ratio Support

  * <strong>16:9</strong> (common)
  * <strong>16:10</strong> (Apple laptops, some LCD monitors)
  * <strong>4:3</strong> (CRT arcade monitors, older TVs)
  
 - This might work, but I haven't had the chance to take a look.
  * <strong>21:9</strong> ("Ultrawide")

The aspect ratio can be changed under *Graphics / Sound Options*.

## Screenshots
![Select Music w/ Simplified Breakdown](https://i.imgur.com/uvBeh6u.png)
![Select Music on 2P w/ Guest Profile](https://i.imgur.com/2vOx8MP.png)
![4:3 w/ Player Stats](https://i.imgur.com/jER3Oqo.png)
![2P in 4:3, no Player Stats are shown](https://i.imgur.com/07HFW5f.png)


# -- KNOWN ISSUES and general things to note --
- Theme is intended for home use only.
- I don't expect this to work outside of event mode.
- CDTitles appear on top of the sort menu despite draw orders being correct x_x

# ---------------- TO DO ----------------
- Maybe add more player stats (highest difficulty passed?)
- I really want to add a chart preview, but I don't know how realistic it is to do that theme-side and not be a laggy mess.
- Completely remove game modes. (competitive/itg mode still technically exists and I'd rather it not set all the metrics and things through lua)
- Fix CDTitles to not appear on top of the sort menu.
- Remake screen select music through lua to add custom sort/subsort and filter options... and also not be a laggy mess...
- Clean up my code. (It's better now than it was in the last version.) At least most things are labeled lol
