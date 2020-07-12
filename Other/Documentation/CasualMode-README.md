# Configuring Casual Mode

Casual Mode provides a simplified StepMania experience for novice players.  It seeks to get new players playing the game faster by addressing many common stumbling points.

To summarize, Casual Mode:

  * restricts what song groups are available to choose from
  * filters out stepcharts above a given difficulty meter
  * provides a new, dedicated Select Music screen to simplify the process of choosing a song
  * provides more prominent on-screen instructions throughout
  * simplifies the flow of a game cycle by removing certain screens

While Simply Love ships with some reasonable default settings for Casual Mode, some of the features described above can be configured by machine operators as desired.

## Filtering Stepcharts Above a Specific Difficulty Meter

By default, stepcharts with a difficulty meter greater than 10 will not appear in Casual Mode.  This threshold can be configured in the operator menu under *Simply Love Options*.

If *all* stepcharts belonging to a given song are above that threshold, that song will not appear as a choice in the group it belongs to in Casual Mode.  If all stepcharts in a given group are above the threshold (I'm looking at you, Tachyon Epsilon), that entire group will not appear as a choice in Casual Mode.

## Restricting Song Groups in Casual Mode

Casual Mode makes use of a simple txt file to explicitly specify what song groups should be available in Casual Mode.  The file is titled **CasualMode-Groups.txt** and is located at *./Simply Love/Other/CasualMode-Groups.txt*

Simply Love ships with 32 unique groups specified, chosen because they feature charts with full difficulties.  You can view the list [here](../CasualMode-Groups.txt).  These are reasonable, trusted defaults, and if you are a machine operator looking for more novice content for your machine, you can start by adding these packs!

Machine operators can customize this list as needed by adding (or removing) Groups by name, one per line.

If a group name is provided in that file that does not exist in the filesystem, it will be ignored.  If a group with no valid Casual Mode stepcharts is added to the list, that group will not appear as a valid choice.

If no groups are specified in this file (i.e., the file is empty), all packs with valid stepcharts will be available for play in Casual Mode.

## Specifying a Default Song for Casual Mode

Casual Mode makes use of a second simple txt file to specify a default song that Casual Mode will always start on.  The file is titled **CasualMode-DefaultSong.txt** and is located at *./Simply Love/Other/CasualMode-DefaultSong.txt*

You can view the file as it ships with Simply Love [here](../CasualMode-DefaultSong.txt).  The file follows the format of:

```
group name/song name
```

where `group name` and `song name` are the filenames of the relevant directories in the filesystem.

If a single line is provided, that song will always be the default song (assuming it exists).

If multiple lines are specified, one will be randomly selected for each new game cycle in Casual Mode as the default song.

If invalid or nonexistent songs are provided they will be ignored, and the first valid song in the first valid group will be used as a fallback default song.
