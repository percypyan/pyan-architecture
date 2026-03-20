// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PyanArchitecture",
	platforms: [
		.iOS(.v18),
		.macOS(.v15),
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
		.package(url: "https://github.com/percypyan/pyan-inject.git", .upToNextMajor(from: "0.1.0")),
		.package(url: "https://github.com/percypyan/pyan-router.git", .upToNextMajor(from: "0.1.0")),
		.package(url: "https://github.com/percypyan/pyan-logging.git", .upToNextMajor(from: "0.2.0")),
		.package(url: "https://github.com/percypyan/pyan-feature-switcher.git", .upToNextMajor(from: "0.2.0")),
		.package(url: "https://github.com/percypyan/pyan-testing.git", .upToNextMajor(from: "0.1.1")),
	],
    targets: [
        .target(
            name: "PyanArchitecture",
			dependencies: [
				.product(name: "PyanInject", package: "pyan-inject"),
				.product(name: "PyanRouter", package: "pyan-router"),
				.product(name: "PyanLogging", package: "pyan-logging"),
				.product(name: "PyanFeatureSwitcher", package: "pyan-feature-switcher"),
				.product(name: "PyanMocking", package: "pyan-testing"),
			]
        ),
        .testTarget(
            name: "PyanArchitectureTests",
            dependencies: ["PyanArchitecture"]
        ),
		.target(
			name: "PyanArchitectureSample",
			dependencies: ["PyanArchitecture"]
		)
    ]
)
