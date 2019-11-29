//
//  AndroidPushSender.swift
//  PerfectTemplate
//
//  Created by Alex Shubin on 20.03.17.
//

import cURL
import PerfectCURL

protocol AndroidPushSender {
    func send(androidApiKey: String,
              message: [String:Any],
              to registrationIDs: [String],
              timeToLive: Int,
              callback: @escaping ([String: Any]) -> Void)
}

struct DefaultAndroidPushSender: AndroidPushSender {
    
    func send(androidApiKey: String,
              message: [String:Any],
              to registrationIDs: [String],
              timeToLive: Int,
              callback: @escaping ([String: Any]) -> Void) {

        let fields: [String:Any] = [
            "registration_ids" : registrationIDs,
            "time_to_live": timeToLive,
            "data" : message
            ]
        
        let jsonToSend = try! fields.jsonEncodedString().utf8
        
        print("Performing request to GCM with json:")
        print(jsonToSend)
        
        let byteArray:[UInt8] = Array(jsonToSend)
        
        let pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: byteArray.count)
        pointer.initialize(from: byteArray, count: byteArray.count)
        
        let curlObject = CURL(url: "https://android.googleapis.com/gcm/send")
        curlObject.setOption(CURLOPT_POST, int: 1)
        curlObject.setOption(CURLOPT_HTTPHEADER, s: "Authorization: key="+androidApiKey+"\nContent-Type: application/json")
        curlObject.setOption(CURLOPT_SSL_VERIFYPEER, int: 0)
        curlObject.setOption(CURLOPT_POSTFIELDS, v: pointer)
        curlObject.setOption(CURLOPT_POSTFIELDSIZE, int: byteArray.count)
        
        curlObject.perform { (code, header, body) in
            
            curlObject.close()
            
            var result: [String:Any] = ["code": code, "header": String(bytes: header, encoding: .utf8) ?? ""]
            
            if let respStr = String(bytes: body, encoding: .utf8),
                var respJson = try? respStr.jsonDecode() as? [String:Any] {
                
                if var results = respJson["results"] as? [[String:Any]] {
                    for i in 0..<results.count {
                        results[i]["registration_id"] = registrationIDs[i]
                    }
                    respJson["results"] = results
                }
                result["body"] = respJson
            }
            callback(result)
        }
    }
}
