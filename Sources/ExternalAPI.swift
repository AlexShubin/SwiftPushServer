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
            let deviceIds = inputJSON?["ios_tokens"] as? [String],
            let registrationIDs = inputJSON?["android_reg_ids"] as? [String],
            let text = inputJSON?["message"] as? String,
            let title = inputJSON?["title"] as? String else {
                
                response.appendBody(string: "Invalid data passed")
                response.completed()
                return
                
        }
        
        guard let app = Database.shared.getApplicationBy(id: id) else {
                
                response.appendBody(string: "Wrong ID passed")
                response.completed()
                return
                
        }
        
        guard let key = request.header(.authorization),
            key == app.authKey else {
                
                response.appendBody(string: "Wrong key passed")
                response.completed()
                return
                
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
        
        let n = NotificationPusher(apnsTopic: app.appID ?? "", expiration: .immediate, priority: .immediate)
        
        var items:[APNSNotificationItem] = [.alertBody(text), .sound("default"), .alertTitle(title)]
        
        if let imageURL = inputJSON?["imageURL"] as? String {
            items.append(.alertLaunchImage(imageURL))
        }
        if let badge = inputJSON?["badge"] as? Int {
            items.append(.badge(badge))
        }
        
       n.pushAPNS(
            configurationName: app.appID ?? "",
            deviceTokens: deviceIds,
            notificationItems: items)
        {
            responses in
            
            ApiResponse["ios_response"] = NotificationResponse.responsesToJson(responses: responses, deviceIDs: deviceIds)
            
            dispatchGroup.leave()
            
        }
        
        /////////////////
        //Pushing to GCM
        /////////////////
        
        var msg: [String:Any] = [
            "message" 	: text,
            "title"		: title
            //    "subtitle"	: "This is a subtitle. subtitle",
            //    "tickerText": "Ticker text here...Ticker text here...Ticker text here",
            //    "vibrate"	: 1,
            //    "sound"		: 1,
            //    "smallIcon"	: "small_icon"
        ]
        
        if let imageURL = inputJSON?["imageURL"] as? String {
            msg["largeIcon"] = imageURL
        }
        if let badge = inputJSON?["badge"] as? Int {
            msg["badge"] = badge
        }
        
        AndroidPushSender.send(androidApiKey: app.androidApiKey ?? "",
                               message: msg,
                               to: registrationIDs) {
            androidResponse in
            
            ApiResponse["android_response"] = androidResponse
            
            dispatchGroup.leave()
                                
        }
    }
    
}









