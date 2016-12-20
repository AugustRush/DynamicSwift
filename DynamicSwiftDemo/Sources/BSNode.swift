//
//  BSNode.swift
//  SwiftComplierDemo
//
//  Created by AugustRush on 12/1/16.
//  Copyright © 2016 August. All rights reserved.
//

import Foundation

enum BSNodeType {
    case classType
    case functionType
    case varibleType
    case excuteObjcType
}

protocol BSNode {
    var nodeType: BSNodeType { get }
    var isFullfilled: Bool { get set }
    func appendLeafNode(_ node: BSNode) -> Void
}

protocol BSExcuteNode: BSNode {
    
}

extension BSNode {
    
    func appendLeafNode(_ node: BSNode) -> Void {
    
    }
}
