# mux-stats-sdk-theoplayer-ios

Mux integration with `THEOplayer`'s native SDK for iOS native applications.

This integration is built on top of [Mux's core Objective-C library](https://github.com/muxinc/stats-sdk-objc), allowing thinner wrappers for each new player.

## Requirements

Note: this integration requires THEOplayer 2.76.0 or newer from version Mux SDK version 0.3.0 or newer. Older versions require THEOPlayer 2.67.0 or newer.

View [the guide on mux.com](https://docs.mux.com/docs/theoplayer-sdk-for-ios)

## Installation

To use Mux's THEOplayer integration in your iOS project, add this to your Podfile:

```
pod 'Mux-Stats-THEOplayer', '~> 0.4'
```

Then run `pod install`.

## Development

* In `MUXSDKStatsTHEOplayer/`, install the required dependencies: `pod install`
* Download `THEOplayerSDK.xcframework` (>= 2.76.0) from the THEOplayer portal
* In Xcode: Open `MUXSDKStatsTHEOplayer/MUXSDKStatsTHEOplayer.xcworkspace`
  * In the project navigator:
     * Delete the existing reference to `THEOplayerSDK.xcframework` in `MUXSDKStatsTHEOplayer/Frameworks`
     * Drag and drop the downloaded `THEOplayerSDK.xcframework` from Finder into `MUXSDKStatsTHEOplayer/Frameworks`

https://user-images.githubusercontent.com/15208707/178379606-7ba319e0-88eb-4b92-ba54-e07ac8485cf7.mov

Hit CMD + B to build the project (making sure the build target is set to an iOS device or simulator) -- it should succeed.


## How to release

* Bump versions in Mux-Stats-THEOplayer.podspec
* Bump Version in Xcode > MUXSDKStatsTheoplayer (Project Navigator) > Targets > MUXSDKStatsTHEOplayer > General > Identity.
* Bump versions in Constants.swift (`MUXSDKStatsTHEOplayer/MUXSDKStatsTHEOplayer/Constants.swift`)
* Execute `update-release-frameworks.sh` to make a full build
* Github - Create a PR to check in all changed files.
* If approved, `git tag [YOUR NEW VERSION]` and `git push --tags`
* Github - Make a new release with the new version
* Cocoapod - Run `pod spec lint` to local check pod validity
* Cocoapod - Run `pod trunk push Mux-Stats-THEOplayer.podspec`
* After the `update-release-frameworks.sh` build, run `archive.sh`.
* Then attach the output to the release
