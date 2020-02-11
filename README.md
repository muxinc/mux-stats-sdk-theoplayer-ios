# mux-stats-sdk-theoplayer-ios

Mux integration with `THEOplayer`'s native SDK for iOS native applications.

This integration is built on top of [Mux's core Objective-C library](https://github.com/muxinc/stats-sdk-objc), allowing thinner wrappers for each new player.

Note: this integration requires THEOplayer 2.61.0 or newer.

## Quickstart
* While we work on publishing this via cocoapods, you can reference this repository as a development pod after you clone this repo
* The built frameworks are available in the `Frameworks` directory if you do not want to build your own version

## Prerequisites
* Place `THEOplayerSDK.framework` in the root folder

## How to release
* Bump versions in MUXSDKStatsTHEOplayer.info, and Mux-Stats-THEOplayer.podspec
* Execute `update-release-frameworks.sh` to make a full build
* Github - Create a PR to check in all changed files.
* If approved, `git tag [YOUR NEW VERSION]` and `git push --tags`
* Github - Make a new release with the new version
* Cocoapod - Run `pod spec lint` to local check pod validity
* Cocoapod - Run `pod trunk push Mux-Stats-THEOplayer.podspec`

* To support Carthage framework management,
* After the `update-release-frameworks.sh` build, run carthage-archive.sh.
* Then attach the output to the release
