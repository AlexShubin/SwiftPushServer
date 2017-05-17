//
//  Application.swift
//  PerfectTemplate
//
//  Created by Alex Shubin on 16.03.17.
//
//

import Foundation

class Application {
    
    var id: Int
    var authKey: String
    var production: Bool
    var appID: String?
    var pemPath: String?
    var authStyle: AuthStyle?
    var keyID: String?
    var teamID: String?
    var p8Path: String?
    var androidApiKey: String?
    
    enum AuthStyle:String {
        case p8 = "p8"
        case pem = "pem"
    }
    
    init() {
        self.id = Database.shared.getMaxAppID() + 1
        self.authKey = UUID().uuidString
        self.production = false
    }
    
    func mustacheRepresentation() -> [String: Any] {
        
        return [
            "id":id,
            "authKey":authKey,
            "appID":appID ?? "",
            "pemPath":pemPath ?? "",
            "keyID":keyID ?? "",
            "teamID":teamID ?? "",
            "authStyle":authStyle?.rawValue ?? "",
            "p8Path":p8Path ?? "",
            "androidApiKey":androidApiKey ?? "",
            "production": production
        ]
        
    }
    
    static func mustacheRepresentationFor(apps: [Application]) -> [[String: Any]] {
        
        return apps.map { $0.mustacheRepresentation() }
        
    }
    
}
