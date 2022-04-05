# Digital Dance v1.0.5

# ------------ Differences from 1.0.4 ------------
- Custom Course Wheel/Screen added with the abilty to sort/filter courses.
- FA+ and EX Score tracking added to gameplay/evaluation.
- ITL Support!
- After selecting a profile you are taken directly to either Song or Course select based on what you last played.
- Added Total Measure count and Density % on song select.
- Single & Double are now differentiated on ScreenSelectMusicDD.
- Sounds added by the user will now be randomly selected to play when a World Record is achieved.
- Column Cues added in player options to show where an arrow is coming after a break.
- Error Bar added in player options.
- Judgement Tilt added in player options.
- Dropping support for 4:3 displays in favor of not removing features due to screen real estate.


# -------------- GrooveStats Integration --------------
Huge thanks to Nantano, Sujeet, Ian, and Dom for the Groovestats Launcher/Intergration!
Rivals, Scores, Leaderboards, Auto-Uploading of scores, it's all here! Please [watch the video](https://www.youtube.com/watch?v=8yMzp7xMQq0) and refer the [GrooveStats Launcher Guide](https://github.com/GrooveStats/gslauncher#readme) on how to setup the StepMania wrapper program that will get you connected.

First, check and see if you're connected!

![CheckConnection](https://i.imgur.com/QQOsCG9.png)

Setup your Rivals on [GrooveStats](https://groovestats.com/index.php?page=register&action=update) and check out your scores write in on the Select Music Screen

![PaneDisplayGSScores](https://i.imgur.com/BrTCdFy.png)

Want to see more scores? Open the sort menu and select the "Leaderboard" option! We show you the World Record, your Personal Best, your three Rivals' scores, and then scores closest around you (might help you branch out and find some other people to rival!)

![Additionalscores](https://i.imgur.com/YOiiCcr.png)

Passed a new song? Got a new score? Your scores will be automatically uploaded to GrooveStats! Note that we do not upload failed scores and that those still need to be uploaded manually (either through the QR code or the [website](https://groovestats.com/)).

# ------------- New Song Wheel and Sort Menu -------------
Thanks to Box for help getting the new Song Wheel in it's current state!

I started working on this song wheel way back around 2018? and it's based of Casual Mode in Simply Love (Thanks quietly-turning <3)
I ended up giving up because it was well out of my abilities, but after picking it back up in 2021 I was determined to finish it. If it wasn't for Box though I don't think this would have ever seen the light of day. He helped me so much with a lot of sorting/filtering logic and I could not have done it without him. I learned a lot about coding and also how terrible Stepmania is while doing this. I definitely still have a lot more to learn too lol.

- A brand new songwheel with custom sorting and filtering options!

- New Sort Menu has Sort/Sub sort options.

- It can also filter songs by things like difficulty, bpm, and length.

- A Groovestats filter that will only display packs that are ranked on Groovestats.

- Song sorts/filters will be remembered between sessions as well. (Profile based)

Accessing the Sort Menu is the same as the default sort menu. To update any options all you need to do is select your desired sorts/filters and back out of the sort menu (either by pressing "Select" or "Escape"). It will automatically reload the music wheel with your new sort/filter preferences.

![sortmenu](https://i.imgur.com/zxYdwMk.png)

- Added a song search functionality. (In the sort menu)

![songsearch](https://i.imgur.com/bZ4R32V.png)

If your setup doesn't have a keyboard you can disable it from appearing in the sort menu in the Operator Menu under "Theme Options".
You can also refresh the music wheel/undo the song search by either closing the folder of the search or resetting your sorts in the sort menu.

# ---------- New Course Wheel and Sort Menu ----------
![CourseSelect](https://i.imgur.com/8RCKKYN.png)

This is similar to the custom song wheel and contains a slightly dumbed down sort/filter menu.
I'm still in disbelief that the engine doesn't have any sorting for courses and I still have no clue how it tries to sort them by default lol.
Now that is no longer an issue as we now have full control of the course wheel : )

![CourseSort](https://i.imgur.com/HEt81CT.png)

You can now use the sort menu to toggle between Course and Song select. 
The theme will also remember what you played last and take you directly into that mode after selecting your profile.

# ---------------- World Record Sounds? ----------------
There is now a folder at "Digital Dance/Sounds/WRSounds" where you can add any .ogg or .mp3 files.
Upon achieving a World Record with the Groovestats Launcher enabled the theme will randomly select a sound to play from that folder.
If no sounds are present nothing will play.
Alternatively if you want it to always play the same sound you can add just one file.

# ------------ How to use a profile picture ------------

- Add a new image at the root of your save folder of your profile.
- (Example: \Save\LocalProfiles\00000000\Profile Picture.png)

![pp](https://i.imgur.com/YDMuJjY.png)

The image must:
- Have a 1:1 aspect ratio for best appearance. (Image will be resized as such).
- Be titled "Profile Picture" or "Avatar"

## Aspect Ratio Support

  * <strong>16:9</strong> (common)
  * <strong>16:10</strong> (Apple laptops, some LCD monitors)
  
The aspect ratio can be changed under *Graphics / Sound Options*.

## SM5 Build Support
As noted in the "About" section this theme is intended for use with SM5 only.
* <strong>SM5.1 Beta 2</strong> (This is what I have been using to make/test this theme.)
* <strong>SM5.0.12</strong> (This should work in theory, but I haven't tested it extensively.)
* <strong>SM5.3</strong> (Use at your own risk.)


# -- General things to note --
- Theme is intended for home use only.

# ---------------- TO DO ----------------
- Make the measure counter not be dependant on runs being measure aligned.
- Always force Event Mode
- Add a way to select a profile for late join.
- Add a way for a player to unjoin a session in 2 player mode.
- Replace any graphics or sound assets from SL that still exist with new original ones.
- Maybe add more player stats (highest difficulty passed?)
- Add more sorts/filters?
- Create a tag system for songs/groups for custom profile sorts/filters.
- Create a hashcache so we can do sorts like NPS.
- Add some sort of basic mouse support ??? and utilize more of the keyboard/move away from "machine buttons".
- Have the Groovestats filter use chart hash to filter rather than by pack directory.
- Add a chart preview? This might be possible with HashCache, but we'll see in the future I guess.
- Clean up my code, it could be better.