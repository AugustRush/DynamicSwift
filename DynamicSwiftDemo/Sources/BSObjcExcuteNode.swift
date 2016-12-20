//
//  BSExcuteNode.swift
//  DynamicSwiftDemo
//
//  Created by AugustRush on 12/8/16.
//  Copyright © 2016 August. All rights reserved.
//

import Foundation

enum BSObjcExcuteNodeParseStatus {
    case caller
    case selector
    case paras
    case end
}

class BSObjcExcuteNode: BSExcuteNode {
    
    var caller: String!
    var selector: String!
    var paramaters = [String]()
    //
    var isSetter = false
    var needDefineTempVar = false
    var tempVarName: String!
    //BSNode protocol
    var isFullfilled: Bool = false {
        didSet {
            if isFullfilled {
                parseStatus = .end
            }
        }
    }
    var nodeType: BSNodeType {
        return .excuteObjcType
    }
    //
    var parseStatus: BSObjcExcuteNodeParseStatus = .caller
}
