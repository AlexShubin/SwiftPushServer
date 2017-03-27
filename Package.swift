

import PackageDescription

let package = Package(
	name: "SwiftPushServer",
	targets: [],
	dependencies: [
		.Package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", majorVersion: 2),
        .Package(url:"https://github.com/PerfectlySoft/Perfect-Notifications.git", majorVersion: 2),
        .Package(url: "https://github.com/PerfectlySoft/Perfect-Mustache.git", majorVersion: 2),
        .Package(url: "https://github.com/PerfectlySoft/Perfect-SQLite.git", majorVersion: 2),
        .Package(url: "https://github.com/PerfectlySoft/Perfect-CURL.git", majorVersion: 2),
        .Package(url: "https://github.com/PerfectlySoft/Perfect-Turnstile-SQLite.git", majorVersion: 1)
    ]
)
