//
//  File.swift
//  MathConverter
//
//  Created by Angle Qian on 2019/2/18.
//  Copyright © 2019 Angle Qian. All rights reserved.
//

import Cocoa


extension NSView {
    
    static func loadFromNib(nibName: String, owner: Any?) -> NSView? {
        
        var arrayWithObjects: NSArray?
        
        let nibLoaded = Bundle.main.loadNibNamed(nibName, owner: owner, topLevelObjects: &arrayWithObjects)
        
        if nibLoaded {
            guard let unwrappedObjectArray = arrayWithObjects else { return nil }
            for object in unwrappedObjectArray {
                if object is NSView {
                    return object as? NSView
                }
            }
            return nil
        } else {
            return nil
        }
    }
}
