// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Mux-Stats-THEOplayer",
    platforms: [
        .iOS(.v15),
        .tvOS(.v15)
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
            .upToNextMajor(from: "5.4.0")
        ),
        .package(
            url: "https://github.com/THEOplayer/theoplayer-sdk-apple.git",
            .upToNextMajor(from: "11.0.0")
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
                    package: "theoplayer-sdk-apple"
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
                    package: "theoplayer-sdk-apple"
                ),
            ]
        ),
    ]
)
