## Windows

**1.** Follow along with the StepMania installer, ensuring that you **do not install to Program Files** to avoid conflicts with Windows UAC.  By default, the installer will install to `C:\Games\` and this is recommended.

**2.** You'll likely need Microsoft's [Visual C++ x86 Redistributable for Visual Studio 2015](http://www.microsoft.com/en-us/download/details.aspx?id=48145).

**3.** You'll also need to have Microsoft's [DirectX 9 runtime](https://www.microsoft.com/en-ca/download/details.aspx?id=35).  It's possible you already have it installed from something else, but if StepMania crashes with <strong>d3dx9_43.dll was not found</strong> or <strong>XINPUT1_3.dll is missing</strong>, you don't, and you'll need to install it.

## macOS

### 10.15 Catalina

macOS 10.15 (Catalina) dropped support for 32-bit apps.  As a result, the most recent release of StepMania (SM5.1-beta2) is not compatible with macOS 10.15.

If you've already upgraded to Catalina, you'll need to build your own StepMania application from source code until the next release occurs.  The wiki has [instructions](https://github.com/stepmania/stepmania/wiki/Compiling-StepMania#macos) on how to do this.

#### older versions of macOS

If you're running an older version of macOS (10.7 to 10.14), you can still use [5.1-beta2](https://github.com/stepmania/stepmania/releases/tag/v5.1.0-b2).

You may find that beta2 crashes immediately with **No NoteSkins found** or **Metric "Common::ScreenWidth" is missing**.   [This wiki page](https://github.com/stepmania/stepmania/wiki/Installing-on-macOS) provides a workaround fix.

## Linux

If the precompiled executable is not compatible with your architecture/distro/etc., you'll likely have better luck building from source.

* [Linux Dependencies](https://github.com/stepmania/stepmania/wiki/Linux-dependencies)
* [Instructions on Compiling](https://github.com/stepmania/stepmania/wiki/Compiling-StepMania)