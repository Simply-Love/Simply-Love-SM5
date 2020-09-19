# Profile Avatars

Starting with v4.9, Simply Love supports profile avatars.

![Profile Avatars](https://i.imgur.com/ygMEo5sh.png)

## Creating a Profile

To have an avatar, you'll need a StepMania profile. You can create one in **Options → Manage Local Profiles → Create Profile**.  Profiles are handy for keeping track of scores and saving modifiers between games.

## Adding an Avatar

Once you have a profile, you can add an image named `Avatar.png` or `Avatar.jpg` to your profile folder on your computer.

If you're using **SM5.0.12**:

<table>
<tbody>
  <tr>
    <td>Windows 10, Windows 7</td>
    <td>C:\Users\<code>USERNAME</code>\AppData\Roaming\StepMania 5\Save\LocalProfiles\<code>profileID</code>\Avatar.png</td>
  </tr>
  <tr>
    <td>macOS</td>
    <td>/Users/<code>USERNAME</code>/Library/Preferences/StepMania 5/LocalProfiles/<code>profileID</code>/Avatar.png</td>
  </tr>
  <tr>
    <td>Linux</td>
    <td>/home/<code>USERNAME</code>/.stepmania-5.0/Save/LocalProfiles/<code>profileID</code>/Avatar.png</td>
  </tr>
</tbody>
</table>

Or, if you're using **SM5.1-beta**:

<table>
<tbody>
  <tr>
    <td>Windows 10, Windows 7</td>
    <td>C:\Users\<code>USERNAME</code>\AppData\Roaming\StepMania 5.1\Save\LocalProfiles\<code>profileID</code>\Avatar.png</td>
  </tr>
  <tr>
    <td>macOS</td>
    <td>/Users/<code>USERNAME</code>/Library/Preferences/StepMania 5.1/LocalProfiles/<code>profileID</code>/Avatar.png</td>
  </tr>
  <tr>
    <td>Linux</td>
    <td>/home/<code>USERNAME</code>/.stepmania-5.1/Save/LocalProfiles/<code>profileID</code>/Avatar.png</td>
  </tr>
</tbody>
</table>

In each of these paths, <code>USERNAME</code> will be your OS username and <code>profileID</code> will be your StepMania profile's ID (a numeric identifier like <code>00000001</code> or <code>00000008</code> or etc.).

## Recommendations

Avatars in Simply Love should be square.  Non-square images will be squished to fit a 1:1 aspect ratio.

Transparency in png files is supported.

Animated gifs and video files are not supported.

## Compatibility

If you've used Hayoreo's [Digital Dance](https://github.com/Hayoreo/digital-dance/) theme, you might already have an image in your profile folder titled `Profile Picture.png`.  Simply Love supports this; there's no need to rename it.