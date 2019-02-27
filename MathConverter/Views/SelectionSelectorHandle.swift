//
//  SelectionSelectorHandle.swift
//  MathConverter
//
//  Created by Angle Qian on 2019/2/2.
//  Copyright © 2019 Angle Qian. All rights reserved.
//

import Cocoa

class SelectionSelectorHandle: NSObject {
    
    // MARK: - Properties
    
    var type: SelectorHandleType
    var selector: SelectionSelector
    /// The frame of the handle, in the coordinate system of the canvas
    var frame: NSRect = NSZeroRect
    var bounds: NSRect = NSZeroRect
    var bezierPath: NSBezierPath {
        get {
            let path = NSBezierPath(ovalIn: frame)
            path.lineWidth = CGFloat(lineWidth)
            return path
        }
    }
    var trackingArea: NSTrackingArea?
    
    // MARK: - Style properties
    
    var strokeColor: NSColor
    var fillColor: NSColor
    var size: NSSize
    var lineWidth: Float
    
    // MARK: - init()
    
    init(ofType type: SelectorHandleType, forSelector selector: SelectionSelector) {
        self.type = type
        self.selector = selector

        strokeColor = selector.currentStrokeColor
        fillColor = selector.currentFillColor
        size = NSSize(width: 10, height: 10)
        lineWidth = 1.0
    }
    
    // MARK: - draw()
    
    func draw() {
        guard selector.canResize else {
            return
        }
        
        refreshHandleFrame(withSelectorFrame: selector.frame)
        strokeColor.setStroke()
        bezierPath.stroke()
    }

    /// MARK: - Public methods

    func refreshTrackingArea() {
        if let area = trackingArea {
            selector.canvas.removeTrackingArea(area)
            trackingArea = nil
        }
        
        if (selector.isSelected && selector.canResize) {
            let trackingRect = (selector.canvas.delegate as! SelectionCanvasController).newRect(forFrame: frame)
            
            var cursor = NSCursor.arrow
            
            if (type == .topLeft || type == .bottomRight) {
                cursor = NSCursor(image: NSImage(byReferencingFile: "/System/Library/Frameworks/WebKit.framework/Versions/Current/Frameworks/WebCore.framework/Resources/northWestSouthEastResizeCursor.png")!, hotSpot: NSPoint(x: 8, y: 8))
            } else if (type == .topRight || type == .bottomLeft) {
                cursor = NSCursor(image: NSImage(byReferencingFile: "/System/Library/Frameworks/WebKit.framework/Versions/Current/Frameworks/WebCore.framework/Resources/northEastSouthWestResizeCursor.png")!, hotSpot: NSPoint(x: 8, y: 8))
            }
            
            let options = NSTrackingArea.Options.activeInKeyWindow.rawValue | NSTrackingArea.Options.mouseEnteredAndExited.rawValue
            trackingArea = NSTrackingArea(rect: trackingRect, options: NSTrackingArea.Options(rawValue: options), owner: selector.canvas, userInfo: ["Cursor": cursor, "Rect": NSStringFromRect(trackingRect), "isCanvasTrackingArea": false])
            selector.canvas.addTrackingArea(trackingArea!)
        }
    }
    
    // MARK: - Internal methods
    
    fileprivate func refreshHandleFrame(withSelectorFrame frame: NSRect) {        
        let halfWidth = size.width / 2;
        let halfHeight = size.height / 2;
        
        let minX = frame.origin.x
        let maxX = frame.origin.x + frame.size.width
        let minY = frame.origin.y
        let maxY = frame.origin.y + frame.size.height
        
        switch type {
        case .topLeft:
            self.frame = NSRect(x: minX - halfWidth, y: maxY - halfHeight, width: size.width, height: size.height)
            break
        case .topRight:
            self.frame = NSRect(x: maxX - halfWidth, y: maxY - halfHeight, width: size.width, height: size.height)
            break
        case .bottomLeft:
            self.frame = NSRect(x: minX - halfWidth, y: minY - halfHeight, width: size.width, height: size.height)
            break
        case .bottomRight:
            self.frame = NSRect(x: maxX - halfWidth, y: minY - halfHeight, width: size.width, height: size.height)
            break
        }
        
        bounds = frame
        
        refreshTrackingArea()
    }
}
