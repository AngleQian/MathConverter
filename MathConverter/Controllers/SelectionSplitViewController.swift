//
//  SelectionSplitViewController.swift
//  MathConverter
//
//  Created by Angle Qian on 2019/1/5.
//  Copyright © 2019 Angle Qian. All rights reserved.
//

import Cocoa


class SelectionSplitViewController: NSSplitViewController {
    
    var document: Document? {
        return view.window?.windowController?.document as? Document
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewDidAppear() {
        if document != nil {
            
        } else {
            Swift.print("SelectionSplitViewController: document is nil")
        }
    }
    
    override func splitViewDidResizeSubviews(_ notification: Notification) {
        (splitViewItems[0].viewController as! SelectionSidebarViewController).refreshLayout()
    }
}
