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
    
    var maxItemWidth: CGFloat = 0 {
        didSet {
            setMinimumWidth()
        }
    }
    
    var document: Document? {
        return view.window?.windowController?.document as? Document
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureResultsView()
    }
    
    override func viewDidAppear() {
        document?.attachObserver(self)
        refreshLayout()
    }
    
    fileprivate func configureResultsView() {
        let flowLayout = NSCollectionViewFlowLayout()
        
        flowLayout.sectionInset = NSEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
        flowLayout.minimumInteritemSpacing = 30000000000
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
    
    fileprivate func setMinimumWidth() {
        let constant = maxItemWidth + 40
        let horizontalConstraint = NSLayoutConstraint(item: resultsView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.greaterThanOrEqual, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1.0, constant: constant)
        view.addConstraint(horizontalConstraint)
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
        
        item.view.translatesAutoresizingMaskIntoConstraints = true
        
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

        let width = image.size.width + 10
        let height = image.size.height + 15 + 22
        let size = NSSize(width: width, height: height)
        
        if width > maxItemWidth {
            maxItemWidth = width
        }
        
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
