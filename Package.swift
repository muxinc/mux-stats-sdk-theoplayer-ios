// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Mux-Stats-THEOplayer",
    platforms: [.iOS(.v11)],
    products: [
        .library(
            name: "MuxStatsTHEOplayer",
            targets: ["MuxStatsTHEOplayer"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/muxinc/stats-sdk-objc.git",
            exact: "4.5.2"
        ),
        .package(
            url: "https://github.com/THEOplayer/theoplayer-sdk-ios.git",
            from: "6.12.1"
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
