//
//  SelectionSelector.swift
//  MathConverter
//
//  Created by Angle Qian on 2019/2/2.
//  Copyright © 2019 Angle Qian. All rights reserved.
//

import Cocoa


class SelectionSelector {
    
    // MARK: - Properties
    
    /// A picker selector is used to select/collect existing selectors, making them selected. A non-picker selector selects the parts of the image to be converted.
    var isPicker: Bool
    /// The canvas on which the selector will be drawn
    var canvas: SelectionCanvas
    /// The frame of the selector, in the coordinate system of the canvas.
    var frame: NSRect {
        didSet {
            refreshTrackingArea()
        }
    }
    var isSelected: Bool {
        didSet {
            refreshTrackingArea()
        }
    }
    var canResize: Bool {
        return resultStatus == .notConverted
    }
    var canMove: Bool {
        return resultStatus == .notConverted
    }
    var currentAction: SelectorActionStatus
    var handles: [SelectionSelectorHandle]
    var currentHandle: SelectionSelectorHandle?
    var bezierPath: NSBezierPath {
        let path = NSBezierPath(rect: frame)
        let lineWidth = isSelected ? lineWidthSelected : lineWidthUnselected
        path.lineWidth = lineWidth
        let lineDash = ((isSelected && isLineDashedSelected) || (!isSelected && isLineDashedUnselected)) && !isPicker
        if lineDash {
            let dash_pattern: [CGFloat] = [5.0]
            path.setLineDash(dash_pattern, count: 1, phase: 0)
        }
        return path
    }
    var trackingArea: NSTrackingArea?
    var resultStatus: SelectionResultStatus {
        didSet {
            refreshTrackingArea()
        }
    }
    
    // MARK: - Style properties
    
    var currentStrokeColor: NSColor {
        if isPicker {
            return Color.gray
        } else {
            switch resultStatus {
            case .notConverted:
                return Color.blue
            case .converted:
                return Color.green
            case .error:
                return Color.red
            case .pending:
                return Color.yellow
            }
        }
    }
    
    var currentFillColor: NSColor {
        if isPicker {
            return Color.lightGray
        } else {
            switch resultStatus {
            case .notConverted:
                return Color.lightBlue
            case .converted:
                return Color.lightGreen
            case .error:
                return Color.lightRed
            case .pending:
                return Color.lightYellow
            }
        }
    }
    
    var minHeight, minWidth: CGFloat
    
    var lineWidthPicker: CGFloat
    
    var lineWidthUnselected: CGFloat
    var lineWidthSelected: CGFloat
    
    var isLineDashedUnselected: Bool
    var isLineDashedSelected: Bool
    
    // MARK: - init()
    
    init(asPicker picker: Bool, forCanvas canvas: SelectionCanvas, withFrame frame: NSRect, withStatus status: SelectionResultStatus?) {
        self.isPicker = picker
        self.canvas = canvas
        self.frame = frame
        isSelected = false
        
        currentAction = .initialize
        resultStatus = status ?? .notConverted
        
        minWidth = 30
        minHeight = 30
        lineWidthPicker = 1
        lineWidthSelected = 1.5
        lineWidthUnselected = 1
        isLineDashedUnselected = true
        isLineDashedSelected = false
        
        handles = [SelectionSelectorHandle]()
        handles.append(SelectionSelectorHandle(ofType: .topLeft, forSelector: self))
        handles.append(SelectionSelectorHandle(ofType: .topRight, forSelector: self))
        handles.append(SelectionSelectorHandle(ofType: .bottomLeft, forSelector: self))
        handles.append(SelectionSelectorHandle(ofType: .bottomRight, forSelector: self))
        
        currentHandle = handles[2]
    }
    
    // MARK: - draw()
    
    func draw() {
        currentStrokeColor.setStroke()
        bezierPath.stroke()
        currentFillColor.setFill()
        bezierPath.fill()

        drawHandles()
        refreshTrackingArea()
    }
    
    // MARK: - Public methods
    
    func isIntersecting(forPoint point: NSPoint) -> Bool {
        // isTouchingHandle() must be called. If order is switched, it might not be called due to short-circuit evaluation
        return isTouchingHandle(forPoint: point) || frame.contains(point)
    }
    
    func isIntersecting(forRect rect: NSRect) -> Bool {
        // isTouchingHandle() must be called. If order is switched, it might not be called due to short-circuit evaluation
        return isTouchingHandle(forRect: rect) || frame.intersects(rect)
    }
    
    func isTouchingHandle(forPoint point: NSPoint) -> Bool {
        for handle in handles {
            if handle.frame.contains(point) {
                currentHandle = handle
                prepare(forAction: .resize)
                return true
            }
        }
        prepare(forAction: .move)
        return false
    }
    
    func isTouchingHandle(forRect rect: NSRect) -> Bool {
        for handle in handles {
            if handle.frame.intersects(rect) {
                return true
            }
        }
        return false
    }
    
    func restoreOrigin() {
        frame = (canvas.delegate as! SelectionCanvasController).newRect(forFrame: frame)
    }
    
    func resize(toPoint point: NSPoint) {
        guard canResize else {
            return
        }
        
        let origin = frame.origin
        let size = frame.size
        let maxX = origin.x + size.width
        let maxY = origin.y + size.height
        var newRect = NSZeroRect
        
        if currentAction == .initialize {
            let _point = initializeClamping(forPoint: point)
            
            newRect = NSRect(x: _point.x, y: _point.y, width: size.width - _point.x + origin.x, height: size.height - _point.y + origin.y)
            
        } else if currentAction == .resize {
            guard let handle = currentHandle else {
                return
            }
            
            let _point = resizeClamping(forPoint: point)
            
            switch handle.type {
            case .topLeft:
                newRect = NSRect(x: _point.x, y: origin.y, width: size.width - _point.x + origin.x, height: size.height + _point.y - maxY)
            case .topRight:
                newRect = NSRect(x: origin.x, y: origin.y, width: size.width + _point.x - maxX, height: size.height + _point.y - maxY)
            case .bottomLeft:
                newRect = NSRect(x: _point.x, y: _point.y, width: size.width - _point.x + origin.x, height: size.height - _point.y + origin.y)
            case .bottomRight:
                newRect = NSRect(x: origin.x, y: _point.y, width: size.width + _point.x - maxX, height: size.height - _point.y + origin.y)
            }
        }
        
        frame = newRect
    }
    
    var oldFrameOrigin = NSZeroPoint
    
    func move(toPoint point: NSPoint, relativeTo relative: NSPoint) {
        guard canResize else {
            return
        }
        
        let _point = moveClamping(forPoint: point, relativeTo: relative)
        let vector = CGVector(dx: _point.x - relative.x, dy: _point.y - relative.y)
        
        frame = NSRect(x: oldFrameOrigin.x + vector.dx, y: oldFrameOrigin.y + vector.dy, width: frame.size.width, height: frame.size.height)
    }
    
    func removeTrackingAreas() {
        for handle in handles {
            if let area = handle.trackingArea {
                canvas.removeTrackingArea(area)
            }
        }
        if let area = trackingArea {
            canvas.removeTrackingArea(area)
        }
    }
    
    func canDropOnCanvas() -> Bool {
        if abs(frame.size.width) < minWidth || abs(frame.size.height) < minHeight {
            return false
        }
        restoreOrigin()
        return true
    }
        
    // MARK: - Internal methods
        
    fileprivate func drawHandles() {
        if (isSelected && !isPicker) {
            for handle in handles {
                handle.draw()
            }
        }
    }
    
    fileprivate func initializeClamping(forPoint point: NSPoint) -> NSPoint {
        return outsideCanvasClamping(forPoint: point)
    }
    
    fileprivate func resizeClamping(forPoint point: NSPoint) -> NSPoint {
        return outsideCanvasClamping(forPoint: point)
    }
    
    fileprivate func moveClamping(forPoint point: NSPoint, relativeTo relative: NSPoint) -> NSPoint {
        let leftOffset = relative.x - oldFrameOrigin.x
        let rightOffset = oldFrameOrigin.x + frame.size.width - relative.x
        let topOffset = oldFrameOrigin.y + frame.size.height - relative.y
        let bottomOffset = relative.y - oldFrameOrigin.y
        
        var newPoint = point
        
        if point.x < (canvas.bounds.origin.x + leftOffset) {
            newPoint.x = canvas.bounds.origin.x + leftOffset
        } else if point.x > (canvas.bounds.origin.x + canvas.bounds.size.width - rightOffset) {
            newPoint.x = canvas.bounds.origin.x + canvas.bounds.size.width - rightOffset
        }
        if point.y < (canvas.bounds.origin.y + bottomOffset) {
            newPoint.y = canvas.bounds.origin.y + bottomOffset
        } else if point.y > (canvas.bounds.origin.y + canvas.bounds.size.height - topOffset) {
            newPoint.y = canvas.bounds.origin.y + canvas.bounds.size.height - topOffset
        }
        
        return newPoint
    }
    
    fileprivate func outsideCanvasClamping(forPoint point: NSPoint) -> NSPoint {
        var newPoint = point
        
        if point.x < canvas.bounds.origin.x {
            newPoint.x = canvas.bounds.origin.x
        } else if point.x > (canvas.bounds.origin.x + canvas.bounds.size.width) {
            newPoint.x = canvas.bounds.origin.x + canvas.bounds.size.width
        }
        if point.y < canvas.bounds.origin.y {
            newPoint.y = canvas.bounds.origin.y
        } else if point.y > (canvas.bounds.origin.y + canvas.bounds.size.height) {
            newPoint.y = canvas.bounds.origin.y + canvas.bounds.size.height
        }
        
        return newPoint
    }
    
    fileprivate func prepare(forAction action: SelectorActionStatus) {
        currentAction = action
    
        if action == .move {
            oldFrameOrigin = frame.origin
        }
    }
    
    fileprivate func refreshTrackingArea() {
        if let area = trackingArea {
            canvas.removeTrackingArea(area)
            trackingArea = nil
        }
        
        if isSelected {
            if canMove {
                var trackingRect = (canvas.delegate as! SelectionCanvasController).newRect(forFrame: frame)
                
                let handle = handles.first!
                let handleWidth = handle.frame.size.width
                let handleHeight = handle.frame.size.height
                let x = trackingRect.origin.x + handleWidth
                let y = trackingRect.origin.y + handleHeight
                let w = trackingRect.size.width - handleWidth
                let h = trackingRect.size.height - handleHeight
                
                trackingRect = NSRect(x: x, y: y, width: w, height: h)
                
                let options = NSTrackingArea.Options.activeInKeyWindow.rawValue | NSTrackingArea.Options.mouseEnteredAndExited.rawValue
                trackingArea = NSTrackingArea(rect: trackingRect, options: NSTrackingArea.Options(rawValue: options), owner: canvas, userInfo: ["Cursor": NSCursor.openHand, "Rect": NSStringFromRect(trackingRect), "isCanvasTrackingArea": false])
                canvas.addTrackingArea(trackingArea!)
            }
            
            for handle in handles {
                handle.refreshTrackingArea()
            }
        }
    }
}

