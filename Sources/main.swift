
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

import StORM
import SQLiteStORM
import PerfectTurnstileSQLite
import TurnstilePerfect
import PerfectNotifications

//////////Constants//////////

let allowRegistration = true

/////////////////////////////

Log.info(message: "SWIFT PUSH SERVER")

// Used later in script for the Realm and how the user authenticates.
let pturnstile = TurnstilePerfectRealm()
SQLiteConnector.db = Database.dbPath

// Set up the Authentication table
let auth = AuthAccount()
try? auth.setup()

// Connect the AccessTokenStore
tokenStore = AccessTokenStore()
try? tokenStore?.setup()

// Create HTTP server.
let server = HTTPServer()

server.addRoutes(ServerRoutes.makeRoutes())

NotificationPusher.setupAPNSConfigurations()

var authenticationConfig = AuthenticationConfig()
authenticationConfig.include("/*")

authenticationConfig.exclude("/login")
authenticationConfig.exclude("/register")
authenticationConfig.exclude("/")
authenticationConfig.exclude("/styles/style.css")

authenticationConfig.exclude("/send_notification")

let authFilter = AuthFilter(authenticationConfig)

// Note that order matters when the filters are of the same priority level
server.setRequestFilters([pturnstile.requestFilter])
server.setResponseFilters([pturnstile.responseFilter])

server.setRequestFilters([(authFilter, .high)])

server.serverPort = 8090

// Where to serve static files from
server.documentRoot = "./webroot"

do {
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}

