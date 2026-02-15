// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Ncmdump",
    platforms: [
        .macOS("13.3"),
        .iOS("16.4")
    ],
    products: [
        .library(
            name: "Ncmdump",
            targets: ["Ncmdump"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/ktiays/taglib.git",
            revision: "5f0c9f71c8626e8f85c2df4200680a93d1b574c1"
        )
    ],
    targets: [
        .target(
            name: "Ncmdump",
            dependencies: ["CNcmdump"],
            path: "Sources/Ncmdump"
        ),
        .target(
            name: "CNcmdump",
            dependencies: [
                .product(name: "TagLib", package: "taglib")
            ],
            path: "Sources/CNcmdump",
            publicHeadersPath: "include",
            cxxSettings: [
                .headerSearchPath("internal")
            ],
            linkerSettings: [
                .linkedLibrary("z")
            ]
        ),
        .testTarget(
            name: "NcmdumpTests",
            dependencies: ["Ncmdump", "CNcmdump"],
            path: "Tests/NcmdumpTests",
            resources: [
                .copy("Resources/test.ncm")
            ]
        )
    ],
    cxxLanguageStandard: .cxx17
)
