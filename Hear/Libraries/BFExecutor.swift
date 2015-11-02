//
//  BFExecutor.swift
//  Hear
//
//  Created by Diego Haz on 11/2/15.
//  Copyright © 2015 Hear. All rights reserved.
//

import Foundation
import Bolts

extension BFExecutor {
    static func backgroundExecutor() -> BFExecutor {
        return BFExecutor(dispatchQueue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0))
    }
}