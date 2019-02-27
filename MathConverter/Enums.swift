//
//  Enums.swift
//  MathConverter
//
//  Created by Angle Qian on 2019/2/2.
//  Copyright © 2019 Angle Qian. All rights reserved.
//

import Foundation


enum SelectorActionStatus{
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


enum SelectionResultStatus: Int {
    case notConverted = 0
    case pending
    case converted
    case error
}
