//
//  sidebarThumbnail.swift
//  MathConverter
//
//  Created by Angle Qian on 2019/1/6.
//  Copyright © 2019 Angle Qian. All rights reserved.
//

import Cocoa


class SidebarThumbnail: NSCollectionViewItem {
    
    var thumbnail: Image? {
        didSet {
            guard isViewLoaded else { return }
            if let thumbail_ = thumbnail {
                imageView?.image = thumbail_.image
                textField?.stringValue = thumbail_.filename
            } else {
                imageView?.image = nil
                textField?.stringValue = ""
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            view.layer?.borderWidth = isSelected ? 3.0 : 0.0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.borderWidth = 0.0
        view.layer?.borderColor = NSColor(calibratedRed: 0.0, green: 0.7, blue: 1.0, alpha: 1.0).cgColor        
    }
    
    func setHighlight(selected: Bool) {
        view.layer?.borderWidth = selected ? 3.0 : 0.0
    }
}

