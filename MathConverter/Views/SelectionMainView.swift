//
//  SelectionMainView.swift
//  MathConverter
//
//  Created by Angle Qian on 2019/1/21.
//  Copyright © 2019 Angle Qian. All rights reserved.
//

import Cocoa


class SelectionMainView: NSImageView {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureSelectionMainView()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configureSelectionMainView()
    }

    func configureSelectionMainView() {
        isEditable = false
        isHighlighted = true
        imageScaling = NSImageScaling.scaleNone
    }

}
