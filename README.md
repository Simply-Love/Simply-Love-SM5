# Digital Dance v1.0.0
Huge thanks to Nantano, Sujeet, Ian, and Dom for the Groovestats Launcher/Intergration!
Also thanks to Box for help getting the new Song Wheel in it's current state!
Without them this update wouldn't be nearly as awesome~

# ---------------- GrooveStats Integration ----------------
Rivals, Scores, Leaderboards, Auto-Uploading of scores, it's all here! Please [watch the video](https://www.youtube.com/watch?v=8yMzp7xMQq0) and refer the [GrooveStats Launcher Guide](https://github.com/GrooveStats/gslauncher#readme) on how to setup the StepMania wrapper program that will get you connected.

First, check and see if you're connected!

![CheckConnection](https://i.imgur.com/QQOsCG9.png)

Setup your Rivals on [GrooveStats](https://groovestats.com/index.php?page=register&action=update) and check out your scores write in on the Select Music Screen

![PaneDisplayGSScores](https://i.imgur.com/BrTCdFy.png)

Want to see more scores? Open the sort menu and select the "Leaderboard" option! We show you the World Record, your Personal Best, your three Rivals' scores, and then scores closest around you (might help you branch out and find some other people to rival!)

![Additionalscores](https://i.imgur.com/YOiiCcr.png)

Passed a new song? Got a new score? Your scores will be automatically uploaded to GrooveStats! Note that we do not upload failed scores and that those still need to be uploaded manually (either through the QR code or the web portal).

# ---------------- New Song Wheel and Sort Menu ----------------

I started working on this song wheel way back in like 2018? and it's based of Casual Mode in Simply Love (Thanks quietly-turning <3)
I ended up giving up because it was well out of my abilities, but after picking it back up earlier this year I was determined to finish it. If it wasn't for Box though I don't think this would have ever seen the light of day. He helped me so much with a lot of sorting/filtering logic and I could not have done it without him. I learned a lot about coding and also how terrible Stepmania is while doing this. I definitely still have a lot more to learn too lol.

- A brand new songwheel with custom sorting and filtering options!

- New Sort Menu has Sort/Sub sort options.

- It can also filter songs by things like difficulty, bpm, and length.

- A Groovestats filter that will only display packs that are ranked on Groovestats.

- Song sorts/filters will be remembered between sessions as well. (Profile based)

Currently to access the Sort Menu you have to press the "Select" button (typically the red button on a cab). To update any options all you need to do is select your desired sorts/filters and back out of the sort menu (either by pressing "Select" or "Escape"). It will automatically reload the music wheel with your new sort/filter preferences.

![sortmenu](https://i.imgur.com/37sNdIj.png)

- Added a song search functionality. (In the sort menu)

![songsearch](https://i.imgur.com/bZ4R32V.png)

If you don't have a keyboard you can just press enter to go back to the music wheel. In the future I will change this to just not show up if you don't have a keyboard, but I want this release to come out asap.


# ---------------- Other Changes ----------------

- Density Graph color is based off of NPS. The higher the NPS the more red it is.
- Density Graph breakdown on song select is now more detailed and caches so it only needs to be parsed once. (Thanks Sujeet!)
- Removal of game modes.
- CDTitle support added.

# ---------------- How to use a profile picture ----------------

- Add a new image at the root of your save folder of your profile.
- (Example: \Save\LocalProfiles\00000000\Profile Picture.png)

![pp](https://i.imgur.com/YDMuJjY.png)

The image must:
- Have a 1:1 aspect ratio for best appearance. (Image will be resized as such).
- Be titled "Profile Picture" or "Avatar"

## Aspect Ratio Support

  * <strong>16:9</strong> (common)
  * <strong>16:10</strong> (Apple laptops, some LCD monitors)
  * <strong>4:3</strong> (CRT arcade monitors, older TVs)
  
The aspect ratio can be changed under *Graphics / Sound Options*.

# -- KNOWN ISSUES and general things to note --
- Sort Menu can only be accessed if you have 4 button navigation on at the moment (aka having a "Select"/Red button)
- Theme is intended for home use only.
- I don't expect this to work outside of event mode.
- 4:3 aspect ratio has less info displayed on 2 player because of lack of room. (No density graph or profile pane)

# ---------------- TO DO ----------------
- Make the Sort Menu accessible to people with 3 button navigation.
- Maybe add more player stats (highest difficulty passed?)
- Add more sorts/filters?
- Add "Favorites" and/or tags for songs/groups.
- Add a hashcache so I can do sorts like NPS.
- Have the Groovestats filter use chart hash to filter rather than by pack directory.
- I really want to add a chart preview. This might be possible with HashCache, but we'll see in the future I guess.
- Clean up my code. It's better now than it was in the last version, but could be better.
