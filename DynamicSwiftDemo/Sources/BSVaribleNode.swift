//
//  BSVaribleNode.swift
//  SwiftComplierDemo
//
//  Created by AugustRush on 12/1/16.
//  Copyright © 2016 August. All rights reserved.
//

import Foundation

enum BSVaribleMemoryPolicy {
    case weak
    case strong
    case assign
}

enum BSVaribleParseStatus {
    case name
    case typeAssign
    case end
}

class BSVaribleNode: BSNode {
    
    var name: String!
    var value: Any?
    var type: String!
    var isConst = false
    var memPolicy: BSVaribleMemoryPolicy = .strong
    //
    var parseStatus: BSVaribleParseStatus = .name
    
    //BSNode protocol
    var isFullfilled: Bool = false {
        didSet {
            if isFullfilled {
                parseStatus = .end
            }
        }
    }
    var nodeType: BSNodeType {
        return .varibleType
    }
}
