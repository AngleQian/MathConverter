//
//  ImageSelection.swift
//  MathConverter
//
//  Created by Angle Qian on 2019/1/23.
//  Copyright © 2019 Angle Qian. All rights reserved.
//

import Cocoa


class ImageSelection {

    var selectionRect: NSRect
    var isConverted = false
    var latex = ""
    
    init(_ selectionRect: NSRect) {
        self.selectionRect = selectionRect
    }
}
