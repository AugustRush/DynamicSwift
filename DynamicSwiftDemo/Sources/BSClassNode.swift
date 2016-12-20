//
//  BSClassNode.swift
//  SwiftComplierDemo
//
//  Created by AugustRush on 12/1/16.
//  Copyright © 2016 August. All rights reserved.
//

import Foundation

enum BSClassNodeParseStatus {
    case name
    case superClass
    case impStart
    case impEnd
}

class BSClassNode: BSNode {
    var name: String!
    var superClass: String = "NSObject"
    var instanceMethods = [BSFunctionNode]()
    var classMethods = [BSFunctionNode]()
    
    var varibles = [String:BSVaribleNode]()
    // parse status
    var parseStatus: BSClassNodeParseStatus = .name
    
    
    //BSNode protocol
    var isFullfilled: Bool = false {
        didSet {
            if isFullfilled {
                self.parseStatus = .impEnd
            }
        }
    }
    var nodeType: BSNodeType {
        return .classType
    }
    
    func appendLeafNode(_ node: BSNode) {
        print("class append node \(node)")
        switch node.nodeType {
        case .classType:
            fatalError()
        case .functionType:
            let function = node as! BSFunctionNode
            if function.type == .instance {
                instanceMethods.append(function)
            } else {
                classMethods.append(function)
            }
        case .varibleType:
            let varible = node as! BSVaribleNode
            varibles.updateValue(varible, forKey: varible.name)
        case .excuteObjcType:
            fatalError()
        }
    }
    
}
