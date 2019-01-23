//
//  WindowController.swift
//  MathConverter
//
//  Created by Angle Qian on 2019/1/5.
//  Copyright © 2019 Angle Qian. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        shouldCascadeWindows = true
        adjustWindowSize()
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        adjustWindowSize()
    }
    
    func adjustWindowSize() {
        let xRatio = 0.8
        let yRatio = 0.8
        
        guard let screen = NSScreen.main else {
            fatalError("No screen?")
        }
        
        let screenRect: NSRect
        screenRect = screen.frame
        let sH = Double(screenRect.size.height)
        let sW = Double(screenRect.size.width)
        let windowRect = CGRect(x: Double(window?.frame.origin.x ?? 0), y: Double(window?.frame.origin.y ?? 0), width: xRatio * sW, height: yRatio * sH) as NSRect
        
        window?.setFrame(windowRect, display: true, animate: true)
    }
}
