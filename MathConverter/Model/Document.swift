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
    func imageAddedOrRemoved()
    func displayChanged()
}

class Document: NSDocument {
    var images = [Image]()
    var noOfImages: Int = 0
    var selected = [Int]()
    var displayed = 0

    override init() {
        super.init()
    }

    override class var autosavesInPlace: Bool {
        return false
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! WindowController
        self.addWindowController(windowController)
    }

    override func data(ofType typeName: String) throws -> Data {
        // Insert code here to write your document to data of the specified type, throwing an error in case of failure.
        // Alternatively, you could remove this method and override fileWrapper(ofType:), write(to:ofType:), or write(to:ofType:for:originalContentsURL:) instead.
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

    override func read(from data: Data, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type, throwing an error in case of failure.
        // Alternatively, you could remove this method and override read(from:ofType:) instead.
        // If you do, you should also override isEntireFileLoaded to return false if the contents are lazily loaded.
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

    
    func addImage(fileURL: URL) {
        addImageAtIndex(fileURL: fileURL, atIndex: noOfImages - 1)
    }
    
    func addImageAtIndex(fileURL: URL, atIndex: Int){
        do {
            let image = try Image(fileURL: fileURL)
            if atIndex >= noOfImages - 1 {
                images.append(image)
            } else {
                images.insert(image, at: atIndex + 1)
            }
            noOfImages += 1
            imageAddedOrRemoved()
        } catch ImageError.imageImportError(let path) {
            Swift.print("NSImage init() throws, from: '\(path)'")
        } catch {
            Swift.print("Unknown image import error")
        }
    }
    
    func removeImageAtIndex(atIndex: Int){
        if (atIndex < 0 || atIndex >= noOfImages) {
            Swift.print("removeImageAtIndex(): atIndex outofbounds \(atIndex)")
        } else {
            images.remove(at: atIndex)
            noOfImages -= 1
            imageAddedOrRemoved()
        }
    }
    
    func imageAtIndex(atIndex: Int) -> Image{
        return images[atIndex]
    }
    
    private var documentObservers = [DocumentObserver]()
    
    func attachObserver(documentObserver: DocumentObserver){
        documentObservers.append(documentObserver)
    }
    
    private func imageAddedOrRemoved(){
        for documentObserver in documentObservers {
            documentObserver.imageAddedOrRemoved()
        }
    }
    
    private func changeDisplay(to: Int) {
        displayed = to
        for documentObserver in documentObservers {
            documentObserver.displayChanged()
        }
    }

}


extension Document: SelectionSidebarSelectionObserver{
    func selectionsAdded(added: Set<IndexPath>) {
        for indexPath in added {
            selected.append(indexPath.item)
        }
        changeDisplay(to: added.first?.item ?? 0)
    }
    
    func selectionsRemoved(removed: Set<IndexPath>) {
        for indexPath in removed {
            if let i = selected.index(of: indexPath.item){
                selected.remove(at: i)
            }
        }
        changeDisplay(to: selected.last ?? displayed)
    }
}

