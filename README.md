# App Installer
An iOS app designed to allow you to install other (signed) iOS apps to your device.

# Purpose
If for some reason, you cannot access the App Store, but have access to the .ipa file, you can put it on a file sharing service and use the raw link to install it using App Installer. Also useful if you're jailbroken with AppSync Unified installed and want an easy way to install your IPAs.

# Issues
- ~Cannot install any apps because of SSL requirement for itms-services installations~ FIXED
- ~Uploads fail because the server does not return JSON, but rather, plaintext.~ FIXED
- ~Server does not return download link~ FIXED
- Installation of apps creates a "scar" app on the home screen that cannot be deleted as far as I know. Similar issues arose back in the days of NoJailbreakApps and other such no-jailbreak stores. Scar app disappears eventually if you simply put it in a folder.
- "Build Generated Issues"-type issues. Minor issues, mostly from deprecated methods used.
- Works sometimes, but not always for some reason. No clue why.

If you want to contribute to the improvement of App Installer, please

# License
This software is licensed under the MIT License, detailed in the file LICENSE.md

In addition to the terms outlined in the MIT License, you must also include a visible and easily useable link to my Twitter account (currently @JustinAlexP). If you really don't want to include one, contact me on Twitter @JustinAlexP and we'll come up with an agreement.

# Demo
https://twitter.com/JustinAlexP/status/879551446013890561
