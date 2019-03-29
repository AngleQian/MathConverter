//
//  SelectionMainViewController.swift
//  MathConverter
//
//  Created by Angle Qian on 2019/1/5.
//  Copyright © 2019 Angle Qian. All rights reserved.
//

import Cocoa


class SelectionMainViewController: NSViewController {
    
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var selectionMainView: SelectionMainView!
    
    var document: Document? {
        return view.window?.windowController?.document as? Document
    }
    var displayed: Int {
        get {
            return document?.displayed ?? 0
        }
    }
    var selectionCanvasController: SelectionCanvasController
    
    required init?(coder: NSCoder) {
        selectionCanvasController = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("SelectionCanvasController")) as! SelectionCanvasController
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.documentView = selectionMainView
        
        configureSelectionCanvas()
    }
    
    override func viewDidAppear() {
        document?.attachObserver(self)
    }

    func refreshDisplay() {
        if let noOfImages = document?.noOfImages {
            if noOfImages > 0 && displayed >= 0 && displayed < noOfImages {
                if let image = document?.images[displayed].image {
                    selectionMainView.image = image
                    selectionMainView.frame = NSRect(origin: CGPoint(x: 0, y: 0), size: image.size)
                    selectionCanvasController.refreshCanvas(frame: NSRect(origin: CGPoint(x: 0, y: 0), size: image.size))
                }
            } else {
                selectionMainView.image = nil
                selectionMainView.frame = NSZeroRect
                selectionCanvasController.refreshCanvas(frame: NSZeroRect)
            }
        }
        scrollView.magnification = 1
    }
    
    fileprivate func configureSelectionCanvas() {
        scrollView.contentView.addSubview(selectionCanvasController.view, positioned: NSWindow.OrderingMode.above, relativeTo: nil)
        selectionMainView.nextResponder = selectionCanvasController
    }
}


extension SelectionMainViewController: DocumentObserver {
    func documentLoaded() {
        refreshDisplay()
    }
    
    func documentChanged() {
        
    }
    
    func displayChanged() {
        refreshDisplay()
    }
    
    func conversionStatusChanged(for imageSelection: ImageSelection) {
        
    }
}
