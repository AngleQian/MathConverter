//
//  SelectionCanvasController.swift
//  MathConverter
//
//  Created by Angle Qian on 2019/1/31.
//  Copyright © 2019 Angle Qian. All rights reserved.
//

import Cocoa

class SelectionCanvasController: NSViewController {
    
    var addSelectionButton: NSButton {
        get {
            return (view.window!.windowController! as! WindowController).addSelectionButton
        }
    }
    
    var isAddSelectionMode: Bool {
        get {
            if addSelectionButton.state == NSButton.StateValue.on {
                return true
            } else {
                return false
            }
        }
    }
    
    var startPoint : NSPoint!
    var shapeLayer : CAShapeLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.frame = NSRect(x: 0, y: 0, width: 0, height: 0)
    }
    
    func refreshCanvas(frame: NSRect) {
        view.frame = frame
    }
    
    override func mouseDown(with event: NSEvent) {
        if isAddSelectionMode {
            self.startPoint = view.convert(event.locationInWindow, from: nil)
            
            shapeLayer = CAShapeLayer()
            shapeLayer.lineWidth = 1.0
            shapeLayer.fillColor = NSColor.clear.cgColor
            shapeLayer.strokeColor = NSColor.black.cgColor
            shapeLayer.lineDashPattern = [10,5]
            view.layer?.addSublayer(shapeLayer)
            
            var dashAnimation = CABasicAnimation()
            dashAnimation = CABasicAnimation(keyPath: "lineDashPhase")
            dashAnimation.duration = 0.75
            dashAnimation.fromValue = 0.0
            dashAnimation.toValue = 15.0
            dashAnimation.repeatCount = .infinity
            shapeLayer.add(dashAnimation, forKey: "linePhase")
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        if isAddSelectionMode {
            let point : NSPoint = view.convert(event.locationInWindow, from: nil)
            let path = CGMutablePath()
            path.move(to: self.startPoint)
            path.addLine(to: NSPoint(x: self.startPoint.x, y: point.y))
            path.addLine(to: point)
            path.addLine(to: NSPoint(x:point.x,y:self.startPoint.y))
            path.closeSubpath()
            self.shapeLayer.path = path
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        
    }
    
}
