//
//  ViewController.swift
//  MathConverter
//
//  Created by Angle Qian on 2019/1/4.
//  Copyright © 2019 Angle Qian. All rights reserved.
//

import Cocoa


class HomeViewController: NSViewController {

    var document: Document? {
        return view.window?.windowController?.document as? Document
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear() {
        document?.attachObserver(documentObserver: self)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}


extension HomeViewController: DocumentObserver {
    func documentLoaded() {

    }
    
    func documentChanged() {
        
    }
    
    func displayChanged() {
        
    }
    
    func conversionStatusChanged(for imageSelection: ImageSelection) {
        
    }
}



