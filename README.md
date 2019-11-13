# Simply-Love-Tweaks
A new game mode that's basically Simply Love ITG but with a couple added features. Right now this mode ONLY works for player 1 playing alone in event single normal mode. So no marathons, probably no doubles, no FA+/Casual/Stomper, no two players at once, no coin modes (they may work but haven't tested). This mode uses a profile's stats.xml to save/load scores (which is what Simply Love ITG mode uses)

Requirements:

Simply Love 4.8.5 and a version of Stepmania that works with Simply Love

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

[Options Pane before starting a song](https://i.imgur.com/GU6vXBR.jpg) - before starting a song there's a selectable display with various bits of info. One is a graph of all the songs played today and what score you got on them. It's cool to visualize trends in difficulty/grade for me at least but for people who get 99+ all the time it's probably useless.

Known Issues:

There are a couple blank places that will eventually be filled in when I decide what to put there.

When starting a song, the normal "Press Start to enter options" appears even though you can't press anything.

If you don't have a select button once you enter the options pane you have to either go to normal player options or start a song. Similarly, if there's no back button you can't quit out of the game. Working on this.

There's some sort of race condition or something where sometimes entering sort menu doesn't disable input on normal music wheel.

I haven't tested different resolutions so probably doesn't work super well on widescreen.

I haven't tested with large libraries. Initial load is long because all songs need to be put in to groups but after that it should be fine.

A lot of text is written straight in so language files won't work.

If you have tagged songs and then delete the tag, the tagged songs won't show up in the untagged group. Once you add the tag back in they'll all reappear.
