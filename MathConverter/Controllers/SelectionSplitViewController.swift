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
    var windowButton: NSSegmentedControl {
        return (view.window!.windowController! as! WindowController).windowButton
    }
    var selectionViewSplitItem: NSSplitViewItem?
    var resultViewSplitItem: NSSplitViewItem?
    
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
    }
    
    func toggleWindowButton() {
        let size = splitViewItems[1].viewController.view.frame.size
        
        removeSplitViewItem(splitViewItems[1])
        
        if windowButton.selectedSegment == 0 {
            if selectionViewSplitItem == nil {
                let selectionMainViewController = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("SelectionMainViewController")) as! SelectionMainViewController
                let item = NSSplitViewItem(viewController: selectionMainViewController)
                selectionViewSplitItem = item
            }
            addSplitViewItem(selectionViewSplitItem!)
            
            (splitViewItems[1].viewController as! SelectionMainViewController).refreshDisplay()
        } else if windowButton.selectedSegment == 1 {
            if resultViewSplitItem == nil {
                let resultMainViewController = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("ResultMainViewController")) as! NSViewController
                let item = NSSplitViewItem(viewController: resultMainViewController)
                resultViewSplitItem = item
            }
            addSplitViewItem(resultViewSplitItem!)
        }

        splitViewItems[1].viewController.view.setFrameSize(size)
        splitViewItems[1].viewController.view.needsDisplay = true
    }
}
