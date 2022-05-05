# Digital Dance v1.0.5

# ------------ Differences from 1.0.4 ------------
- Custom Course Wheel/Screen added with the abilty to sort/filter courses.
- You can now play songs and courses in the same session without starting a new one.
- FA+ and EX Score tracking added to gameplay/evaluation.
- ITL Support! (Requires [Groovestats Launcher v1.3.1 or newer](https://github.com/GrooveStats/gslauncher/releases))
- After selecting a profile you are taken directly to either Song or Course select based on what you last played.
- Added Total Measure count and Density % on song select.
- Sounds added by the user will now be randomly selected to play when a World Record is achieved.
- Column Cues added in player options to show where an arrow is coming after a break.
- Error Bar added in player options.
- Judgement Tilt added in player options.
- Fix lead in time on ScreenGameplay to account for rate mods.
- Dropping support for 4:3 displays in favor of not removing features due to screen real estate.


# ---------- New Course Wheel and Sort Menu ----------
![CourseSelect](https://i.imgur.com/8RCKKYN.png)

This is similar to the custom song wheel and contains a slightly dumbed down sort/filter menu.
I'm still in disbelief that the engine doesn't have any sorting for courses and I still have no clue how it tries to sort them by default lol.
Now that is no longer an issue as we now have full control of the course wheel : )

![CourseSort](https://i.imgur.com/HEt81CT.png)

You can now use the sort menu to toggle between Course and Song select. 
The theme will also remember what you played last and take you directly into that mode after selecting your profile.

# ---------- FA+ Emulation ----------

Players can now toggle whether or not they want to display the FA+ (15ms) window from the player options menu.

All judgments support this emulation.

![FA+ tracking](https://i.imgur.com/EXgS3Zn.png)

# ---------- EX Scoring ----------

The players in the community have gotten significantly better over time, and the default scoring weights from ITG leave a lot to be desired for timing centric players and events. Past tournaments already ignored ITG weights for their own personally defined weights.

This takes this a step further and integrates EX style scoring into the theme separately. This is done in addition to the ITG scoring modes so there are no changes related to that.

There is now a player option to replace the displayed ITG score with with the EX score as well. With this option enabled, Subtractive Scoring will now refer to this EX Score.

On Screen Evaluation, there's an additional Pane for players that might care about one scoring type versus another.

![EX Score on evaluation](https://i.imgur.com/W4xbZHP.png)

# ---------- Step Statistics in Versus Mode. ----------

This will only be visible/selectable in any widescreen mode.

![versus step stats](https://i.imgur.com/hGIJLCR.png)

# ----------  Scorebox ----------

With GS Integration we have leaderboards and other neat things. Other themes have incorporated a notion of a "Scorebox" which displays the current GrooveStats/RPG/ITL scores on songs in ScreenGameplay. Digital Dance now incorporates the same when Step Statistics is active and a machine is connected to the internet.

![scorebox](https://i.imgur.com/DxG4lnH.png)

# ----------  Error Bar ----------
How off are your steps really? Find out with the Error Bars! Choose from two different visualizations (not shown is also the option to simply show Early/Late)

![errorbar](https://user-images.githubusercontent.com/5017202/117606998-ecc6a800-b10f-11eb-9dea-68db07fe126e.png)

# ----------  Judgment Tilt ----------

Another useful option that other themes have incorporated is a "judgment tilt" that rotates the judgment font depending on the millisecond difference from 0 a player is on each step. This feature has now also been ported to Digital Dance.

# ---------------- World Record Sounds? ----------------
There is now a folder at "Digital Dance/Sounds/WRSounds" where you can add any .ogg or .mp3 files.
Upon achieving a World Record with the Groovestats Launcher enabled (or a quad on anything) [the theme will randomly select a sound to play from that folder.](https://clips.twitch.tv/FuriousLongSnail4Head-xPkflHV6iE19dFg3)
If no sounds are present nothing will play.
Alternatively if you want it to always play the same sound you can add just one file.

![wrsounds](https://i.imgur.com/L9fs22O.png)

## Aspect Ratio Support

  * <strong>16:9</strong> (common)
  * <strong>16:10</strong> (Apple laptops, some LCD monitors)
  
The aspect ratio can be changed under *Graphics / Sound Options*.

## SM5 Build Support
As noted in the "About" section this theme is intended for use with SM5 only.
* <strong>SM5.1 Beta 2</strong> (This is what I have been using to make/test this theme.)
* <strong>SM5.0.12</strong> (This should work in theory, but I haven't tested it extensively.)


# -- General things to note --
- Theme is intended for home use only.