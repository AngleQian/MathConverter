//
//  DragView.swift
//  MathConverter
//
//  Created by Angle Qian on 2019/1/4.
//  Copyright © 2019 Angle Qian. All rights reserved.
//

import Cocoa

protocol DragViewDelegate {
    func dragView(didDragFileWith URL: URL)
}

class DragView : NSView {
    var delegate: DragViewDelegate?
    
    private var acceptedFileExtensions = ["png", "jpdeg", "jpg"]
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.gray.cgColor
        
        registerForDraggedTypes([NSPasteboard.PasteboardType.URL, NSPasteboard.PasteboardType.fileURL])
    }
    
    override func draw(_ dirtyRect: NSRect){
        super.draw(dirtyRect)
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if checkExtension(sender) == true {
            self.layer?.backgroundColor = NSColor.blue.cgColor
            return .copy
        } else {
            return NSDragOperation()
        }
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?){
        self.layer?.backgroundColor = NSColor.gray.cgColor
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        self.layer?.backgroundColor = NSColor.gray.cgColor
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let pasteboard = sender.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
            let path = pasteboard[0] as? String else {
                return false
        }
        
        let fileURL = URL(fileURLWithPath: path)
        delegate?.dragView(didDragFileWith: fileURL)
        
        
        Swift.print("Path URL: \(fileURL.absoluteString)")
        
        return true
    }
    
    fileprivate func checkExtension(_ drag: NSDraggingInfo) -> Bool {
        guard let board = drag.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
            let path = board[0] as? String else {
                return false
        }
        
        let suffix = URL(fileURLWithPath: path).pathExtension
        for ext in self.acceptedFileExtensions {
            if ext.lowercased() == suffix {
                return true
            }
        }
        
        return false
    }
}
