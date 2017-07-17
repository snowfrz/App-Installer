# App Installer
An iOS app designed to allow you to install other (signed) iOS apps to your device.

Designed by Justin Proulx (Sn0wCh1ld), nullpixel, AppleBetas and CreatureSurvive.

<h2>Download</h2>
<h4><a href="https://github.com/Sn0wCh1ld/App-Installer/releases/download/1.0.4.0/App.Installer.ipa">1.0.4.0 (.ipa)</a></h4>
<h4><a href="https://github.com/Sn0wCh1ld/App-Installer/releases/download/1.0.3.0/App.Installer.ipa">1.0.3.0 (.ipa)</a></h4>
<h4><a href="https://github.com/Sn0wCh1ld/App-Installer/releases/download/1.0.2.1/App.Installer.ipa">1.0.2.1 (.ipa)</a></h4>
<strike><h4><a href="https://github.com/Sn0wCh1ld/App-Installer/releases/download/1.0.2.0/App.Installer.ipa">1.0.2.0 (.ipa)</a></h4></strike>
<h4><a href="https://github.com/Sn0wCh1ld/App-Installer/releases/download/1.0.1/App.Installer.ipa">1.0.1 (.ipa)</a></h4>
<h4><a href="https://github.com/Sn0wCh1ld/App-Installer/releases/download/1.0/App.Installer.ipa">1.0 (.ipa)</a></h4>

# Purpose
If for some reason, you cannot access the App Store, but have access to the .ipa file, you can put it on a file sharing service and use the raw link to install it using App Installer. Also useful if you're jailbroken with AppSync Unified installed and want an easy way to install your IPAs.

# Issues
- ~Cannot install any apps because of SSL requirement for itms-services installations~ FIXED
- ~Uploads fail because the server does not return JSON, but rather, plaintext.~ FIXED
- ~Server does not return download link~ FIXED
- ~Installation of apps creates a "scar" app on the home screen that cannot be deleted as far as I know. Similar issues arose back in the days of NoJailbreakApps and other such no-jailbreak stores. Scar app disappears eventually if you simply put it in a folder.~ NOT FIXED, BUT AN OFFICIAL WORKAROUND IS INCLUDED IN THE APP. WE WILL CONTINUE WORKING TO FULLY FIX IT.
  
  Workarounds:
  You can get rid of scar apps by doing one of two things.
  1. "Delete" the scar app using iOS' home screen editing mode, then put it in a folder. It will disappear eventually.
  2. Go to Settings > General > iPhone Storage. Wait for it to load, then scroll to the bottom. You will see either "App      Installer" or "Your App", depending on what version of App Installer you have installed. It will not have an icon, and will be about 20KB (so, a lot smaller than the 200KB size of the actual App Installer app). Select it, then press "Delete App".

- ~"Build Generated Issues"-type issues. Minor issues, mostly from deprecated methods used.~ FIXED
- Works sometimes, but not always for some reason. No clue why.
- Apps signed with a free developer account sometimes do not install for some reason. Please contact one of us if you manage to install an app signed with a free developer account.

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
