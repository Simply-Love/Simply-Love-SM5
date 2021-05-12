*<strong>Digital Dance v1.0.0</strong>
Huge thanks to Nantano, Sujeet, Ian, and Dom for the GS Launcher!
Without them this update wouldn't be nearly as awesome~

# ---------------- Notable changes ----------------

- Added support for GS Launcher, Score submission, and leaderboards!
- A brand new songwheel with custom sorting and filtering options!
- New Sort Menu has Sort/Sub sort options.
- It can also filter songs by things like difficulty, bpm, and length.
- A Groovestats filter that will only display packs/songs that are ranked on Groovestats.
- Added a song search functionality. (In the sort menu)
- Density Graph color is based off of NPS. The higher the NPS the more red it is.
- Density Graph breakdown on song select is now more detailed and caches so it only needs to be parsed once. (Thanks Sujeet!)
- Removal of game modes.
- CDTitle support added.
- Player stats added that includes things like steps per set/lifetime, songs in set/lifetime, average bpm, and average difficulty.
- Added Player Stats support to 4:3 displays (Only in 1 player mode)
- Average difficulty will now account for rate mods. (Though it's not accurate and tends to lean to lower ratings)
- Each player can have their own unique profile picture and if one isn't present then a default image will appear in place.
- Each player gets their own difficulty selection instead of being shared. (Unless in 4:3)
- Music wheel is centered and each player's assets are on their own side. (Only on widescreen)


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
  
The aspect ratio can be changed under *Graphics / Sound Options*.

## Screenshots
![Select Music w/ GS Launcher running](https://i.imgur.com/uvBeh6u.png)
![Select Music on 2P w/ Guest Profile](https://i.imgur.com/HAC5rap.jpg)
![4:3 w/ Player Stats](https://i.imgur.com/1Y9l8nC.jpg)
![2P in 4:3, no Player Stats are shown](https://i.imgur.com/07HFW5f.png)


# -- KNOWN ISSUES and general things to note --
- Theme is intended for home use only.
- I don't expect this to work outside of event mode.
- Sort Menu can only be accessed if you have 4 button naviation on at the moment (aka having a "Select"/Red button)

# ---------------- TO DO ----------------
- Make the Sort Menu more accessible to people with 3 button navigation.
- Maybe add more player stats (highest difficulty passed?)
- Add more sorts/filters
- Add "Favorites" and/or tags for songs/groups.
- Add a hashcache so I can do sorts like NPS.
- I really want to add a chart preview, but I don't know how realistic it is to do that theme-side and not be a laggy mess.
- Clean up my code. It's better now than it was in the last version, but could be better.
