//
//  ImageSelection.swift
//  MathConverter
//
//  Created by Angle Qian on 2019/1/23.
//  Copyright © 2019 Angle Qian. All rights reserved.
//

import Cocoa


protocol ImageSelectionDelegate {
    var image: NSImage { get }
    func conversionStatusChanged(for imageSelection: ImageSelection)
}


class ImageSelection {

    var selectionRect: NSRect
    var selectionImage: NSImage?
    var status: SelectionResultStatus {
        didSet {
            delegate?.conversionStatusChanged(for: self)
        }
    }
    var latex = ""
    var userLatex: String?
    
    var delegate: ImageSelectionDelegate?
    
    init(withRect rect: NSRect, image: NSImage, delegate: ImageSelectionDelegate) {
        self.status = .notConverted
        selectionRect = rect
        self.delegate = delegate

        updateSelectionImage()
    }
    
    init(withDictionary dict: [String: AnyObject], delegate: ImageSelectionDelegate) throws {
        self.delegate = delegate
        
        guard dict["selectionRect"] != nil, let rect = NSRect(dictionaryRepresentation: dict["selectionRect"] as! CFDictionary) else {
            throw DocumentError.deserializationError("dict[\"selectionRect\"]")
        }
        
        guard dict["status"] != nil, let status = SelectionResultStatus(rawValue: dict["status"] as! Int) else {
            throw DocumentError.deserializationError("dict[\"status\"]")
        }
        
        guard dict["latex"] != nil else {
            throw DocumentError.deserializationError("dict[\"latex\"]")
        }
        
        guard dict["userLatex"] != nil else {
            throw DocumentError.deserializationError("dict[\"userLatex\"]")
        }
        
        selectionRect = rect
        self.status = status
        updateSelectionImage()
        latex = (dict["latex"] as? String) ?? ""
        userLatex = dict["userLatex"] as? String
    }
    
    func serialize() -> [String: AnyObject] {
        var dict: [String: AnyObject] = [:]
        
        dict["selectionRect"] = selectionRect.dictionaryRepresentation
        dict["status"] = status.rawValue as AnyObject
        dict["latex"] = latex as AnyObject
        dict["userLatex"] = userLatex as AnyObject
        
        return dict
    }
    
    func modify(toNewRect rect: NSRect) {
        guard status == .notConverted else {
            return
        }
        selectionRect = rect
        updateSelectionImage()
    }
    
    func convertSelection() {
        if case .notConverted = status {
            
        } else if case .error = status {
            
        } else {
            return
        }
        
        guard let image = selectionImage else {
            return
        }
        convertImage(image: image, caller: self)
        status = .pending
    }
    
    fileprivate func updateSelectionImage() {
        guard let image = delegate?.image else {
            return
        }
        
        let rect = selectionRect
        
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return
        }
        
        let x = rect.origin.x
        let y = image.size.height - rect.origin.y - rect.size.height
        let croppedRect = CGRect(x: x, y: y, width: rect.size.width, height: rect.size.height)
        
        guard let croppedImage = cgImage.cropping(to: croppedRect) else {
            return
        }
        
        selectionImage = NSImage(cgImage: croppedImage, size: rect.size)
    }
}


extension ImageSelection: ConverterCaller {
    func responseError(_ error: Error) {
        Swift.print(error)
    }
    
    func response(_ response: HTTPURLResponse) {

    }
    
    func result(_ result: NSDictionary) {
        guard let latex = result["latex"] as? String else {
            Swift.print("latex guard")
            return
        }
        
        self.latex = latex
        Swift.print(latex)
        status = .converted
    }
}


extension ImageSelection: Equatable {
    static func == (lhs: ImageSelection, rhs: ImageSelection) -> Bool {
        return lhs.selectionRect == rhs.selectionRect
    }
    
    static func == (lhs: ImageSelection, rhs: SelectionSelector) -> Bool {
        return lhs.selectionRect == rhs.frame
    }
}
