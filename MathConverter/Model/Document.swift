//
//  Document.swift
//  MathConverter
//
//  Created by Angle Qian on 2019/1/4.
//  Copyright © 2019 Angle Qian. All rights reserved.
//

import Foundation
import Cocoa


protocol DocumentObserver {
    func documentChanged()
    func displayChanged()
    func conversionStatusChanged(for imageSelection: ImageSelection)
    func documentLoaded()
}


class Document: NSDocument {
    
    var images = [Image]()
    var noOfImages: Int {
        return images.count
    }
    var selected = [Int]()
    var displayed = 0
    var noOfSelections: Int {
        var temp = 0
        for image in images {
            temp += image.noOfSelections
        }
        return temp
    }
    
    override init() {
        super.init()
    }
    
    override class var autosavesInPlace: Bool {
        return true
    }
    
    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! WindowController
        self.addWindowController(windowController)
    }
    
    override func data(ofType typeName: String) throws -> Data {
        // Insert code here to write your document to data of the specified type, throwing an error in case of failure.
        let documentDict = serialize()
        do {
            let documentData = try NSKeyedArchiver.archivedData(withRootObject: documentDict, requiringSecureCoding: false)
            return documentData
        } catch {
            throw DocumentError.serializationError("NSKeyedArchiver.archivedData(withRootObject:requiringSecuringCoding:)")
        }
    }
    
    override func read(from data: Data, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type, throwing an error in case of failure.
        var documentDict: [String: AnyObject]
        
        do {
            guard let dict = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String: AnyObject] else {
                throw DocumentError.deserializationError("documentDict")
            }
            
            documentDict = dict
        } catch {
            throw DocumentError.deserializationError("NSKeyedUnarchiver.unarchiveTopLevelObjectWithData()")
        }
    
        do {
            try deserialize(from: documentDict)
        } catch {
            throw DocumentError.deserializationError("deserializeDocument(from:)")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: {
            self.loadDocument()
        })
    }
    
    func deserialize(from dict: [String: AnyObject]) throws {
        guard dict["images"] != nil, let serializedImages = dict["images"] as? [AnyObject] else {
            throw DocumentError.deserializationError("dict[\"images\"]")
        }

        for serializedImage in serializedImages {
            guard let imageDict = serializedImage as? [String: AnyObject] else {
                throw DocumentError.deserializationError("imageDict")
            }
            
            do {
                let image = try Image(withDictionary: imageDict, delegate: self)
                images.append(image)
            } catch DocumentError.deserializationError(let errorString) {
                Swift.print("deserializeDocument: \(errorString)")
            }
        }
    }
    
    func serialize() -> [String: AnyObject] {
        var dict: [String: AnyObject] = [:]
        
        var serializedImages = [AnyObject]()
        for image in images {
            serializedImages.append(image.serialize() as AnyObject)
        }
        dict["images"] = serializedImages as AnyObject
        
        return dict
    }
    
    
    func addImage(withFileURL: URL) {
        addImage(withFileURL: withFileURL, atIndex: noOfImages - 1)
    }
    
    func addImage(withFileURL: URL, atIndex: Int){
        do {
            let image = try Image(withfileURL: withFileURL, delegate: self)
            if atIndex >= noOfImages - 1 {
                images.append(image)
            } else {
                images.insert(image, at: atIndex + 1)
            }
            changeDocument()
        } catch ImageError.imageImportError(let path) {
            Swift.print("NSImage init() throws, from: '\(path)'")
        } catch {
            Swift.print("Unknown image import error")
        }
    }
    
    func removeImage(atIndex: Int){
        if (atIndex < 0 || atIndex >= noOfImages) {
            Swift.print("removeImageAtIndex(): atIndex outofbounds \(atIndex)")
        } else {
            images.remove(at: atIndex)
            changeDocument()
        }
    }
    
    func getImage(atIndex: Int) -> Image{
        return images[atIndex]
    }
    
    func convertSelections() {
        for image in images {
            image.convertSelections()
        }
    }
    
    private var documentObservers = [DocumentObserver]()
    
    func attachObserver(_ documentObserver: DocumentObserver){
        documentObservers.append(documentObserver)
    }
    
    fileprivate func changeDocument() {
        updateChangeCount(NSDocument.ChangeType.changeDone)
        for documentObserver in documentObservers {
            documentObserver.documentChanged()
        }
    }
    
    fileprivate func changeDisplay(to display: Int) {
        displayed = display
        for documentObserver in documentObservers {
            documentObserver.displayChanged()
        }
    }
    
    fileprivate func changeConversionStatus(for imageSelection: ImageSelection) {
        updateChangeCount(NSDocument.ChangeType.changeDone)
        for documentObserver in documentObservers {
            documentObserver.conversionStatusChanged(for: imageSelection)
        }
    }
    
    fileprivate func loadDocument() {
        for documentObserver in documentObservers {
            documentObserver.documentLoaded()
        }
    }
    
}


extension Document: ImageDelegate {
    func conversionStatusChanged(for imageSelection: ImageSelection) {
        changeConversionStatus(for: imageSelection)
    }
    
    func selectionsChanged() {
        changeDocument()
    }
}


extension Document: SelectionSidebarSelectionObserver {
    func selections(added: Set<IndexPath>) {
        for indexPath in added {
            selected.append(indexPath.item)
        }
        changeDisplay(to: added.first?.item ?? 0)
    }
    
    func selections(removed: Set<IndexPath>) {
        for indexPath in removed {
            if let i = selected.index(of: indexPath.item){
                selected.remove(at: i)
            }
        }
        changeDisplay(to: selected.last ?? displayed)
    }
}
