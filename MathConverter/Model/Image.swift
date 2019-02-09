//
//  Image.swift
//  MathConverter
//
//  Created by Angle Qian on 2019/1/6.
//  Copyright © 2019 Angle Qian. All rights reserved.
//

import Cocoa


class Image {
    
    var document: Document
    var image: NSImage?
    var filename: String
    var selections = [ImageSelection]() {
        didSet {
            document.documentChanged()
        }
    }
    var noOfSelections: Int {
        return selections.count
    }
    
    init(inDocument document: Document, withfileURL url: URL) throws {
        self.document = document
        image = NSImage(contentsOf: url)
        if image != nil {
            filename = url.lastPathComponent
        } else {
            throw ImageError.imageImportError(url.absoluteString)
        }
    }
    
    func addSelection(with selection: ImageSelection) {
        Swift.print("Append")
        selections.append(selection)
    }
    
    func removeSelection(with selector: SelectionSelector) {
        if let i = selections.firstIndex(where: {$0 == selector}) {
            Swift.print("remove")
            selections.remove(at: i)
        }
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
