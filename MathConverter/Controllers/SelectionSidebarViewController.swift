//
//  SelectionSidebarViewController.swift
//  MathConverter
//
//  Created by Angle Qian on 2019/1/5.
//  Copyright © 2019 Angle Qian. All rights reserved.
//

import Cocoa


protocol SelectionSidebarSelectionObserver {
    func selections(added: Set<IndexPath>)
    func selections(removed: Set<IndexPath>)
}


class SelectionSidebarViewController: NSViewController {
    
    @IBOutlet weak var selectionSidebar: NSCollectionView!
    
    var totalNoOfImagesSelections: NSTextField {
        return (view.window!.windowController! as! WindowController).totalNoOfImagesSelections
    }
    
    var document: Document? {
        return view.window!.windowController?.document as? Document
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        registerDragAndDrop()
    }
    
    override func viewDidAppear() {
        document?.attachObserver(self)
        if let doc = document {
            attachObserver(observer: doc)
        }
        refreshLayout()
    }

    private func configureCollectionView() {
        let flowLayout = NSCollectionViewFlowLayout()
    
        flowLayout.sectionInset = NSEdgeInsets(top: 20.0, left: 10.0, bottom: 10.0, right: 10.0)
        flowLayout.minimumInteritemSpacing = 100.0
        flowLayout.minimumLineSpacing = 20.0
        
        selectionSidebar.collectionViewLayout = flowLayout
        view.wantsLayer = true
    }
    
    private func registerDragAndDrop() {
        selectionSidebar.registerForDraggedTypes([NSPasteboard.PasteboardType(kUTTypeURL as String)])
        selectionSidebar.setDraggingSourceOperationMask(NSDragOperation.every, forLocal: true)
        selectionSidebar.setDraggingSourceOperationMask(NSDragOperation.every, forLocal: false)
    }
    
    fileprivate func highlightItems(selected: Bool, atIndexPaths: Set<IndexPath>) {
        for indexPath in atIndexPaths {
            guard let item = selectionSidebar.item(at: indexPath) else {continue}
            (item as! SidebarThumbnail).setHighlight(selected: selected)
        }
    }
    
    // called when selections need to be made programmatically
    fileprivate func selectItems(newSelection: Set<IndexPath>){
        selectionSidebar.selectItems(at: newSelection, scrollPosition: NSCollectionView.ScrollPosition.nearestHorizontalEdge)
        selectionsAdded(added: newSelection)
    }
    
    fileprivate func reloadData(){
        selectionSidebar.reloadData()
        // reloadData() will clear all the selections
        selectionsRemoved(removed: selectionSidebar.selectionIndexPaths)
        refreshLayout()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: {
            self.refreshLayout()
        })
    }
    
    func refreshLayout() {
        selectionSidebar.collectionViewLayout!.invalidateLayout()
        if let layout = selectionSidebar.collectionViewLayout {
            layout.invalidateLayout()
        } else {
            Swift.print("refreshLayout() failed")
        }
    }
    
    // atIndex of the current selection
    // image(s) should be added after the selection
    // the last newly added image should be selected
    fileprivate func addImageAtIndexFromURLs(urls: [URL], atIndex: Int) {
        var currentItem = atIndex
        var indexPaths: Set<IndexPath> = []
        
        let isSelectionEmpty: Bool = selectionSidebar.selectionIndexPaths.isEmpty
        var newSelection: Set<IndexPath>
        
        for url in urls {
            document?.addImage(withFileURL: url, atIndex: atIndex)
            indexPaths.insert(IndexPath(item: currentItem, section: 0))
            currentItem += 1
        }
        
        reloadData() // clears selection
        
        if isSelectionEmpty {
            var itemIndex = 0
            if let noOfImages = document?.noOfImages {
                itemIndex = noOfImages - 1
            }
            newSelection = Set([IndexPath(item: itemIndex, section: 0)])
        } else {
            newSelection = Set([IndexPath(item: atIndex + urls.count, section: 0)])
        }
        
        selectItems(newSelection: newSelection)
    }
    
    // addImage() will be called from WindowController
    func addImage() {
        var maxSelectionIndex: Int? // if selectionIndexPaths is empty, maxSelectionIndex will be nil
        for indexPath in selectionSidebar.selectionIndexPaths {
            if indexPath.item >= maxSelectionIndex ?? 0 {
                maxSelectionIndex = indexPath.item
            }
        }
        
        let atIndex = maxSelectionIndex ?? document?.noOfImages ?? 0
        
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowsMultipleSelection = true
        openPanel.allowedFileTypes = NSImage.imageTypes
        
        openPanel.beginSheetModal(for: view.window!, completionHandler: { (response) -> Void in
            guard response == NSApplication.ModalResponse.OK else {return}
            self.addImageAtIndexFromURLs(urls: openPanel.urls, atIndex: atIndex)
        })
    }
    
    // removeImage() will be called from WindowController
    func removeImage() {
        let selectionIndexPaths = selectionSidebar.selectionIndexPaths
        if selectionIndexPaths.isEmpty {
            return
        }
        
        var selectionIndexPathsArray = Array(selectionIndexPaths)
        selectionIndexPathsArray.sort(by: {$0.item < $1.item})
        
        // remove
        // var offset is needed because when an item is removed, its current index changes
        // and becomes different from its index in selectionIndexPaths
        var offset = 0
        for indexPath in selectionIndexPathsArray {
            document?.removeImage(atIndex: indexPath.item - offset)
            offset += 1
        }
        
        reloadData()
        
        // update selection
        guard let noOfImages = document?.noOfImages else {
            return
        }
        if noOfImages == 0 {
            return
        } else {
            // the element before the first element in the selection will be selected after removal
            var itemIndex = 0
            if (selectionIndexPathsArray.first?.item ?? 0) - 1 > 0 {
                itemIndex = selectionIndexPathsArray.first!.item - 1
            }
            let newSelection = Set([IndexPath(item: itemIndex, section: 0)])
            selectItems(newSelection: newSelection)
        }
    }
    
    private var selectionSidebarSelectionObservers = [SelectionSidebarSelectionObserver]()
    
    func attachObserver(observer: SelectionSidebarSelectionObserver) {
        selectionSidebarSelectionObservers.append(observer)
    }
    
    fileprivate func selectionsAdded(added: Set<IndexPath>) {
        for observer in selectionSidebarSelectionObservers {
            observer.selections(added: added)
        }
    }
    
    fileprivate func selectionsRemoved(removed: Set<IndexPath>) {
        for observer in selectionSidebarSelectionObservers {
            observer.selections(removed: removed)
        }
    }
}


extension SelectionSidebarViewController: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return document?.noOfImages ?? 0
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = selectionSidebar.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SidebarThumbnail"), for: indexPath)
        
        guard let sidebarThumbnail = item as? SidebarThumbnail else {
            return item
        }
    
        sidebarThumbnail.thumbnail = document?.images[indexPath.item]
        
        return item
    }
}


extension SelectionSidebarViewController: NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView,
                        didSelectItemsAt indexPaths: Set<IndexPath>) {
        highlightItems(selected: true, atIndexPaths: indexPaths)
        selectionsAdded(added: indexPaths)
    }
    
    func collectionView(_ collectionView: NSCollectionView,
                        didDeselectItemsAt indexPaths: Set<IndexPath>) {
        highlightItems(selected: false, atIndexPaths: indexPaths)
        selectionsRemoved(removed: indexPaths)
    }
}


extension SelectionSidebarViewController: NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        let newWidth = selectionSidebar.frame.width - 2 * 20
        let ratio = newWidth / document!.images[indexPath.item].image.size.width
        let newHeight = ratio * document!.images[indexPath.item].image.size.height
        return NSSize(width: newWidth, height: newHeight)
    }
}


extension SelectionSidebarViewController: DocumentObserver {
    func documentLoaded() {
        reloadData()
    }

    func documentChanged() {
        totalNoOfImagesSelections.stringValue = String(document?.noOfImages ?? 0) + " / " + String(document?.noOfSelections ?? 0)
    }
    
    func displayChanged() {
        
    }
    
    func conversionStatusChanged(for imageSelection: ImageSelection) {
        
    }
}
