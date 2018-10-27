// swift-tools-version:4.2

import PackageDescription

let package =
    Package(name: "SwiftPushServer",
            products: [
                .executable(name: "SwiftPushServer", targets: ["SwiftPushServer"])
        ],
            dependencies: [
                .package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", from: "3.0.0"),
                .package(url:"https://github.com/PerfectlySoft/Perfect-Notifications.git", from: "3.0.0"),
                .package(url: "https://github.com/PerfectlySoft/Perfect-Mustache.git", from: "3.0.0"),
                .package(url: "https://github.com/PerfectlySoft/Perfect-SQLite.git", from: "3.0.0"),
                .package(url: "https://github.com/PerfectlySoft/Perfect-CURL.git", from: "3.0.0")
        ],
            targets: [
                .target(
                    name: "SwiftPushServer",
                    dependencies: ["PerfectHTTPServer", "PerfectNotifications", "PerfectMustache", "PerfectSQLite", "PerfectCURL"],
                    path: "./Sources"),
                ]
)
