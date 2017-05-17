//
//  ServerRoutes.swift
//  PerfectTemplate
//
//  Created by Alex Shubin on 16.03.17.
//
//

import Foundation
import PerfectHTTP
import PerfectNotifications
import PerfectLib
import PerfectHTTPServer
import PerfectTurnstileSQLite

public class ServerRoutes {
    
    open static func makeRoutes() -> Routes {
        
        var routes = Routes()
        
        routes.add(method:.get, uri:"/", handler: main)
        routes.add(method:.get, uri:"/index", handler: indexHandler)
        
        // Auth //
        routes.add(method: .get, uri: "/login", handler: AuthHandlersWeb.loginHandlerGET)
        routes.add(method: .post, uri: "/login", handler: AuthHandlersWeb.loginHandlerPOST)
        if allowRegistration {
            routes.add(method: .get, uri: "/register", handler: AuthHandlersWeb.registerHandlerGET)
            routes.add(method: .post, uri: "/register", handler: AuthHandlersWeb.registerHandlerPOST)
        } else {
            routes.add(method: .get, uri: "/register", handler: { request, response in
                response.appendBody(string: "Registration is not allowed")
                response.completed()
            })
            routes.add(method: .get, uri: "/register", handler: { request, response in
                response.appendBody(string: "Registration is not allowed")
                response.completed()
            })
        }
        routes.add(method: .post, uri: "/logout", handler: AuthHandlersWeb.logoutHandler)
        //
        
        // internal post //
        routes.add(method:.post, uri:"/send", handler:sendHandler)
        routes.add(method:.post, uri:"/generate_notification", handler:generateNotificationHandler)
        routes.add(method:.post, uri:"/new_application", handler:newApplicationHandler)
        routes.add(method:.post, uri:"/edit_application", handler:editApplicationHandler)
        routes.add(method:.post, uri:"/save_application", handler:saveApplicationHandler)
        routes.add(method:.post, uri:"/delete_application", handler:deleteApplicationHandler)
        //
        
        // For external API
        routes.add(method:.post, uri:"/send_notification", handler:ExternalAPI.sendNotificationHandler)
        //
        
        return routes
    }
    
    private static func getContext(_ request: HTTPRequest) -> [String: Any] {
        return [
            "accountID": request.user.authDetails?.account.uniqueID ?? "",
            "authenticated": request.user.authenticated
        ]
    }
    
    open static func main(request: HTTPRequest, _ response: HTTPResponse) {
        
        if request.user.authenticated {
            response.redirect(path: "/index")
        } else {
            response.redirect(path: "/login")
        }
        
    }
    
    open static func indexHandler(request: HTTPRequest, _ response: HTTPResponse) {
        
        var context = getContext(request)
        
        let apps = Database.shared.getAllApps()
        let mApps = Application.mustacheRepresentationFor(apps: apps)
        
        context["apps"] = mApps
        
        response.render(template: "/index", context: context)
        
    }
    
    
    open static func newApplicationHandler(request: HTTPRequest, _ response: HTTPResponse) {
        
        let context = getContext(request)
        
        response.render(template: "/edit_application", context: context)
        
    }
    
    open static func editApplicationHandler(request: HTTPRequest, _ response: HTTPResponse) {
        
        if let id = request.param(name: "id"),
            let app = Database.shared.getApplicationBy(id: id) {
        
            var context = getContext(request)
            context += app.mustacheRepresentation()
            context["pemBool"] = (app.authStyle == .pem)
            context["p8Bool"] = (app.authStyle == .p8)
   
            response.render(template: "/edit_application", context: context)
            
        }
    }
    
    open static func saveApplicationHandler(request: HTTPRequest, _ response: HTTPResponse) {
        
        if let uploads = request.postFileUploads,
            uploads.count > 0 {
            
            var app: Application
            
            if let idUpload = uploads.first(where: { $0.fieldName == "id"}),
                !idUpload.fieldValue.isEmpty {
                
                app = Database.shared.getApplicationBy(id: idUpload.fieldValue)!
                
            } else {
                app = Application()
            }
            
            let fileDir = Dir(Dir.workingDir.path + "files")
            do {
                try fileDir.create()
            } catch {
                fatalError("\(error)")
            }
            
            app.production = false
            
            for upload in uploads {
                
                switch upload.fieldName {
                case "pemFile":
                    if !upload.tmpFileName.isEmpty {
                        if let path = app.pemPath, !path.isEmpty {
                            File(path).delete()
                        }
                        let thisFile = File(upload.tmpFileName)
                        do {
                            let serverFile = try thisFile.moveTo(path: fileDir.path + UUID().string + ".pem", overWrite: true)
                            app.pemPath = serverFile.realPath
                        } catch {
                            print(error)
                        }
                    }
                case "p8File":
                    if !upload.tmpFileName.isEmpty {
                        if let path = app.p8Path, !path.isEmpty {
                            File(path).delete()
                        }
                        let thisFile = File(upload.tmpFileName)
                        do {
                            let serverFile = try thisFile.moveTo(path: fileDir.path + UUID().string + ".p8", overWrite: true)
                            app.p8Path = serverFile.realPath
                        } catch {
                            print(error)
                        }
                    }
                case "appID":
                    app.appID = upload.fieldValue
                case "teamID":
                    app.teamID = upload.fieldValue
                case "keyID":
                    app.keyID = upload.fieldValue
                case "authorization":
                    app.authStyle = Application.AuthStyle(rawValue: upload.fieldValue)
                case "androidApiKey":
                    app.androidApiKey = upload.fieldValue
                case "production":
                    app.production = true
                default:
                    break
                }
            }
            
            Database.shared.insertOrReplace(application: app)
            
            NotificationPusher.setupAPNSConfiguration(for: app)
            
        }
        
        response.redirect(path: "/index")
        
    }
    
    static func generateNotificationHandler(request: HTTPRequest, _ response: HTTPResponse) {
        
        if let id = request.param(name: "id") {
            
            var context = getContext(request)
            
            context["id"] = id
            
            response.render(template: "/generate_notification", context: context)
        }
        
    }
    
    static func deleteApplicationHandler(request: HTTPRequest, _ response: HTTPResponse) {
        
        if let id = request.param(name: "id") {
            
            Database.shared.deleteApplicationBy(id: id)
            
            response.redirect(path: "/index")
        }
    }
    
    static func sendHandler(request: HTTPRequest, _ response: HTTPResponse) {
        
        guard let text = request.param(name: "text"),
            let id = request.param(name: "id"),
            let tokens = request.param(name: "tokens"),
            let registrationIDs = request.param(name: "registrationIDs"),
            let title = request.param(name: "title")
            else {
                
                response.appendBody(string: "Invalid data passed")
                response.completed()
                return
                
        }
        
        let app = Database.shared.getApplicationBy(id: id)!
        
        let json:[String:Any] = [
            "app_id": id,
            "ios_tokens": tokens.components(separatedBy: ",").filter {!$0.isEmpty},
            "android_reg_ids": registrationIDs.components(separatedBy: ",").filter {!$0.isEmpty},
            "title": title,
            "message": text
        ]
        
        let header = "Authorization: "+app.authKey+"\nContent-Type: application/json"
        let body = try! json.jsonEncodedString()
        
        print("==================================")
        print("test POST request to external API:")
        print("==================================")
        print(header)
        print(body)
        print("==================================")
        
        CurlHTTPRequest.post(url: "localhost:\(server.serverPort)/send_notification",
        header: header, body: body) { selfResponse in

            var context = getContext(request)
            context["response"] = selfResponse
    
            response.render(template: "/response", context: context)
        }
    }
    
}
