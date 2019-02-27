//
//  Converter.swift
//  MathConverter
//
//  Created by Angle Qian on 2019/1/4.
//  Copyright © 2019 Angle Qian. All rights reserved.
//

import Cocoa
import Alamofire


protocol ConverterCaller {
    func responseError(_: Error)
    func response(_: HTTPURLResponse)
    func result(_: NSDictionary)
}


func convertImage(image: NSImage, caller: ConverterCaller) {
    Swift.print("Converting")
    
    let headers = [
        "content-type": "application/json",
        "app_id": "angleqian01_gmail_com",
        "app_key": "8136893173c71992ce6e"
    ]
    let parameters = ["src": "data:image/jpeg;base64,{BASE64-STRING}"] as [String : Any]
    let postData: Data = try! JSONSerialization.data(withJSONObject: parameters, options: [])
    let request: NSMutableURLRequest = NSMutableURLRequest(url: NSURL(string: "https://api.mathpix.com/v3/latex")! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 600.0)
    let session = URLSession.shared
    let dataTask: URLSessionDataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
        if (error != nil) {
            caller.responseError(error!)
            Swift.print("DataTask request error: \(error!)")
        } else {
            let httpResponse = response as? HTTPURLResponse
            caller.response(httpResponse!)
        }
    })
    
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = headers
    request.httpBody = postData as Data
    
    dataTask.resume()
    
    if let base64string = image.base64String {
        let parameters : Parameters = [
            "src" : "data:image/png;base64," + base64string
        ]
        AF.request("https://api.mathpix.com/v3/latex",
                   method: .post,
                   parameters : parameters,
                   encoding: JSONEncoding.default,
                   headers: [
                    "app_id" : "angleqian01_gmail_com",
                    "app_key" : "8136893173c71992ce6e"
            ])
            .responseJSON{ response in
                if let JSON = response.result.value {
                    caller.result(JSON as! NSDictionary)
                }
        }
    }
}
