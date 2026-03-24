// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "PyanArchitecture",
	platforms: [
		.iOS(.v18),
		.macOS(.v15),
		.macCatalyst(.v18),
		.tvOS(.v18),
		.watchOS(.v11),
		.visionOS(.v2)
	],
    products: [
        .library(
            name: "PyanArchitecture",
            targets: ["PyanArchitecture"]
        ),
		.library(
			name: "PyanArchitectureSample",
			targets: ["PyanArchitectureSample"]
		)
    ],
	dependencies: [
		.package(url: "https://github.com/percypyan/pyan-inject.git", .upToNextMajor(from: "0.2.0")),
		.package(url: "https://github.com/percypyan/pyan-router.git", .upToNextMajor(from: "0.1.3")),
		.package(url: "https://github.com/percypyan/pyan-logging.git", .upToNextMajor(from: "0.2.0")),
		.package(url: "https://github.com/percypyan/pyan-feature-switcher.git", .upToNextMajor(from: "0.2.0")),
		.package(url: "https://github.com/percypyan/pyan-testing.git", .upToNextMajor(from: "0.1.1")),
		.package(url: "https://github.com/swiftlang/swift-syntax.git", from: "602.0.0"),
	],
    targets: [
		.macro(
			name: "PyanArchitectureMacros",
			dependencies: [
				.product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
				.product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
			]
		),
        .target(
            name: "PyanArchitecture",
			dependencies: [
				.product(name: "PyanInject", package: "pyan-inject"),
				.product(name: "PyanRouter", package: "pyan-router"),
				.product(name: "PyanLogging", package: "pyan-logging"),
				.product(name: "PyanFeatureSwitcher", package: "pyan-feature-switcher"),
				.product(name: "PyanMocking", package: "pyan-testing"),
				"PyanArchitectureMacros",
			]
        ),
        .testTarget(
            name: "PyanArchitectureTests",
            dependencies: [
				"PyanArchitecture",
				"PyanArchitectureMacros",
				.product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
			]
        ),
		.target(
			name: "PyanArchitectureSample",
			dependencies: ["PyanArchitecture"]
		)
    ]
)
