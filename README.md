# Simply-Love-Tweaks
A new game mode that's basically Simply Love ITG but with a couple added features. Right now this mode works best for single player event mode. So no marathons, no FA+/Casual/Stomper, coin modes and doubles may work but i haven't tested them. This mode uses a profile's stats.xml to save/load scores (which is what Simply Love ITG mode uses)

NOTE-The first load will be VERY slow (the more songs you have the slower it'll go). Please be patient and let it sit - might take many minutes.

Requirements:

Simply Love 4.8.6 and a version of Stepmania that works with Simply Love

Installation:

Copy all the files here besides license/readme into your Simply Love directory.
NOTE-This overwrites some normal Simply Love files so I highly recommend backing up your version first (or using a fresh install)

Features:

[Expanded group information](https://i.imgur.com/7wbqhrt.jpg) - When choosing a group you can see how many songs/charts there are, how many you've passed, and some basic info like average difficulty.

[Expanded song information](https://i.imgur.com/XfJ5sgV.jpg) - Stream information that can be turned on/off and replaces the grid blocks in the normal song select. Shows peak NPS, Avg NPS, a breakdown of the stream based on the stream measure thing already in Simply Love, and the graph of the breakdown also already in Simply Love. There's also a list of tags. One is created automatically showing if there are BPM changes in a song.

[Song Tagging](https://i.imgur.com/SVJraE9.jpg) - Songs can be tagged with custom tags. These tags can be sorted/filtered or just help remind you of things. I personally use it to tag songs with too many crossovers and then filter it out so I never have to see them. Tags can be created in game if you have a keyboard or else there's a text file in the "Other" folder that you can modify to add/delete tags.

[Song Filtering](https://i.imgur.com/oGDJYy3.jpg) - Songs can be filtered based on tags, pass status (passed/failed/unplayed), number of jumps, steps, or difficulty. For songs that have multiple charts, ones that should be filtered will be greyed out but you can still select them. If a song has no charts that pass the filters it won't show up in your song list at all.

[Expanded evaluation information](https://i.imgur.com/j8duPhv.jpg) - Because there's no support for two players, I used the extra screen space to add on some other information that I personally like seeing.

Sorting by Grade/Difficulty - When sorting by grade, if a song has any chart with the selected grade it will show up on the list. When sorting by difficulty, any chart with the correct difficulty will show up on the list. In both cases you can still choose to play any of the other charts. As you play, songs will move around in to different grade groups.

Order options - Change the way songs are ordered within a group. For example, if you're looking at all songs that start with 'A' you can then sort them by BPM.

[Options Pane before starting a song](https://i.imgur.com/GU6vXBR.jpg) - before starting a song there's a selectable display with various bits of info. One is a graph of all the songs played today and what score you got on them. It's cool to visualize trends in difficulty/grade for me at least but for people who get 99+ all the time it's probably useless.

Charts are tracked by hash - if you have duplicates of a song you'll see your scores on both files. If you change the steps in a song it'll count as a new song and won't show all your old scores.

Known Issues:

There are a couple blank places that will eventually be filled in when I decide what to put there.

If you don't have a select button once you enter the options pane you have to either go to normal player options or start a song. 

I haven't tested different resolutions so probably doesn't work super well on widescreen.

Initial load is extremely slow

If you have tagged songs and then delete the tag, the tagged songs won't show up in the untagged group. Once you add the tag back in they'll all reappear.
