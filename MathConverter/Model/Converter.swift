//
//  Converter.swift
//  MathConverter
//
//  Created by Angle Qian on 2019/1/4.
//  Copyright © 2019 Angle Qian. All rights reserved.
//

import Foundation
import Cocoa
import Alamofire

func convertImage(image: NSImage){
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
            Swift.print("Lol: \(error!)")
        } else {
            let httpResponse = response as? HTTPURLResponse
            Swift.print(httpResponse!)
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
                    print("\(JSON)")
                }
        }
    }
}


extension NSImage {
    var base64String: String? {
        guard let rep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(size.width),
            pixelsHigh: Int(size.height),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .calibratedRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
            ) else {
                print("Couldn't create bitmap representation")
                return nil
        }
        
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
        draw(at: NSZeroPoint, from: NSZeroRect, operation: .sourceOver, fraction: 1.0)
        NSGraphicsContext.restoreGraphicsState()
        
        guard let data = rep.representation(using: NSBitmapImageRep.FileType.png, properties: [NSBitmapImageRep.PropertyKey.compressionFactor: 1.0]) else {
            print("Couldn't create PNG")
            return nil
        }
        
        // With prefix
        // return "data:image/png;base64,\(data.base64EncodedString(options: []))"
        // Without prefix
        return data.base64EncodedString(options: [])
    }
}

