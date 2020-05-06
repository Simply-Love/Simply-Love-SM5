### Windows

Follow along with the StepMania installer, ensuring that you **do not install to Program Files** to avoid conflicts with Windows UAC.  By default, the installer will install to `C:\Games\` and this is fine for most players.

You'll likely need Microsoft's [Visual C++ x86 Redistributable for Visual Studio 2015](http://www.microsoft.com/en-us/download/details.aspx?id=48145).

You'll also need to have Microsoft's [DirectX 9 runtime](https://www.microsoft.com/en-ca/download/details.aspx?id=35).  It's possible you already have the DirectX 9 runtime installed, but if StepMania crashes with **d3dx9_43.dll was not found** or **XINPUT1_3.dll is missing**, you don't, and will need it first.

It [should be okay](https://github.com/stepmania/stepmania/issues/1936#issuecomment-557917810) to have multiple DirectX runtimes installed.

### macOS

If you are unable to open the dmg installer with an error like "No mountable file systems", you'll need to [update your copy of macOS](https://github.com/stepmania/stepmania/issues/1726) for the time being.

If StepMania crashes immediately with **No NoteSkins found** or **Metric "Common::ScreenWidth" is missing**, [this wiki page](https://github.com/stepmania/stepmania/wiki/Installing-on-macOS) provides a way of fixing it on your computer until it the problem is properly fixed in StepMania.

### Linux

If the precompiled executable is not compatible with your architecture/distro/etc., you'll likely have better luck compiling from source.

* [Linux Dependencies](Linux-dependencies)
* [Instructions on Compiling](Compiling-StepMania)