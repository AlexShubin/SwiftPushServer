//
//  NotificationPusher+Extensions.swift
//  SwiftPushServer
//
//  Created by Alex Shubin on 24.03.17.
//
//

import PerfectNotifications

extension NotificationPusher {
    
    static func setupAPNSConfigurations() {
        
        let apps = Database.shared.getAllApps()
        
        for app in apps {
            
            setupAPNSConfiguration(for: app)
            
        }
    }
    
    static func setupAPNSConfiguration(for app: Application) {
        
        guard let authStyle = app.authStyle else {
            return
        }
        
        switch authStyle {
        case .pem:
            
            if let appID = app.appID,
                let pemPath = app.pemPath {
                
                addConfigurationAPNS(
                    name: appID,
                    production: app.production,
                    certificatePath: pemPath)
                
            }
            
        case .p8:
            
            if let appID = app.appID,
                let p8Path = app.p8Path,
                let keyID = app.keyID,
                let teamID = app.teamID {
                
                addConfigurationAPNS(
                    name: appID,
                    production: app.production,
                    keyId: keyID,
                    teamId: teamID,
                    privateKeyPath: p8Path)
            }
            
        }
    }
    
}
