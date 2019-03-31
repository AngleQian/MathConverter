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
    var selectionSidebarViewController: SelectionSidebarViewController {
        return splitViewItems[0].viewController as! SelectionSidebarViewController
    }
    var selectionViewSplitItem: NSSplitViewItem?
    var resultsViewSplitItem: NSSplitViewItem?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectionViewSplitItem = splitViewItems[1]
    }
    
    override func viewDidAppear() {
        if document != nil {
            
        } else {
            Swift.print("SelectionSplitViewController: document is nil")
        }
    }
    
    override func splitViewDidResizeSubviews(_ notification: Notification) {
        (splitViewItems[0].viewController as! SelectionSidebarViewController).refreshLayout()
        if let viewController = (splitViewItems[1].viewController as? ResultsViewController) {
            viewController.refreshLayout()
        }
    }
    
    func toggleWindowButton(withSelectedSegment seg: Int) {
        let sizeLeft = splitViewItems[0].viewController.view.frame.size
        let sizeRight = splitViewItems[1].viewController.view.frame.size
        
        removeSplitViewItem(splitViewItems[1])
        
        if seg == 0 {
            if selectionViewSplitItem == nil {
                let selectionMainViewController = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("SelectionMainViewController")) as! SelectionMainViewController
                let item = NSSplitViewItem(viewController: selectionMainViewController)
                selectionViewSplitItem = item
            }
            addSplitViewItem(selectionViewSplitItem!)
            
            (splitViewItems[1].viewController as! SelectionMainViewController).refreshDisplay()
        } else if seg == 1 {
            if resultsViewSplitItem == nil {
                let resultMainViewController = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("resultsViewController")) as! NSViewController
                let item = NSSplitViewItem(viewController: resultMainViewController)
                resultsViewSplitItem = item
            }
            addSplitViewItem(resultsViewSplitItem!)
        }

        splitViewItems[0].viewController.view.setFrameSize(sizeLeft)
        splitViewItems[0].viewController.view.needsDisplay = true
        splitViewItems[1].viewController.view.setFrameSize(sizeRight)
        splitViewItems[1].viewController.view.needsDisplay = true
        
        (splitViewItems[0].viewController as! SelectionSidebarViewController).refreshLayout()
    }
    
    func addImage() {
        selectionSidebarViewController.addImage()
    }
    
    func removeImage() {
        selectionSidebarViewController.removeImage()
    }
}
