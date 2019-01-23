//
//  Image.swift
//  MathConverter
//
//  Created by Angle Qian on 2019/1/6.
//  Copyright © 2019 Angle Qian. All rights reserved.
//

import Cocoa

class Image {
    var image: NSImage?
    var filename: String
    
    init(fileURL: URL) throws {
        image = NSImage(contentsOf: fileURL)
        if image != nil {
            filename = fileURL.lastPathComponent
        } else {
            throw ImageError.imageImportError(fileURL.absoluteString)
        }
    }
    
    func getNSImage() -> NSImage? {
        return image
    }
}
