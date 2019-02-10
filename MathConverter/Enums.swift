//
//  Enums.swift
//  MathConverter
//
//  Created by Angle Qian on 2019/2/2.
//  Copyright © 2019 Angle Qian. All rights reserved.
//

import Foundation


/// Defines the current action of a selector
///
/// - none: no action
/// - resize: resizing
/// - move: moving
/// - initialize: initializing
enum SelectorActionStatus {
    case none
    case resize
    case move
    case initialize
}


enum SelectorHandleType {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}

enum SelectionResultStatus {
    case notConverted
    case converted
    case error
}
