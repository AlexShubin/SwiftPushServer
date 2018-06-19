//
//  File.swift
//  SwiftPushServer
//
//  Created by Alex Shubin on 23.03.17.
//
//

import PerfectHTTP
import PerfectNotifications
import PerfectLib
import PerfectHTTPServer


extension NotificationResponse {
    
    static func responsesToJson(responses: [NotificationResponse], deviceIDs: [String]) -> [[String:Any]] {
        
        assert(responses.count == deviceIDs.count)
        
        var result = [[String:Any]]()
        
        for i in 0..<responses.count {
            result.append(responses[i].toJson(deviceID: deviceIDs[i]))
        }
        
        return result
        
    }
    
    func toJson(deviceID: String? = nil) -> [String:Any] {
        
        var json = [String: Any]()
        
        json["code"] = self.status.code
        json["status"] = self.status.description
        json["body"] = self.jsonObjectBody
        json["token"] = deviceID
        
        return json
        
    }
    
}
