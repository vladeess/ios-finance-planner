// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FinancePlanner",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "FinancePlanner", targets: ["FinancePlanner"])
    ],
    targets: [
        .target(
            name: "FinancePlanner",
            path: "FinancePlanner",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
