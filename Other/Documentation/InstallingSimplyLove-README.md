# Installing Simply Love

## 1. Delete Old Copies First

If you are upgrading from a previous version of Simply Love, fully delete the old Simply Love folder first.

**Do not merge the new folder into the old.**

🔷 Reminder: If you added additional judgment graphics to your old copy of Simply Love, you'll want to back them up. You would have added them to `./Simply Love/Graphics/_judgments/` in the old theme, and that's where they'll go in the new theme.

## 2. Download

You can download the current Simply Love release at the **[Latest Release](https://github.com/Simply-Love/Simply-Love-SM5/releases/latest)** page.

As of this writing, GitHub puts the download link at the bottom of the release page, under the **Assets** header.

![download a Simply Love release](https://i.imgur.com/5ELYPW1l.png)

GitHub also provides two separate downloads (zip and tag.gz) labeled "Source code" under Assets.  If you just want to download and use Simply Love, you can safely ignore those. 🙂

## 3. Unzip, Install

To install Simply Love, unzip it and move the resulting *Simply Love* folder into your [StepMania user content folder](https://github.com/stepmania/stepmania/wiki/User-Data-Locations).

If you're using **SM5.0.12**, Simply Love should be installed here:

<table>
<tbody>
  <tr>
    <td>Windows 10, Windows 7</td>
    <td>C:\Users\<code>USERNAME</code>\AppData\Roaming\StepMania 5\Themes\Simply Love\</td>
  </tr>
  <tr>
    <td>macOS</td>
    <td>/Users/<code>USERNAME</code>/Library/Application Support/StepMania 5/Themes/Simply Love/</td>
  </tr>
  <tr>
    <td>Linux</td>
    <td>/home/<code>USERNAME</code>/.stepmania-5.0/Themes/Simply Love/</td>
  </tr>
</tbody>
</table>

Or, if you're using **SM5.1-beta**:

<table>
<tbody>
  <tr>
    <td>Windows 10, Windows 7</td>
    <td>C:\Users\<code>USERNAME</code>\AppData\Roaming\StepMania 5.1\Themes\Simply Love\</td>
  </tr>
  <tr>
    <td>macOS</td>
    <td>/Users/<code>USERNAME</code>/Library/Application Support/StepMania 5.1/Themes/Simply Love/</td>
  </tr>
  <tr>
    <td>Linux</td>
    <td>/home/<code>USERNAME</code>/.stepmania-5.1/Themes/Simply Love/</td>
  </tr>
</tbody>
</table>

🔷 Tip: If you find yourself adding/modifying themes frequently, you may wish to create a shortcut as the user content folder can be inconvenient to navigate to.

## 4. Switch to Simply Love

The next time you use StepMania, you can switch to Simply Love from the main options menu found on the Title Screen.

![switch to Simply Love](https://i.imgur.com/RoBLgZnh.png)

The exact process can vary depending on your current theme, but this setting is usually in **Options → Display Options → Appearance Options → Theme**

---

## Troubleshooting

If you switch to Simply Love and see a plain black screen with white text, you might have nested folders too deeply.

![folders nested too deeply](https://i.imgur.com/BP3TjLOh.png)

You might have `/Themes/Simply Love/Simply Love/` <br>
when you want &nbsp;`/Themes/Simply Love/`

This can happen when unzipping the download.

Quit StepMania, check to see if the theme's files are nested too deeply, and move the correct folder up a level if needed.