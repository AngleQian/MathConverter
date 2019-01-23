//
//  SelectionMainView.swift
//  MathConverter
//
//  Created by Angle Qian on 2019/1/21.
//  Copyright © 2019 Angle Qian. All rights reserved.
//

import Cocoa

class SelectionMainView: NSImageView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configureSelectionMainView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureSelectionMainView()
    }
    
    func configureSelectionMainView(){
        self.frame = NSRect(x: 0, y: 0, width: 100, height: 100)
        self.isEditable = false
        self.isEnabled = true
        self.isHighlighted = true
        self.imageScaling = NSImageScaling.scaleNone
    }
}
