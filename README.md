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
✅ [StepMania 5.1-beta](https://github.com/stepmania/stepmania/releases/tag/v5.1.0-b2)<br>
✅ [StepMania 5.1 nightly builds](https://github.com/stepmania/stepmania/wiki/Nightly-Builds)

**Incompatible**<br>
❌ Alpha builds of SM5.3 are not supported at this time, but hopefully this will change in the future<br>
❌ Forks of SM5 (e.g. *starworlds*)<br>
❌ Older versions of StepMania (e.g. StepMania 3.9)<br>
❌ Forks of older versions of StepMania (e.g. OpenITG, notITG)<br>
❌ SM5.2


## Installing Simply Love

If you are upgrading from a previous version of Simply Love, fully delete the old Simply Love folder before moving the new folder into place.  **Do not try to merge the new folder into the old.**

You can read about and download the current release of Simply Love at the [Latest Release](https://github.com/quietly-turning/Simply-Love-SM5/releases/latest) page.

Full install instructions are in the [Installing Simply Love](./Other/InstallingSimplyLove-README.md) README.


## Language Support

Simply Love has support for:

  * English
  * Deutsch
  * Español
  * Français
  * Italiano
  * 日本語
  * Português Brasileiro

The current language can be changed in Simply Love under *System Options*.

## Screenshots

![Title Screen](https://i.imgur.com/tlKZad8l.png)
![Gameplay](https://i.imgur.com/6PRBIHil.png)
![Player Options](https://i.imgur.com/Jk5A4LTl.png)
![Evaluation with QR Code](https://i.imgur.com/TaApeGBl.png)
![Select Profile](https://i.imgur.com/bZc5xpll.png)
![Visual Themes](https://i.imgur.com/hGB1T4nl.png)

Visit my imgur album for more screenshots of this theme: [http://imgur.com/a/56wDq](http://imgur.com/a/56wDq)


## Features

#### New GameModes

* [Casual](http://imgur.com/zLLhDWQh.png) – Intended for novice players; restricted song list, no failing, no LifeMeter, simplified UI, etc.  You can read more about customizing what content appears in Casual Mode [here](./Other/CasualMode-README.md).
* [ITG](http://imgur.com/HS03hhJh.png) – Play using the *In the Groove* standards established over a decade ago
* [FA+](http://imgur.com/teZtlbih.png) – Similar to ITG, but features tighter TimingWindows; can be used to qualify for ECFA events

#### New Auxiliary Features

  * [Live Step Statistics](https://imgur.com/w4ddgSK.png) – This optional gameplay overlay tracks how many of each judgment have been earned in real time and features a notes-per-second density histogram.  This can make livestreaming more interesting for viewers.
  * [Judgment Scatter Plot](https://imgur.com/JK5Li2w.png) – ScreenEvaluation now features a judgment scatterplot where notes hit early are rendered "below the middle" and notes hit late are rendered "above the middle." This can offer insight into how a player performed over time. Did the player gradually hit notes earlier and earlier as the song wore on? This feature can help players answer such questions.
  * [Judgment Density Histogram](https://imgur.com/FAuieAf.png) – The evaluation screen also now features a histogram that will help players assess whether they are more often hitting notes early or late.
  * [Per-Column Judgment Breakdown](https://i.imgur.com/TaApeGB.png)
  * [QR Code Integration with GrooveStats](https://i.imgur.com/TaApeGB.png) – Evaluation now displays a QR code that will upload the score you just earned to your [GrooveStats](http://groovestats.com/) account.
  * [IIDX-inspired Pacemaker](http://imgur.com/NwN8Fnbh.png)
  * improved MeasureCounter – Stepcharts can now be parsed ahead of time, so it is no longer necessary to play through a stepchart at least once to acquire a stream breakdown.

#### New Aesthetic Features
 * [RainbowMode](http://i.imgur.com/aKsvrcch.png) – add some color to Simply Love!
 * [NoteSkin and Judgment previews](https://i.imgur.com/Jk5A4LT.png) in the modifier menu
 * improved widescreen support

#### New Conveniences for Public Machine Operators
  * [MenuTimer Options](https://i.imgur.com/SqbsMiw.png) – Set the MenuTimers for various screens.
  * [Long/Marathon Song Cutoffs](http://i.imgur.com/fzNJDVDh.png) – The cutoffs for songs that cost 2 and 3 rounds can be set in *Arcade Options*.
  * [USB Profile Options](https://i.imgur.com/ZgU9HGw.png) – Manage settings for player USB sticks, including custom songs.  Only available in SM5.1-beta and newer.


---

## FAQ

#### How can I get more songs to show up in Casual Mode?

Please refer to the [Casual Mode README](./Other/CasualMode-README.md).

#### I'm getting an error when I try to install StepMania.

Refer to the [Troubleshooting StepMania](./Other/TroubleshootingStepMania-README.md) guide included with Simply Love.

#### How can I load custom songs from USB sticks?

First, configure your PC for USB profiles.  Follow the guides for [Windows](https://github.com/stepmania/stepmania/wiki/Static-Mount-Points-for-USB-Profiles-(Windows)) or [Linux](https://github.com/stepmania/stepmania/wiki/Creating-Static-Mount-Points-For-USB-Profiles-%28Linux%29).

If you are using [SM5.1-beta](https://github.com/stepmania/stepmania/releases/tag/v5.1.0-b2) and have configured your computer using the guides linked above, you can use the [USB Profile Options menu](https://i.imgur.com/ZgU9HGw.png) in Simply Love to configure settings for custom songs.

Note that support for loading custom songs from USB profiles is new to StepMania 5.1.  It is not available in StepMania 5.0.12 and older.


#### Why does my timing graph look weird?

If your judgment distribution graph on Screen Evaluation has multiple individual "spikes" like Cloud Strife's hair in FFVII, your dance pad hardware is polling at a low rate.

![spiky boi](https://i.imgur.com/oMAQKoM.jpg)

Fixing this is outside the scope of Simply Love as a StepMania theme.  You may need to install drivers for your OS, modify hardware inside your dance pad, or both.

StarlightLumi wrote a guide for modifying L-Tek Dance Pads to poll at 1000 Hz:<br/>https://www.instructables.com/id/Modifying-an-L-tek-Dance-Pad-to-Poll-at-1000hz-on-/

StarlightLumi's L-TEK guide was based on original code and efforts by [natano](https://github.com/natano):<br/>https://www.natano.net/blog/2019-12-14-usb-polling-adventure/

[sahunt](https://github.com/sahunt) has a guide on modifying Windows to poll at 1000 Hz:<br/>https://www.hackmycab.com/?portfolio=usb-polling

geefr has a wiki page on identifying and troubleshooting USB polling issues in Linux:<br/>https://github.com/geefr/stepmania-linux-goodies/wiki/So-You-Think-You-Have-Polling-Issues