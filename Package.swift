// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "AppBanners",
    platforms: [.macOS(.v10_15), .iOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AppBanners",
            targets: ["AppBanners"]
        ),
//        .executable(
//            name: "AppBannersClient",
//            targets: ["AppBannersClient"]
//        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0-latest"),
    ],
    targets: [
        .macro(
            name: "AppBannersMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(
            name: "AppBanners",
            dependencies: ["AppBannersMacros"]
        ),
        // A client of the library, which is able to use the macro in its own code.
//        .executableTarget(name: "AppBannersClient", dependencies: ["AppBanners"]),
        .testTarget(
            name: "AppBannersTests",
            dependencies: [
                "AppBannersMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
