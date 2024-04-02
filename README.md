# mux-stats-sdk-theoplayer-ios

Mux integration with `THEOplayer`'s native SDK for iOS native applications.

This integration is built on top of [Mux's core Objective-C library](https://github.com/muxinc/stats-sdk-objc), allowing thinner wrappers for each new player.

Mux Data SDK for THEOplayer v0.9.0 is compatible with THEOplayer 6.12.1 or newer. Older Mux Data SDK for THEOplayer versions require THEOPlayer 2.76.0 or newer.

View [the guide on mux.com](https://docs.mux.com/docs/theoplayer-sdk-for-ios)

## Installation

### Swift Package Manager - Xcode

1. In Xcode menu bar click "File" > "Swift Packages" > "Add Package Dependency..."
2. Enter package repository URL https://github.com/muxinc/mux-stats-sdk-theoplayer-ios.git 
3. Click Next
4. Specify the dependency "Rules", we recommened choosing the option "Up to Next Major".
Note that MuxStatsTHEOplayer depends on MuxCore. The MuxCore will also be installed.

### Swift Package Manager - Package.swift

Add the following to your `Package.swift` dependencies

```swift
.package(
      url: "https://github.com/muxinc/mux-stats-sdk-theoplayer-ios",
      .upToNextMajor(from: "0.9.0")
    ),
```

### Cocoapods

Add this to your Podfile:

```
pod 'Mux-Stats-THEOplayer', '~> 0.9'
```

Then run `pod install`.

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
