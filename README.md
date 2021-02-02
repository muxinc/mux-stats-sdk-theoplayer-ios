# mux-stats-sdk-theoplayer-ios

Mux integration with `THEOplayer`'s native SDK for iOS native applications.

This integration is built on top of [Mux's core Objective-C library](https://github.com/muxinc/stats-sdk-objc), allowing thinner wrappers for each new player.

Note: this integration requires THEOplayer 2.76.0 or newer from version Mux SDK version 0.3.0 or newer. Older versions require THEOPlayer 2.67.0 or newer.

View [the guide on mux.com](https://docs.mux.com/docs/theoplayer-sdk-for-ios)

## Installation

Add this to your Podfile:

```
pod 'Mux-Stats-THEOplayer', '~> 0.4'
```

Then run `pod install`.

## Development

* Place `THEOplayerSDK.framework` (>= 2.76.0) in the root folder

## How to release

* Bump versions in Mux-Stats-THEOplayer.podspec
* Bump Version in XCode > Target > General
* Bump versions Constants.swift
* Execute `update-release-frameworks.sh` to make a full build
* Github - Create a PR to check in all changed files.
* If approved, `git tag [YOUR NEW VERSION]` and `git push --tags`
* Github - Make a new release with the new version
* Cocoapod - Run `pod spec lint` to local check pod validity
* Cocoapod - Run `pod trunk push Mux-Stats-THEOplayer.podspec`
* After the `update-release-frameworks.sh` build, run carthage-archive.sh.
* Then attach the output to the release
