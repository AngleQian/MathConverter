//
//  ResultsViewController.swift
//  MathConverter
//
//  Created by Angle Qian on 2019/2/11.
//  Copyright © 2019 Angle Qian. All rights reserved.
//

import Cocoa


class ResultsViewController: NSViewController {
    
    @IBOutlet weak var resultsView: NSCollectionView!
    
    var document: Document? {
        return view.window?.windowController?.document as? Document
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureResultsView()
    }
    
    override func viewDidAppear() {
        document?.attachObserver(documentObserver: self)
        refreshLayout()
    }
    
    fileprivate func configureResultsView() {
        let flowLayout = NSCollectionViewFlowLayout()
        
        flowLayout.sectionInset = NSEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
        flowLayout.minimumInteritemSpacing = 20000
        flowLayout.minimumLineSpacing = 30.0
        
        resultsView.collectionViewLayout = flowLayout
        view.wantsLayer = true
    }
    
    func refreshLayout() {
        resultsView.collectionViewLayout?.invalidateLayout()
    }
    
    fileprivate func reloadData() {
        resultsView.reloadData()
        refreshLayout()
    }
}


extension ResultsViewController: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let document = document, document.displayed < document.noOfImages else {
            return 0
        }

        return document.images[document.displayed].noOfConvertedSelections
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = resultsView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ResultSnippetItem"), for: indexPath)
        
        item.view.translatesAutoresizingMaskIntoConstraints = false
        
        guard let resultSnippet = item as? ResultSnippetItem, let document = document, document.displayed < document.noOfImages, indexPath.item <  document.images[document.displayed].noOfConvertedSelections else {
            return item
        }
        
        resultSnippet.originalImage = document.images[document.displayed].convertedSelections[indexPath.item].selectionImage
        resultSnippet.originalLatex = document.images[document.displayed].convertedSelections[indexPath.item].latex
        
        return item
    }
}


extension ResultsViewController: NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        guard let document = document, document.displayed < document.noOfImages, indexPath.item < document.images[document.displayed].convertedSelections.count, let image = document.images[document.displayed].convertedSelections[indexPath.item].selectionImage else {
            return NSSize(width: 0, height: 0)
        }

        let width = resultsView.frame.size.width * 0.8
        let height = image.size.height + 5 + 22
        let size = NSSize(width: width, height: height)
        
        return size
    }
}


extension ResultsViewController: DocumentObserver {
    func documentLoaded() {
        reloadData()
    }

    func documentChanged() {
        reloadData()
    }
    
    func displayChanged() {
        reloadData()
    }
    
    func conversionStatusChanged(for imageSelection: ImageSelection) {
        reloadData()
    }
}
