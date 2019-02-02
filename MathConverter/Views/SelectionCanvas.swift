//
//  SelectionCanvas.swift
//  MathConverter
//
//  Created by Angle Qian on 2019/2/1.
//  Copyright © 2019 Angle Qian. All rights reserved.
//

import Cocoa


class SelectionCanvas: NSView {
    
    var startPoint : NSPoint!
    var shapeLayer : CAShapeLayer!
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        wantsLayer = true
        layer?.backgroundColor = NSColor(red: 0, green: 0, blue: 0.5, alpha: 0.5).cgColor
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }

}
