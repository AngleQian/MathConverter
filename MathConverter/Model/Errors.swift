//
//  Errors.swift
//  MathConverter
//
//  Created by Angle Qian on 2019/1/6.
//  Copyright © 2019 Angle Qian. All rights reserved.
//

import Foundation


enum ImageError: Error {
    case imageImportError(String)
}


enum ConversionError: Error {
    
}


enum DocumentError: Error {
    case deserializationError(String)
    case serializationError(String)
}
