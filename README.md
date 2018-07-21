# App Installer
An iOS app designed to allow you to install other (signed) iOS apps to your device.

Designed by Justin Proulx (Sn0wCh1ld), nullpixel, AppleBetas and CreatureSurvive.

# Download
[Latest Version (1.0.4.0)](https://github.com/Sn0wCh1ld/App-Installer/releases/download/1.0.4.0/App.Installer.ipa)

Previous versions are available on the [Releases page](https://github.com/Sn0wCh1ld/App-Installer/releases).

# Purpose
If for some reason, you cannot access the App Store, but have access to the .ipa file, you can put it on a file sharing service and use the raw link to install it using App Installer. Also useful if you're jailbroken with AppSync Unified installed and want an easy way to install your IPAs.

# Issues
Issues are not necessarily for the current *release* of App Installer, but are for the current commit. Commits are often further ahead than releases, but don't always work properly. At this time (July 21st, 2018), the current release is version 1.0.4.0, while the current commit is for version 2.0.0.0.

**Classic Install Mode**
- Apps signed with a free developer account sometimes do not install for some reason. Please contact one of us if you manage to install an app signed with a free developer account.

**Resign Install Mode**
- Resigning with [libProvision](https://github.com/Matchstic/Extender-Installer/tree/new-backend/Shared/libProvision) succeeds, but the newly signed app does not install (iOS 11 and below), or does not open (iOS 12)
- Code is poorly written
- No progress bar after download stage

Contributions to the improvement of App Installer are greatly appreciated!

# Limitations
- At this time, apps must be signed already for App Installer to install them. Signed apps include App Store apps, and apps you signed yourself.

# License
This software is licensed under the MIT License, detailed in the file LICENSE.md

In addition to the terms outlined in the MIT License, you must also include a visible and easily useable link to my Twitter account (currently @JustinAlexP). If you really don't want to include one, contact me on Twitter @JustinAlexP and we'll come up with an agreement.

# Demo
Demo is of version 1.0. Changes have been made since then, but the core functionality is the same.
https://twitter.com/JustinAlexP/status/879551446013890561

# Developers
App Installer was mainly developed by [Justin Proulx](https://www.twitter.com/JustinAlexP), [nullpixel](https://twitter.com/nullriver), [AppleBetas](https://twitter.com/AppleBetasDev) and [CreatureSurvive](https://www.twitter.com/CreatureSurvive).
