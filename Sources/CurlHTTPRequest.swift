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
    
    public static func jsonPOST(url: String, header: String, json: [String:Any]) -> String {
        
        let byteArray:[UInt8] = try! Array(json.jsonEncodedString().utf8)
        
        let pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: byteArray.count)
        pointer.initialize(from: byteArray, count: byteArray.count)
        
        let curlObject = CURL(url: url)
        curlObject.setOption(CURLOPT_POST, int: 1)
        curlObject.setOption(CURLOPT_HTTPHEADER, s: header)
        curlObject.setOption(CURLOPT_SSL_VERIFYPEER, int: 0)
        curlObject.setOption(CURLOPT_POSTFIELDS, v: pointer)
        curlObject.setOption(CURLOPT_POSTFIELDSIZE, int: byteArray.count)
        
        let perf = curlObject.performFully()
        
        curlObject.close()
        
        return String(bytes: perf.2, encoding: .utf8) ?? ""
    }
}
