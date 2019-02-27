//
//  Image.swift
//  MathConverter
//
//  Created by Angle Qian on 2019/1/6.
//  Copyright © 2019 Angle Qian. All rights reserved.
//

import Cocoa


protocol ImageDelegate {
    func selectionsChanged()
    func conversionStatusChanged(for imageSelection: ImageSelection)
}

class Image {
    
    var image: NSImage
    var filename: String
    var selections = [ImageSelection]() {
        didSet {
            delegate?.selectionsChanged()
        }
    }
    var noOfSelections: Int {
        return selections.count
    }
    var convertedSelections: [ImageSelection] {
        var convertedSelections = [ImageSelection]()
        for selection in selections {
            if selection.status == .converted {
                convertedSelections.append(selection)
            }
        }
        return convertedSelections
    }
    var noOfConvertedSelections: Int {
        return convertedSelections.count
    }
    
    var delegate: ImageDelegate?
    
    init(withfileURL url: URL, delegate: ImageDelegate) throws {
        self.delegate = delegate
        let _image = NSImage(contentsOf: url)
        
        guard _image != nil else {
            throw ImageError.imageImportError(url.absoluteString)
            
        }
        
        filename = url.lastPathComponent
        image = _image!
    }
    
    init(withDictionary dict: [String: AnyObject], delegate: ImageDelegate) throws {
        self.delegate = delegate
        
        guard dict["image"] != nil, let imageData = dict["image"] as? Data, let image = NSImage(data: imageData) else {
            throw DocumentError.deserializationError("dict[\"image\"]")
        }
        
        guard dict["filename"] != nil, let filename = dict["filename"] as? String else {
            throw DocumentError.deserializationError("dict[\"filename\"]")
        }
        
        guard dict["selections"] != nil, let serializedSelections = dict["selections"] as? [AnyObject] else {
           throw DocumentError.deserializationError("dict[\"selections\"]")
        }
        
        self.image = image
        self.filename = filename
        
        for serializedSelection in serializedSelections {
            guard let selectionDict = serializedSelection as? [String: AnyObject] else {
                throw DocumentError.deserializationError("selectionDict")
            }
            
            do {
                let selection = try ImageSelection(withDictionary: selectionDict, delegate: self)
                selections.append(selection)
            } catch {
                throw DocumentError.deserializationError("ImageSelection(withDictionary:)")
            }
        }
    }

    func serialize() -> [String: AnyObject] {
        var dict: [String: AnyObject] = [:]
        
        if let imageData = image.tiffRepresentation {
            dict["image"] = imageData as AnyObject
        }
        
        dict["filename"] = filename as AnyObject
        
        var serializedSelections = [AnyObject]()
        for selection in selections {
            serializedSelections.append(selection.serialize() as AnyObject)
        }
        dict["selections"] = serializedSelections as AnyObject
        
        
        return dict
    }
    
    func addSelection(withRect rect: NSRect) {
        let imageSelection = ImageSelection(withRect: rect, image: image, delegate: self)
        selections.append(imageSelection)
    }
    
    // if the basedOn selection need to be modified
    // first need to remove that selection using removeSelection(with:)
    // then use addSelection(withModifiedRect:basedOn:)
    // this is designed so that SelectionCanvasController need not be changed
    func addSelection(withModifiedRect rect: NSRect, basedOn selection: ImageSelection?) {
        guard let selection = selection else {
            return
        }
        
        selection.modify(toNewRect: rect)
        selections.append(selection)
    }
    
    @discardableResult
    func removeSelection(with selector: SelectionSelector) -> ImageSelection? {
        guard let i = selections.firstIndex(where: {$0 == selector}) else {
            return nil
        }
        let selection = selections[i]
        selections.remove(at: i)
        return selection
    }
    
    func modifySelector(withRect rect: NSRect, toNewRect newRect: NSRect) {
        var selection: ImageSelection?
        for _selection in selections {
            if _selection.selectionRect == rect {
                selection = _selection
            }
        }
        selection?.modify(toNewRect: newRect)
    }
    
    func convertSelections() {
        for selection in selections {
            selection.convertSelection()
        }
    }
}


extension Image: ImageSelectionDelegate {
    func conversionStatusChanged(for imageSelection: ImageSelection) {
        delegate?.conversionStatusChanged(for: imageSelection)
    }
}
