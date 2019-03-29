//
//  ResultSnippetItem.swift
//  MathConverter
//
//  Created by Angle Qian on 2019/2/19.
//  Copyright © 2019 Angle Qian. All rights reserved.
//

import Cocoa


class ResultSnippetItem: NSCollectionViewItem {
    
    var originalImage: NSImage? {
        didSet {
            guard isViewLoaded else { return }
            if let image = originalImage {
                imageView?.image = image
            }
        }
    }
    
    var originalLatex: String? {
        didSet {
            guard isViewLoaded else { return }
            if let latex = originalLatex {
                textField?.stringValue = latex
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.borderWidth = 3
        view.layer?.borderColor = NSColor(calibratedRed: 0.0, green: 0.7, blue: 1.0, alpha: 1.0).cgColor
    }
    
}

