//
//  Structs.swift
//  MathConverter
//
//  Created by Angle Qian on 2019/2/4.
//  Copyright © 2019 Angle Qian. All rights reserved.
//

import Foundation


struct Boundary {
    var size: CGFloat = 0
    var position: CGFloat = 0
}


struct Boundaries {
    var top: Boundary = Boundary()
    var bottom: Boundary = Boundary()
    var left: Boundary = Boundary()
    var right: Boundary = Boundary()
}
