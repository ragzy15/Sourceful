// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Sourceful",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v10)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Sourceful",
            targets: ["Sourceful"]),
        .library(
            name: "SourcefulPrettier",
            targets: ["SourcefulPrettier"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SourcefulPrettier",
            dependencies: [],
            resources: [
                .process("Resources/parser-angular.js"),
                .process("Resources/parser-babylon.js"),
                .process("Resources/parser-flow.js"),
                .process("Resources/parser-glimmer.js"),
                .process("Resources/parser-graphql.js"),
                .process("Resources/parser-html.js"),
                .process("Resources/parser-markdown.js"),
                .process("Resources/parser-postcss.js"),
                .process("Resources/parser-typescript.js"),
                .process("Resources/standalone.js"),
                .process("Resources/vkbeautify.js"),
                .process("Resources/beautify.js"),
                .process("Resources/beautify-css.js"),
                .process("Resources/beautify-html.js"),
            ]),
        .testTarget(
            name: "SourcefulPrettierTests",
            dependencies: ["SourcefulPrettier"]),
        .target(
            name: "Sourceful",
            dependencies: []),
        .testTarget(
            name: "SourcefulTests",
            dependencies: ["Sourceful"]),
    ]
)
