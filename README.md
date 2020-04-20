# Simply Love (StepMania 5)

![Arrow Logo](https://i.imgur.com/oZmxyGo.png)
======================

## About

Simply Love is a StepMania 5 theme for the post-ITG community.

It features a clean and simple design, offers numerous data-driven features not implemented by the StepMania 5 engine, and allows the current generation of ITG fans to breathe new life into the game they've known for over a decade.

Simply Love was originally designed and implemented for a previous version of StepMania (SM3.95) by hurtpiggypig.  For more information on that version of Simply Love, check here:
https://www.youtube.com/watch?v=OtcWy5m6-CQ



## Supported Versions of StepMania

Simply Love is compatible with current releases of SM5 from the official StepMania project.

**Compatible**<br>
✅ [StepMania 5.0.12](https://github.com/stepmania/stepmania/releases/tag/v5.0.12)<br>
✅ [StepMania 5.1-beta](https://github.com/stepmania/stepmania/releases/tag/v5.1.0-b2)

**Incompatible**<br>
❌ Alpha builds of SM5.3 are not supported at this time, but hopefully this will change in the future<br>
❌ Forks of SM5 (e.g. *starworlds*)<br>
❌ Older versions of StepMania (e.g. StepMania 3.9)<br>
❌ Forks of older versions of StepMania (e.g. OpenITG, notITG)<br>
❌ SM5.2



## Installing Simply Love

You can download a zip of the latest formal release from the [Releases Page](https://github.com/quietly-turning/Simply-Love-SM5/releases/latest).

To install Simply Love, unzip it and move the resulting *Simply Love* folder into your [StepMania user data directory](https://github.com/stepmania/stepmania/wiki/User-Data-Locations).

The install paths will look like:

* **Windows**: `%APPDATA%\StepMania 5.1\Themes\Simply Love\`
* **macOS**: `~/Library/Application Support/StepMania 5.1/Themes/Simply Love/`
* **Linux**: `~/.stepmania-5.1/Themes/Simply Love/`

The next time you use StepMania, you can switch to Simply Love from the main options menu found on the Title Screen.  The exact process can vary depending on the theme you are currently using, but this is usually done within **Options → Display Options → Appearance Options → Theme**

## Screenshots

![Title Screen](https://i.imgur.com/tlKZad8l.png)
![Gameplay](https://i.imgur.com/6PRBIHil.png)
![Player Options](https://i.imgur.com/Jk5A4LTl.png)
![Evaluation with QR Code](https://i.imgur.com/TaApeGBl.png)
![Select Profile](https://i.imgur.com/bZc5xpll.png)
![Visual Themes](https://i.imgur.com/hGB1T4nl.png)

Visit my imgur album for more screenshots of this theme in action: [http://imgur.com/a/56wDq](http://imgur.com/a/56wDq)

## Features


#### New GameModes

* [Casual](http://imgur.com/zLLhDWQh.png) – Intended for novice players; restricted song list, no failing, no LifeMeter, simplified UI, etc.  You can read more about customizing what content appears in Casual Mode [here](./Other/CasualMode-README.md).
* [ITG](http://imgur.com/HS03hhJh.png) – Play using the *In the Groove* standards established over a decade ago
* [FA+](http://imgur.com/teZtlbih.png) – Similar to ITG, but features tighter TimingWindows; can be used to qualify for ECFA events

#### New Auxiliary Features

  * [Live Step Statistics](https://imgur.com/w4ddgSK.png) – This optional gameplay overlay tracks how many of each judgment have been earned in real time and features a notes-per-second density histogram.  This can make livestreaming more interesting for viewers.
  * [Judgment Scatter Plot](https://imgur.com/JK5Li2w.png) – ScreenEvaluation now features a judgment scatterplot where notes hit early are rendered "below the middle" and notes hit late are rendered "above the middle." This can offer insight into how a player performed over time. Did the player gradually hit notes earlier and earlier as the song wore on? This feature can help players answer such questions.
  * [Judgment Density Histogram](https://imgur.com/FAuieAf.png) – The evaluation screen also now features a histogram that will help players assess whether they are more often hitting notes early or late.
  * [Per-Column Judgment Breakdown](https://imgur.com/ErcvncM.png)
  * [IIDX-inspired Pacemaker](http://imgur.com/NwN8Fnbh.png)
  * [QR Code Integration with GrooveStats](https://imgur.com/olgg4hS.png) – Evaluation now displays a QR code that will upload the score you just earned to your [GrooveStats](http://groovestats.com/) account.
  * improved MeasureCounter – Stepcharts can now be parsed ahead of time, so it is no longer necessary to play through a stepchart at least once to acquire a stream breakdown.

#### New Aesthetic Features
 * [RainbowMode](http://i.imgur.com/aKsvrcch.png) – add some color to Simply Love!
 * [NoteSkin and Judgment previews](https://i.imgur.com/Jk5A4LT.png) in the modifier menu
 * improved widescreen support

#### New Conveniences for Public Machine Operators
  * [MenuTimer Options](https://i.imgur.com/SqbsMiw.png) – Set the MenuTimers for various screens.
  * [Long/Marathon Song Cutoffs](http://i.imgur.com/fzNJDVDh.png) – The cutoffs for songs that cost 2 and 3 rounds can be set in *Arcade Options*.
  * [USB Profile Options](https://i.imgur.com/ZgU9HGw.png) – Manage settings for player USB sticks, including custom songs.  Only available in SM5.1-beta and newer.

#### Language Support

Simply Love has support for:

  * English
  * Español
  * Français
  * Português Brasileiro
  * 日本語
  * Deutsch

The current language can be changed in Simply Love under *System Options*.


---

## FAQ

#### How can I get more songs to show up in Casual Mode?
Please refer to the [Casual Mode README](./Other/CasualMode-README.md).


#### I'm getting an error when I try to install StepMania.

StepMania can be tricky to install and the process has different stumbling points unique to each OS.

Refer to the [Troubleshooting StepMania README](./Other/TroubleshootingStepMania-README.md) included with Simply Love.

#### How can I let players load custom songs from USB sticks?

The StepMania project has wiki pages for configuring USB profiles for [Windows](https://github.com/stepmania/stepmania/wiki/Static-Mount-Points-for-USB-Profiles-(Windows)) and [Linux](https://github.com/stepmania/stepmania/wiki/Creating-Static-Mount-Points-For-USB-Profiles-%28Linux%29).

StepMania 5.1-beta and newer supports loading custom songs from USB profiles.  If you are using SM5.1-beta and have configured your computer using the Wikis linked to above, you can use the [USB Profile Options menu](https://i.imgur.com/ZgU9HGw.png) in Simply Love to configure settings for custom songs.


#### Why does my timing graph look weird?

If your timing graph on Screen Evaluation has multiple individual "spikes" like Cloud Strife's hair in FFVII, you have USB polling issues.

![spikey boi](https://i.imgur.com/oMAQKoM.jpg)

Fixing this is outside the scope of Simply Love as a StepMania theme.

GitHub user geefr has a [wiki page](https://github.com/geefr/stepmania-linux-goodies/wiki/So-You-Think-You-Have-Polling-Issues) on identifying and troubleshooting USB polling issues that may help.
