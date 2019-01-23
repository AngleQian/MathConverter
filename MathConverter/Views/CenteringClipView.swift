//
//  CenteringClipView.swift
//  MathConverter
//
//  Created by Angle Qian on 2019/1/23.
//  Copyright © 2019 Angle Qian. All rights reserved.
//

import Cocoa

class CenteringClipView: NSClipView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func constrainBoundsRect(_ proposedBounds: NSRect) -> NSRect {
        var constrainedClipViewBounds = super.constrainBoundsRect(proposedBounds)
        
        guard let documentView = documentView else {
            return constrainedClipViewBounds
        }
        
        let documentViewFrame = documentView.frame
        
        // If proposed clip view bounds width is greater than document view frame width, center it horizontally.
        if documentViewFrame.width < proposedBounds.width {
            constrainedClipViewBounds.origin.x = floor((proposedBounds.width - documentViewFrame.width) / -2.0)
        }
        
        // If proposed clip view bounds height is greater than document view frame height, center it vertically.
        if documentViewFrame.height < proposedBounds.height {
            constrainedClipViewBounds.origin.y = floor((proposedBounds.height - documentViewFrame.height) / -2.0)
        }
        
        return constrainedClipViewBounds
    }
    
}
