//
//  SelectionSidebarViewController.swift
//  MathConverter
//
//  Created by Angle Qian on 2019/1/5.
//  Copyright © 2019 Angle Qian. All rights reserved.
//

import Cocoa

protocol SelectionSidebarSelectionObserver {
    func selectionsAdded(added: Set<IndexPath>)
    func selectionsRemoved(removed: Set<IndexPath>)
}

class SelectionSidebarViewController: NSViewController {
    
    @IBOutlet weak var selectionSidebar: NSCollectionView!
    @IBOutlet weak var noOfImagesLabel: NSTextField!
    @IBOutlet weak var addImageButton: NSButton!
    @IBOutlet weak var removeImageButton: NSButton!
    
    var document: Document? {
        return view.window!.windowController?.document as? Document
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        registerDragAndDrop()
    }
    
    override func viewDidAppear() {
        document?.attachObserver(documentObserver: self)
        if let doc = document {
            attachObserver(observer: doc)
        }
    }

    private func configureCollectionView() {
        let flowLayout = NSCollectionViewFlowLayout()
        
        flowLayout.itemSize = NSSize(width: 160.0, height: 140.0)
        flowLayout.sectionInset = NSEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
        flowLayout.minimumInteritemSpacing = 20.0
        flowLayout.minimumLineSpacing = 20.0
        
        selectionSidebar.collectionViewLayout = flowLayout
        view.wantsLayer = true
        selectionSidebar.layer?.backgroundColor = NSColor.blue.cgColor
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
        updateRemoveButton()
    }
    
    // called when selections need to be made programmatically
    fileprivate func selectItems(newSelection: Set<IndexPath>){
        selectionSidebar.selectItems(at: newSelection, scrollPosition: NSCollectionView.ScrollPosition.nearestHorizontalEdge)
        updateRemoveButton()
        selectionsAdded(added: newSelection)
    }
    
    fileprivate func reloadData(){
        selectionSidebar.reloadData()
        // reloadData() will clear all the selections
        selectionsRemoved(removed: selectionSidebar.selectionIndexPaths)
    }
    
    fileprivate func updateRemoveButton() {
        removeImageButton.isEnabled = !selectionSidebar.selectionIndexPaths.isEmpty
    }
    
    // atIndex of the current selection
    // image(s) should be added after the selection
    // the last newly added image should be selected
    fileprivate func addImageAtIndexFromURLs(urls: [URL], atIndex: Int){
        var currentItem = atIndex
        var indexPaths: Set<IndexPath> = []
        
        let isSelectionEmpty: Bool = selectionSidebar.selectionIndexPaths.isEmpty
        var newSelection: Set<IndexPath>
        
        for url in urls {
            document?.addImageAtIndex(fileURL: url, atIndex: atIndex)
            indexPaths.insert(IndexPath(item: currentItem, section: 0))
            currentItem += 1
        }
        
//        selectionSidebar.insertItems(at: indexPaths)
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
    
    
    @IBAction func addImage(_ sender: Any) {
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
    
    @IBAction func removeImage(_ sender: Any) {
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
            document?.removeImageAtIndex(atIndex: indexPath.item - offset)
            offset += 1
        }
        
        reloadData()
        
        // update selection
        guard let noOfImages = document?.noOfImages else {
            return
        }
        if noOfImages == 0 {
            updateRemoveButton()
            // no selection needed
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
    
    func attachObserver(observer: SelectionSidebarSelectionObserver){
        selectionSidebarSelectionObservers.append(observer)
    }
    
    func selectionsAdded(added: Set<IndexPath>) {
        for observer in selectionSidebarSelectionObservers {
            observer.selectionsAdded(added: added)
        }
    }
    
    func selectionsRemoved(removed: Set<IndexPath>) {
        for observer in selectionSidebarSelectionObservers {
            observer.selectionsRemoved(removed: removed)
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
    
        let thumbnail = document?.images[indexPath.item]
        sidebarThumbnail.thumbnail = thumbnail
        
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


extension SelectionSidebarViewController: DocumentObserver {
    func imageAddedOrRemoved() {
        if let x = document?.noOfImages {
            noOfImagesLabel.stringValue = String(x) + " Images"
        }
    }
    func displayChanged() {
        
    }
}
