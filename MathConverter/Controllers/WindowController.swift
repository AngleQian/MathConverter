//
//  WindowController.swift
//  MathConverter
//
//  Created by Angle Qian on 2019/1/5.
//  Copyright © 2019 Angle Qian. All rights reserved.
//

import Cocoa


class WindowController: NSWindowController {

    @IBOutlet weak var removeImageButton: NSButton!
    @IBOutlet weak var totalNoOfImagesSelections: NSTextField!
    @IBOutlet weak var addSelectionButton: NSButton!
    @IBOutlet weak var windowButton: NSSegmentedControl!
    
    var selectionSplitViewController: SelectionSplitViewController {
        get {
            return window!.contentViewController! as! SelectionSplitViewController
        }
    }
    
    var selectionSidebarViewController: SelectionSidebarViewController {
        get {
            return selectionSplitViewController.splitViewItems[0].viewController as! SelectionSidebarViewController
        }
    }
    
    var document_: Document? {
        get {
            return document as? Document
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        shouldCascadeWindows = true
        adjustWindowSize()
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        adjustWindowSize()
        removeImageButton.isEnabled = true
    }
    
    func adjustWindowSize() {
//        let xRatio = 0.9
//        let yRatio = 0.9
//        
//        guard let screen = NSScreen.main else {
//            fatalError("No screen?")
//        }
//        
//        let screenRect: NSRect
//        screenRect = screen.frame
//        let sH = Double(screenRect.size.height)
//        let sW = Double(screenRect.size.width)
//        let windowRect = CGRect(x: Double(window?.frame.origin.x ?? 0), y: Double(window?.frame.origin.y ?? 0), width: xRatio * sW, height: yRatio * sH) as NSRect
//        
//        window?.setFrame(windowRect, display: true, animate: true)
    }
    
    
    @IBAction func addImage(_ sender: Any) {
        selectionSidebarViewController.addImage()
    }
    
    @IBAction func removeImage(_ sender: Any) {
        selectionSidebarViewController.removeImage()
    }
    
    @IBAction func toggleWindowButton(_ sender: NSSegmentedControl) {
        selectionSplitViewController.toggleWindowButton()
    }
    
}


extension WindowController: DocumentObserver {
    func documentChanged() {
        
    }
    
    func displayChanged() {
        
    }
}
