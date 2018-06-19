
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectNotifications

Log.info(message: "SWIFT PUSH SERVER")

// Create HTTP server.
let server = HTTPServer()
server.addRoutes(Routes(UIRoutesProvider().make() + APIRoutesProvider().make()))

NotificationPusher.setupAPNSConfigurations()

server.serverPort = 8090

// Where to serve static files from
server.documentRoot = "./webroot"

do {
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}

