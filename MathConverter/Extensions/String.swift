//
//  File.swift
//  MathConverter
//
//  Created by Angle Qian on 2019/2/26.
//  Copyright © 2019 Angle Qian. All rights reserved.
//

import Cocoa


extension String {
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
