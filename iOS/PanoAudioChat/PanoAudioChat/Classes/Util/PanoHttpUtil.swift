//
//  PanoHttpUtil.swift
//  PanoAudioRoom
//
//  Created by wenhua.zhang on 2020/10/28.
//

import Foundation

open class PanoHttpUtil: NSObject {
    
    public enum PanoHttpMethod : String {
        case post = "POST"
        case get = "GET"
    }
    
    open class func Request(_ urlString: String, method: PanoHttpMethod? = .post, paramters: [String: Any]? = nil, headers: [String:String]? = nil, completionHandler: ((_ res: String, _ err: Error?) -> Void)? = nil) {
        guard let url = URL(string: urlString) else { return }
        var req = URLRequest(url: url)
        req.setValue(NSUUID().uuidString, forHTTPHeaderField: "Tracking-Id")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        req.setValue("Keep-Alive", forHTTPHeaderField: "Connection")
        req.httpMethod = "POST"
        if let httpMethod = method {
            req.httpMethod = httpMethod.rawValue
        }
        req.timeoutInterval = 60
        if paramters != nil {
            let data =  try! JSONSerialization.data(withJSONObject: paramters!, options: JSONSerialization.WritingOptions(rawValue: 0))
            req.httpBody = data
        }
        
        URLSession.shared.dataTask(with: req) { (data , response, err) in
            if let resp = response as? HTTPURLResponse {
                var result = ""
                if resp.statusCode == 200 && err == nil && (data != nil){
                    result = String(data: data!, encoding: .utf8) ?? ""
                }
                DispatchQueue.main.async {
                    if completionHandler != nil {
                        completionHandler!(result, err)
                    }
                }
            }
        }.resume()
    }
}


