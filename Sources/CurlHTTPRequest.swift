//
//  CurlHTTPRequest.swift
//  SwiftPushServer
//
//  Created by Alex Shubin on 21.03.17.
//
//

import cURL
import PerfectCURL

public class CurlHTTPRequest {
    
    public static func post(url: String, header: String, body: String, callback: @escaping (String)->Void) {
        
        let byteArray:[UInt8] = Array(body.utf8)
        
        let pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: byteArray.count)
        pointer.initialize(from: byteArray, count: byteArray.count)
        
        let curlObject = CURL(url: url)
        curlObject.setOption(CURLOPT_POST, int: 1)
        curlObject.setOption(CURLOPT_HTTPHEADER, s: header)
        curlObject.setOption(CURLOPT_SSL_VERIFYPEER, int: 0)
        curlObject.setOption(CURLOPT_POSTFIELDS, v: pointer)
        curlObject.setOption(CURLOPT_POSTFIELDSIZE, int: byteArray.count)
        
        curlObject.perform { (code, header, body) in
        
            curlObject.close()
        
            callback("Code: \(code)\n Header: \(String(bytes: header, encoding: .utf8) ?? "")\n Body: \(String(bytes: body, encoding: .utf8) ?? "")")
            
        }
    }
}
