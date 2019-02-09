//
//  SelectionCanvas.swift
//  MathConverter
//
//  Created by Angle Qian on 2019/2/1.
//  Copyright © 2019 Angle Qian. All rights reserved.
//

import Cocoa


protocol SelectionCanvasDelegate: AnyObject {

}


class SelectionCanvas: NSView {
    
    weak var delegate: SelectionCanvasDelegate?
    var trackingArea: NSTrackingArea?
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        wantsLayer = true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        refreshTrackingArea()
        
        guard let _delegate = delegate else {
            return
        }
        
        for selector in (_delegate as! SelectionCanvasController).selectors {
            selector.draw()
        }

        if let selector = (_delegate as! SelectionCanvasController).currentSelector {
            if selector.isPicker {
                selector.draw()
            }
        }
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }

    func refreshTrackingArea() {
        if let area = trackingArea {
            removeTrackingArea(area)
            trackingArea = nil
        }
        
        let cursor = NSCursor.crosshair
        
        let options = NSTrackingArea.Options.activeInKeyWindow.rawValue | NSTrackingArea.Options.mouseEnteredAndExited.rawValue
        
        trackingArea = NSTrackingArea(rect: frame, options: NSTrackingArea.Options(rawValue: options), owner: self, userInfo: ["Cursor": cursor, "Rect": NSStringFromRect(frame), "isCanvasTrackingArea": true])
        addTrackingArea(trackingArea!)
    }
}
