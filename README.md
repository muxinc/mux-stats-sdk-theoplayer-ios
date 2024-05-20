# mux-stats-sdk-theoplayer-ios

Mux integration with `THEOplayer`'s native SDK for iOS native applications.

This integration is built on top of [Mux's core Objective-C library](https://github.com/muxinc/stats-sdk-objc), allowing thinner wrappers for each new player.

Mux Data SDK for THEOplayer is compatible with THEOplayer 7.1.0 or newer.

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
      .upToNextMajor(from: "0.10.0")
    ),
```

### Cocoapods

Add this to your Podfile:

```
pod 'Mux-Stats-THEOplayer', '~> 0.10'
```

Then run `pod install`.

## How to release

* Checkout and push a release branch named: `releases/vX.Y.Z` where X, Y, Z are the major, minor, and patch versions of the release
* Github - open pull requests with release branch as destination for your changes
* Update version in Mux-Stats-THEOplayer.podspec on release branch
* Update version in `Constants.swift` on release branch
* Update version in the Examples and in this README
* Github - open a pull request to merge release branch to `master`
* If approved, merge release branch using squash merging 
* Add `git tag [YOUR NEW VERSION]` and `git push --tags`
* Github - Make a new release with the new version
* Cocoapod - Run `pod spec lint` to local check pod validity
* Cocoapod - Run `pod trunk push Mux-Stats-THEOplayer.podspec`
