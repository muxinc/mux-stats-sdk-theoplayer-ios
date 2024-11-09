// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Mux-Stats-THEOplayer",
    platforms: [
        .iOS(.v12),
        .tvOS(.v12)
    ],
    products: [
        .library(
            name: "MuxStatsTHEOplayer",
            targets: ["MuxStatsTHEOplayer"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/muxinc/stats-sdk-objc.git",
            exact: "4.7.1"
        ),
        .package(
            url: "https://github.com/THEOplayer/theoplayer-sdk-ios.git",
            .upToNextMajor(from: "8.0.0")
        )
    ],
    targets: [
        .target(
            name: "MuxStatsTHEOplayer",
            dependencies: [
                .product(
                    name: "MuxCore",
                    package: "stats-sdk-objc"
                ),
                .product(
                    name: "THEOplayerSDK",
                    package: "theoplayer-sdk-ios"
                ),
            ]
        ),
        .testTarget(
            name: "MuxStatsTHEOplayerTests",
            dependencies: [
                "MuxStatsTHEOplayer",
                .product(
                    name: "MuxCore",
                    package: "stats-sdk-objc"
                ),
                .product(
                    name: "THEOplayerSDK",
                    package: "theoplayer-sdk-ios"
                ),
            ]
        ),
    ]
)
