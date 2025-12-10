// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "ImageSlider",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "ImageSlider",
            targets: ["ImageSlider"])
    ],
    targets: [
        .target(
            name: "ImageSlider",
            dependencies: []),
        .testTarget(
            name: "ImageSliderTests",
            dependencies: ["ImageSlider"])
    ]
)
