//
//  SelectionMainViewController.swift
//  MathConverter
//
//  Created by Angle Qian on 2019/1/5.
//  Copyright © 2019 Angle Qian. All rights reserved.
//

import Cocoa

class SelectionMainViewController: NSViewController {
    @IBOutlet var scrollView: NSScrollView!
    
//    var imageView = SelectionMainView(frame: NSRect(x: 0, y: 0, width: 0, height: 0))
    @IBOutlet weak var imageView: SelectionMainView!
    
    
    var document: Document? {
        return view.window?.windowController?.document as? Document
    }
    var displayed = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        scrollView.documentView = imageView
    }
    
    override func viewDidAppear() {
        document?.attachObserver(documentObserver: self)
    }
    
    func refreshDisplay() {
        if let noOfImages = document?.noOfImages {
            if noOfImages > 0 && displayed >= 0 && displayed < noOfImages {
                if let image = document?.images[displayed].image {
                    imageView.image = image
                    let center = CGPoint(x: 0, y: 0)
                    imageView.frame = NSRect(origin: center, size: image.size)
                    Swift.print(imageView.frame)
                }
            } else {
                imageView.image = nil
                imageView.frame = NSRect(x: 0, y: 0, width: 0, height: 0)
            }
        } else {
        }
    }
    
    func updateScrollBars(){
        
    }
}

extension SelectionMainViewController: DragViewDelegate {
    func dragView(didDragFileWith URL: URL) {
//        document?.addImage(fileURL: URL)
    }
}

extension SelectionMainViewController: DocumentObserver{
    func imageAddedOrRemoved() {
        
    }
    
    func displayChanged() {
        displayed = document?.displayed ?? 0
        refreshDisplay()
    }
    
}
