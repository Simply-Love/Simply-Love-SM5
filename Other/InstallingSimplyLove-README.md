# Installing Simply Love

### Delete Old Copies First

If you are upgrading from a previous version of Simply Love, fully delete the old Simply Love folder first.  **Do not try to merge the new folder into the old.**

### Download

You can download the current Simply Love release at the [Latest Release](https://github.com/quietly-turning/Simply-Love-SM5/releases/latest) page

### Unzip, Install

To install Simply Love, unzip it and move the resulting *Simply Love* folder into your [StepMania user content folder](https://github.com/stepmania/stepmania/wiki/User-Data-Locations).

If you're using SM5.0.12, Simply Love should be installed here:

* **Windows**: `%APPDATA%\StepMania 5\Themes\Simply Love\`
* **macOS**: `~/Library/Application Support/StepMania 5/Themes/Simply Love/`
* **Linux**: `~/.stepmania-5.0/Themes/Simply Love/`

Or, if you're using SM5.1-beta:

* **Windows**: `%APPDATA%\StepMania 5.1\Themes\Simply Love\`
* **macOS**: `~/Library/Application Support/StepMania 5.1/Themes/Simply Love/`
* **Linux**: `~/.stepmania-5.1/Themes/Simply Love/`

The `Themes`, `NoteSkins`, `Songs`, etc. sub-folders in your user content folder is where content should be installed to minimize the chance of permission errors.

If you find yourself adding content frequently, you may wish to create a shortcut as it can be incovenient to navigate to manually.

### Switch to Simply Love using UI

The next time you use StepMania, you can switch to Simply Love from the main options menu found on the Title Screen.

![switch to Simply Love](https://i.imgur.com/RoBLgZnh.png)

The exact process can vary depending on your current theme, but this setting is usually in **Options → Display Options → Appearance Options → Theme**

---

## Troubleshooting

If you switch to Simply Love and see a plain black screen with white text, you might have nested folders too deeply.

![folders nested too deeply](https://i.imgur.com/BP3TjLOh.png)

You might have `/Themes/Simply Love/Simply Love/` <br>
when you want `/Themes/Simply Love/`

This can happen when unzipping the download.

Quit StepMania, check to see if the theme's files are nested too deeply, and move the correct folder up a level if needed.