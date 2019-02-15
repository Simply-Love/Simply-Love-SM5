# Simply Love (StepMania 5)

![Arrow Logo](http://i.imgur.com/FyeguCQ.png)
======================

This is a recreation of hurtpiggypig's Simply Love SM3.95 theme made to now run in StepMania 5.

I use the word "recreation" (as opposed to "port") because virtually no code was brought over from the SM3.95 counterpart.  My general process was to visually inspect the original SM3.95 theme, and recreate it screen by screen in SM5.

For information on the original StepMania 3.95 version of Simply Love, check here:
https://www.youtube.com/watch?v=OtcWy5m6-CQ



## Requirements

You'll need to install [StepMania 5.0.12](https://github.com/stepmania/stepmania/releases/tag/v5.0.12) or [StepMania 5.1 beta](https://github.com/stepmania/stepmania/releases/tag/v5.1.0-b2) to use this theme.

Older versions of StepMania are not compatible.  StepMania 5.2 is not compatible.

#### Troubleshooting StepMania

If you are having trouble installing StepMania or getting it to run on your computer, please refer to StepMania's [FAQ](http://www.stepmania.com/faq/).  Additionally, you may find these links helpful for your given operating system:

  * **Windows** -  [This issue on GitHub](https://github.com/stepmania/stepmania-site/issues/64) provides links to the needed DirectX and VS2013 redistributable packages.
  * **macOS** - If you are unable to open the dmg installer with an error like "No mountable file systems", you'll need to [update your copy of macOS](https://github.com/stepmania/stepmania/issues/1726) for the time being. If you are encountering the "No NoteSkins found" error, [this GitHub comment](https://github.com/stepmania/stepmania/issues/1299#issuecomment-275114142) provides a means of resolving it on your computer until it is properly fixed upstream.
  * **Linux** - It is more or less assumed that you will build your own executables if you are using Linux.  StepMania's GitHub wiki provides both a [list of dependencies](https://github.com/stepmania/stepmania/wiki/Linux-Dependencies) and some [instructions on compiling](https://github.com/stepmania/stepmania/wiki/Compiling-StepMania).


## Installation

To install this theme, unzip it and move the resulting directory inside the *Themes* folder in your [StepMania user data directory](https://github.com/stepmania/stepmania/wiki/User-Data-Locations).  The resulting directory structure should [look like this](http://www.personal.psu.edu/djg270/sites/sm5/?open=11-4).

## Screenshots

Visit my imgur album for screenshots of this theme in action: [http://imgur.com/a/56wDq](http://imgur.com/a/56wDq)


## New Features
Or, *things I've added that were not present in the original Simply Love for StepMania 3.95.*

#### New GameModes

* [Casual](http://i.imgur.com/zLLhDWQh.png) – Intended for novice players; restricted song list, no failing, no LifeMeter, simplified UI, etc.  You can read more about customizing what content appears in Casual Mode [here](./CasualMode-README.md).
* [Competitive](http://i.imgur.com/HS03hhJh.png) – Play using the *In the Groove* standards established over a decade ago
* [ECFA](http://i.imgur.com/teZtlbih.png) – Similar to Competitive, but features tighter TimingWindows; can be used to qualify for ECFA events
* [StomperZ](http://i.imgur.com/dOKTpVbh.png) – Emulates a very small set of features from Rhythm Horizon gameplay

#### New Auxiliary Features

  * [Live Step Statistics](https://imgur.com/w4ddgSK.png) – This optional gameplay overlay tracks how many of each judgment have been earned in real time and features a notes-per-second density histogram.  This can make livestreaming more interesting for viewers.
  * [Judgment Scatter Plot](https://i.imgur.com/JK5Li2w.png) – ScreenEvaluation now features a judgment scatterplot where notes hit early are rendered "below the middle" and notes hit late are rendered "above the middle." This can offer insight into how a player performed over time. Did the player gradually hit notes earlier and earlier as the song wore on? This feature can help players answer such questions.
  * [Judgment Density Histogram](https://i.imgur.com/FAuieAf.png) – The evaluation screen also now features a histogram that will help players assess whether they are more often hitting notes early or late.
  * [Per-Column Judgment Breakdown](https://imgur.com/ErcvncM.png)
  * [IIDX-inspired Pacemaker](http://i.imgur.com/NwN8Fnbh.png)
  * improved MeasureCounter – stepcharts can now be parsed ahead of time, so it is no longer necessary to play through a stepchart at least once to acquire a stream breakdown

#### New Aesthetic Features
 * [RainbowMode](http://i.imgur.com/aKsvrcch.png) – add some color to Simply Love!
 * [NoteSkin previews](https://imgur.com/NyHJGjc.png) in the modifier menu
 * improved widescreen support

#### New Conveniences for Public Machine Operators
  * [MenuTimer Options](http://imgur.com/DPffsdQh.png) – Set the MenuTimers for various screens.
  * [Long/Marathon Song Cutoffs](http://i.imgur.com/fzNJDVDh.png) – The cutoffs for songs that cost 2 and 3 rounds can be set in *Arcade Options*.

#### Language Support

Simply Love has full support for:

  * English
  * Español
  * Français

The current language can be changed in Simply Love under *System Options*.  You may need to restart StepMania immediately after changing the language for all in-game text to be properly translated.

## Missing Features
Or, *things that were in the original Simply Love for StepMania 3.95 that are not present here.*

  * ghost data
  * timed sets


---

## FAQ

#### Why are my high scores ranking out of order?
You need to set `PercentageScoring=1` in your Preferences.ini file.  Please note that you must quit StepMania before opening and editing Preferences.ini.

Your existing scores will remain ranked out of order, but all scores going forward after making this change will be ranked correctly.

#### Where is my Preferences.ini file?
See the [Manually Changing Preferences](https://github.com/stepmania/stepmania/wiki/Manually-Changing-Preferences) page on StepMania's GitHub Wiki.

#### How can I get more songs to show up in Casual Mode?
Please refer to the [Casual Mode README](./CasualMode-README.md).

---

## Acknowledgements

* [hurtpiggypig](http://www.shirtpiggypig.com/) -- Lara designed the original Simply Love theme for StepMania 3.95.
* [djpohly](https://github.com/djpohly) -- djpohly was a constant source of knowledge and help during the months I spent porting this.
* [sigatrev](https://github.com/sigatrev) -- Matt helped Lara implement some of the more technical aspects of the original theme and was always available to respond to my questions.
* [freem](https://github.com/freem) -- I used AJ's StepMania 5 theme, [Moonlight](http://ssc.ajworld.net/?p=moonlight), as the foundation/starting point for this port.  While virtually none of Moonlight is left in Simply Love at this point, it helped immensely in providing the examples I needed when getting started.
* [kyzentun](https://github.com/kyzentun) -- kyzentun answered many of my theming questions on IRC and even went out of his way to fix source-related issues that helped me out along my way.
* the SM5 dev-team and IRC-frequenters -- Theming in SM5 is significantly easier than it is in 3.95.  Thank you, for that.  Thank you, shakesoda, Midiman, wolfman2000, et al!
