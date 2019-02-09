//
//  SelectionCanvasController.swift
//  MathConverter
//
//  Created by Angle Qian on 2019/1/31.
//  Copyright © 2019 Angle Qian. All rights reserved.
//

import Cocoa

class SelectionCanvasController: NSViewController {
    
    var addSelectionButton: NSButton {
        get {
            return (view.window!.windowController! as! WindowController).addSelectionButton
        }
    }
    var isAddSelectionMode: Bool {
        get {
            return addSelectionButton.state == NSButton.StateValue.on
        }
    }
    var document: Document {
        return view.window!.windowController!.document as! Document
    }
    lazy var documentImage = document.images[document.displayed]
    var selectors = [SelectionSelector]()
    var currentSelector: SelectionSelector?
    var previousMouseDownPoint = NSZeroPoint
    var selectedSelectors = [SelectionSelector]() {
        didSet {
            for selector in selectors {
                selector.isSelected = selectedSelectors.contains(where: {$0 === selector})
            }
        }
    }
    var gotHitSelectorsCounter: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        (view as! SelectionCanvas).delegate = self
        view.frame = NSZeroRect
        NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: {
            self.keyDown(with: $0)
            return $0
        })
    }
    
    override func viewDidAppear() {
        document.attachObserver(documentObserver: self)
    }
    
    func refreshCanvas(frame: NSRect) {
        view.frame = frame
    }
    
    override func mouseDown(with event: NSEvent) {
        let point = view.convert(event.locationInWindow, from: nil)
        let frame = NSRect(x: point.x, y: point.y, width: 0, height: 0)
        
        markAllSelectors(asSelected: false)
        
        if isAddSelectionMode {
            view.window?.disableCursorRects()
            addSelector(withFrame: frame, asPicker: false)
            return
        }
        
        if let gotHitSelectors = getHitSelectors(forPoint: point) {
            if point == previousMouseDownPoint {
                gotHitSelectorsCounter += 1
                if gotHitSelectorsCounter >= gotHitSelectors.count {
                    gotHitSelectorsCounter = 0
                }
                currentSelector = gotHitSelectors[gotHitSelectorsCounter]
                if let temp = selectors.firstIndex(where: {$0 === currentSelector}) {
                    selectors.swapAt(0, temp)
                }
            } else {
                previousMouseDownPoint = point
                gotHitSelectorsCounter = 0
                currentSelector = gotHitSelectors[gotHitSelectorsCounter]
            }
            currentSelector!.isSelected = true
            view.needsDisplay = true
            return
        }
        
        addSelector(withFrame: frame, asPicker: true)
    }
    
    override func mouseDragged(with event: NSEvent) {
        guard let selector = currentSelector else {
            return
        }
        
        
        
        let point = view.convert(event.locationInWindow, from: nil)
        
        if selector.currentAction == .initialize || selector.currentAction == .resize {
            selector.resize(toPoint: point)
        } else if selector.currentAction == .move {
            selector.move(toPoint: point, relativeTo: previousMouseDownPoint)
        }
        
        if selector.isPicker {
            if let gotHitSelectors = getHitSelectors(forRect: selector.frame) {
                selectedSelectors = gotHitSelectors
            } else {
                selectedSelectors.removeAll(keepingCapacity: false)
            }
        }
        
        view.needsDisplay = true
    }
    
    override func mouseUp(with event: NSEvent) {
        if isAddSelectionMode {
            if let selector = currentSelector {
                if !selector.canDropOnCanvas() {
                    selectors.removeLast()
                    currentSelector = nil
                } else {
                    documentImage.addSelection(with: ImageSelection(currentSelector!.frame))
                }
            }
        } else {
            currentSelector = nil
        }
        
        view.needsDisplay = true
    }
    
    override func mouseEntered(with event: NSEvent) {
        if isAddSelectionMode {
            if let area = event.trackingArea, let userData = area.userInfo as? [String: AnyObject], let cursor = userData["Cursor"] as? NSCursor, let isCanvas = userData["isCanvasTrackingArea"] as? Bool {
                if isCanvas {
                    cursor.set()
                }
            }
        } else {
            if let area = event.trackingArea, let userData = area.userInfo as? [String: AnyObject], let cursor = userData["Cursor"] as? NSCursor, let isCanvas = userData["isCanvasTrackingArea"] as? Bool {
                if !isCanvas {
                    cursor.set()
                }
            }
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        if isAddSelectionMode {
            if let area = event.trackingArea, let userData = area.userInfo as? [String: AnyObject], let isCanvas = userData["isCanvasTrackingArea"] as? Bool {
                if isCanvas {
                    NSCursor.arrow.set()
                }
            }
        } else {
            NSCursor.arrow.set()
        }
    }
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 51 {
            removeSelectedSelectors()
        }
    }
    
    func newRect(forFrame frame: NSRect) -> NSRect {
        var X = frame.origin.x
        var Y = frame.origin.y
        var W = frame.size.width
        var H = frame.size.height
        
        if frame.size.width < 0 {
            X = frame.origin.x + frame.size.width
            W = abs(frame.size.width)
        }
        
        if frame.size.height < 0 {
            Y = frame.origin.y + frame.size.height
            H = abs(frame.size.height)
        }
        
        return NSRect(x: X, y: Y, width: W, height: H)
    }
    
    fileprivate func addSelector(withFrame frame: NSRect, asPicker picker: Bool) {
        currentSelector = SelectionSelector(asPicker: picker, forCanvas: (view as! SelectionCanvas), withFrame: frame)
        if !picker {
            currentSelector!.isSelected = true
            selectors.append(currentSelector!)
        }
    }
    
    fileprivate func getHitSelectors(forPoint point: NSPoint) -> [SelectionSelector]? {
        var gotHitSelectors = [SelectionSelector]()
        var didHitSelector = false
        
        for selector in selectors {
            if selector.isIntersecting(forPoint: point) {
                gotHitSelectors.append(selector)
                didHitSelector = true
            }
        }
        
        return didHitSelector ? gotHitSelectors : nil
    }
    
    fileprivate func getHitSelectors(forRect rect: NSRect) -> [SelectionSelector]? {
        var gotHitSelectors = [SelectionSelector]()
        var didHitSelector = false
        
        for selector in selectors {
            if selector.isIntersecting(forRect: rect) {
                gotHitSelectors.append(selector)
                didHitSelector = true
            }
        }
        
        return didHitSelector ? gotHitSelectors : nil
    }
    
    fileprivate func markAllSelectors(asSelected isSelected: Bool) {
        for selector in selectors {
            selector.isSelected = isSelected
        }
        view.needsDisplay = true
    }
    
    fileprivate func removeSelectedSelectors() {
        var i = 0
        while i < selectors.count {
            if selectors[i].isSelected {
                documentImage.removeSelection(with: selectors[i])
                selectors.remove(at: i).removeTrackingAreas()
                i -= 1
            }
            i += 1
        }
        view.needsDisplay = true
    }
    
    fileprivate func loadFromDocument() {
        selectors.removeAll(keepingCapacity: false)
        currentSelector = nil
        selectedSelectors.removeAll(keepingCapacity: false)
        previousMouseDownPoint = NSZeroPoint
        gotHitSelectorsCounter = 0
    }
    
}

extension SelectionCanvasController: SelectionCanvasDelegate {
    
}

extension SelectionCanvasController: DocumentObserver {
    func documentChanged() {
    }
    
    func displayChanged() {
        loadFromDocument()
    }
}
