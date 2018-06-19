//
//  ExternalAPI.swift
//  SwiftPushServer
//
//  Created by Alex Shubin on 21.03.17.
//
//

import PerfectHTTP
import PerfectNotifications
import PerfectLib
import PerfectHTTPServer

class ExternalAPI {
    
    static func sendNotificationHandler(request: HTTPRequest, _ response: HTTPResponse) {
        
        let params = request.params()
        
        guard params.count > 0,
            let inputJSON = try? params[0].0.jsonDecode() as? [String:Any],
            let id = inputJSON?["app_id"] as? String,
            let text = inputJSON?["message"] as? String,
            let title = inputJSON?["title"] as? String else {
                
                response.appendBody(string: "Invalid data passed: app_id, message, title - should be there")
                response.completed()
                return
        }
        
        var iosTokens = [String]()
        var androidRegIDs = [String]()
        
        if let tokens = inputJSON?["ios_tokens"] as? [String] {
            iosTokens = tokens
        }
        if let regIDs = inputJSON?["android_reg_ids"] as? [String] {
            androidRegIDs = regIDs
        }
        
        guard iosTokens.count + androidRegIDs.count > 0 else {
            response.appendBody(string: "No tokens to send passed")
            response.completed()
            return
        }
        
        guard let app = Database.shared.getApplicationBy(id: id) else {
            response.appendBody(string: "Wrong ID passed")
            response.completed()
            return
        }
        
        guard let key = request.header(.authorization), key == app.authKey else {
            response.appendBody(string: "Wrong auth key passed in header")
            response.completed()
            return
        }
        
        var secondsToLive = 60*60*24*7*4 // 4 weeks by default
        if let timeToLive = inputJSON?["time_to_live"] as? Int,
            1..<secondsToLive ~= timeToLive {
            secondsToLive = timeToLive
        }
        
        var ApiResponse = [String:Any]()
        
        let dispatchGroup = DispatchGroupImitation() {
            response.appendBody(string: try! ApiResponse.jsonEncodedString())
            response.completed()
        }
        dispatchGroup.enter() // enter for apns
        dispatchGroup.enter() // enter for gcm
        
        /////////////////
        //Pushing to APNS
        /////////////////
        
        if let appID = app.appID,
            appID.count > 0,
            iosTokens.count > 0 {
            
            let n = NotificationPusher(apnsTopic: appID, expiration: .relative(secondsToLive), priority: .immediate, collapseId: nil)
            
            let items:[APNSNotificationItem] = [
                .alertBody(text),
                .sound("default"),
                .alertTitle(title),
                .contentAvailable
            ]
            
            n.pushAPNS(
                configurationName: app.appID ?? "",
                deviceTokens: iosTokens,
                notificationItems: items)
            {
                responses in
                
                ApiResponse["ios_response"] = NotificationResponse.responsesToJson(responses: responses, deviceIDs: iosTokens)
                dispatchGroup.leave()
            }
        } else {
            dispatchGroup.leave()
        }
        
        /////////////////
        //Pushing to GCM
        /////////////////
        
        if let androidApiKey = app.androidApiKey,
            androidApiKey.count > 0,
            androidRegIDs.count > 0 {
            
            let msg: [String:Any] = [
                "message" 	: text,
                "title"		: title
            ]
            
            AndroidPushSender.send(androidApiKey: androidApiKey,
                                   message: msg,
                                   to: androidRegIDs,
                                   timeToLive: secondsToLive) {
                                    androidResponse in
                                    
                                    ApiResponse["android_response"] = androidResponse
                                    dispatchGroup.leave()
            }
        } else {
            dispatchGroup.leave()
        }
    }
    
}









