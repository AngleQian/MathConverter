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
        return (view.window!.windowController! as! WindowController).addSelectionButton
    }
    var isAddSelectionMode: Bool {
        return addSelectionButton.state == NSButton.StateValue.on
    }
    var document: Document? {
        return view.window?.windowController?.document as? Document
    }
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
    var isMouseDown = false

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
        document?.attachObserver(self)
        loadFromDocument()
    }
    
    func refreshCanvas(frame: NSRect) {
        view.frame = frame
        loadFromDocument()
    }
    
    override func mouseDown(with event: NSEvent) {
        isMouseDown = true
        view.window?.disableCursorRects()
        
        let point = view.convert(event.locationInWindow, from: nil)
        let frame = NSRect(x: point.x, y: point.y, width: 0, height: 0)
        
        markAllSelectors(asSelected: false)
        
        if isAddSelectionMode {
            addSelector(withFrame: frame, asPicker: false, withStatus: .notConverted)
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
        
        addSelector(withFrame: frame, asPicker: true, withStatus: nil)
    }
    
    override func mouseDragged(with event: NSEvent) {
        guard let selector = currentSelector, let document = document else {
            return
        }
        
        let point = view.convert(event.locationInWindow, from: nil)
        
        if selector.currentAction == .initialize {
            selector.resize(toPoint: point)
        } else {
            let removedSelection = document.images[document.displayed].removeSelection(with: selector)
            
            if selector.currentAction == .resize {
                selector.resize(toPoint: point)
            } else if selector.currentAction == .move {
                selector.move(toPoint: point, relativeTo: previousMouseDownPoint)
            }
            
            document.images[document.displayed].addSelection(withModifiedRect: selector.frame, basedOn: removedSelection)
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
        isMouseDown = false
        
        guard let document = document else {
            return
        }
        
        if isAddSelectionMode {
            if let selector = currentSelector {
                if !selector.canDropOnCanvas() {
                    selectors.removeLast()
                    currentSelector = nil
                } else {
                    document.images[document.displayed].addSelection(withRect: selector.frame)
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
    
    fileprivate func addSelector(withFrame frame: NSRect, asPicker picker: Bool, withStatus status: SelectionResultStatus?) {
        currentSelector = SelectionSelector(asPicker: picker, forCanvas: (view as! SelectionCanvas), withFrame: frame, withStatus: status)
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
        guard let document = document else {
            return
        }
        
        var i = 0
        while i < selectors.count {
            if selectors[i].isSelected {
                document.images[document.displayed].removeSelection(with: selectors[i])
                selectors.remove(at: i).removeTrackingAreas()
                i -= 1
            }
            i += 1
        }
        view.needsDisplay = true
    }
    
    fileprivate func loadFromDocument() {
        guard let document = document else {
            return
        }
        
        while 0 < selectors.count {
            selectors.remove(at: 0).removeTrackingAreas()
        }
        currentSelector = nil
        selectedSelectors.removeAll(keepingCapacity: false)
        previousMouseDownPoint = NSZeroPoint
        gotHitSelectorsCounter = 0
        
        guard document.noOfImages != 0, document.displayed < document.noOfImages else {
            return
        }
        
        for selection in document.images[document.displayed].selections {
            addSelector(withFrame: selection.selectionRect, asPicker: false, withStatus: selection.status)
        }
        markAllSelectors(asSelected: false)
    }
    
    fileprivate func updateSelectorStatus(for imageSelection: ImageSelection) {
        guard let document = document, document.noOfImages != 0, document.displayed < document.noOfImages else {
            return
        }
        
        let selectionSelector = selectors.first(where: {imageSelection == $0})
        selectionSelector?.resultStatus = imageSelection.status
        if let currentSelector = currentSelector, imageSelection == currentSelector {
            currentSelector.resultStatus = imageSelection.status
        }
        
        view.needsDisplay = true
    }
}


extension SelectionCanvasController: SelectionCanvasDelegate {
    
}


extension SelectionCanvasController: DocumentObserver {
    func documentLoaded() {
        loadFromDocument()
    }
    
    func documentChanged() {
    }
    
    func displayChanged() {
        loadFromDocument()
    }
    
    func conversionStatusChanged(for imageSelection: ImageSelection) {
        updateSelectorStatus(for: imageSelection)
    }
}
