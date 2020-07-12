# Simply Love (StepMania 5)

![Arrow Logo](https://i.imgur.com/oZmxyGo.png)


## About

Simply Love is a StepMania 5 theme for the post-ITG community.

It features a clean and simple design, offers numerous data-driven features not implemented by the StepMania 5 engine, and allows the current generation of ITG fans to breathe new life into the game they've known for over a decade.

Simply Love was originally designed and implemented for a previous version of StepMania (SM3.95) by hurtpiggypig.  For more information on that version of Simply Love, check here:
https://www.youtube.com/watch?v=OtcWy5m6-CQ


## Supported Versions of StepMania

Simply Love is compatible with current releases from the official StepMania project.

**Compatible Releases**<br>
✅ [StepMania 5.0.12](https://github.com/stepmania/stepmania/releases/tag/v5.0.12)<br>
✅ [StepMania 5.1-b2](https://github.com/stepmania/stepmania/releases/tag/v5.1.0-b2)<br>

If you are able to compile StepMania's source code yourself, the [5_1-new branch](https://github.com/stepmania/stepmania/tree/5_1-new/) is supported.  The wiki has [instructions for compiling](https://github.com/stepmania/stepmania/wiki/Compiling-StepMania).


**Incompatible**<br>
❌ Alpha builds of SM5.3 are not supported at this time, but hopefully this will change in the future<br>
❌ Forks of SM5 (e.g. *starworlds*)<br>
❌ Older versions of StepMania (e.g. StepMania 3.9)<br>
❌ Forks of older versions of StepMania (e.g. OpenITG, NotITG)<br>
❌ SM5.2


## Installing Simply Love

If you are upgrading from a previous version of Simply Love, fully delete the old Simply Love folder first.  **Do not merge the new folder into the old.**

You can download the current Simply Love release at the [Latest Release](https://github.com/quietly-turning/Simply-Love-SM5/releases/latest) page.

Full install instructions are in the [Installing Simply Love](./Other/Documentation/InstallingSimplyLove-README.md) README.


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


## Aspect Ratio Support

Simply Love is designed to be usable at resolutions as low as 640x480 but still look crisp and clean in HD, 2k, 4k, etc.  It supports many screen aspect ratios:

  * <strong>16:9</strong> (common)
  * <strong>16:10</strong> (Apple laptops, some LCD monitors)
  * <strong>4:3</strong> (CRT arcade monitors, older TVs)
  * <strong>21:9</strong> ("Ultrawide")

The aspect ratio can be changed under *Graphics / Sound Options*.


## Screenshots

![Title Screen](https://i.imgur.com/txGZj2Ul.png)
![Gameplay](https://i.imgur.com/6PRBIHil.png)
![twenty-one nine gameplay](https://i.imgur.com/rl6WibDl.png)
![Player Options](https://i.imgur.com/Jk5A4LTl.png)
![Evaluation](https://i.imgur.com/VamMT1Ql.png)
![Select Profile](https://i.imgur.com/1SsDc90l.png)
![Visual Themes](https://i.imgur.com/AQeRafLl.png)

Visit my imgur album for more screenshots: [http://imgur.com/a/56wDq](http://imgur.com/a/56wDq)


## Features

Refer to the [Features README](./Other/Documentation/Features-README.md) for a basic list of features and screenshots.

---

## FAQ

#### How can I get more songs to show up in Casual Mode?

Please refer to the [Casual Mode README](./Other/Documentation/CasualMode-README.md).

#### I'm getting an error when I try to install StepMania.

Refer to the [Troubleshooting StepMania](./Other/Documentation/TroubleshootingStepMania-README.md) guide included with Simply Love.

#### How can I load custom songs from USB sticks?

First, configure your PC for USB profiles.  Follow the guides for [Windows](https://github.com/stepmania/stepmania/wiki/Static-Mount-Points-for-USB-Profiles-(Windows)) or [Linux](https://github.com/stepmania/stepmania/wiki/Creating-Static-Mount-Points-For-USB-Profiles-%28Linux%29).

If you are using [SM5.1-beta](https://github.com/stepmania/stepmania/releases/tag/v5.1.0-b2) and have followed the guides linked above, you can use the [USB Profile Options menu](https://i.imgur.com/ZgU9HGw.png) in Simply Love to configure settings for custom songs.

Note that support for loading custom songs from USB profiles is new to StepMania 5.1.  It is not available in StepMania 5.0.12 and older.


#### Why does my timing graph look weird?

If your judgment distribution graph on Screen Evaluation has multiple individual "spikes" like Cloud Strife's hair in FFVII, your dance pad hardware is polling at a low rate.

![spiky boi](https://i.imgur.com/ay1G6rml.png)

Fixing this is outside the scope of Simply Love as a StepMania theme.  You may need to install drivers for your OS, modify hardware inside your dance pad, or both.

StarlightLumi wrote a guide for modifying L-Tek Dance Pads to poll at 1000 Hz:<br/>https://www.instructables.com/id/Modifying-an-L-tek-Dance-Pad-to-Poll-at-1000hz-on-/

StarlightLumi's L-TEK guide was based on original code and efforts by [natano](https://github.com/natano):<br/>https://www.natano.net/blog/2019-12-14-usb-polling-adventure/

[sahunt](https://github.com/sahunt) has a guide on modifying Windows to poll at 1000 Hz:<br/>https://www.hackmycab.com/?portfolio=usb-polling

geefr has a wiki page on identifying and troubleshooting USB polling issues in Linux:<br/>https://github.com/geefr/stepmania-linux-goodies/wiki/So-You-Think-You-Have-Polling-Issues