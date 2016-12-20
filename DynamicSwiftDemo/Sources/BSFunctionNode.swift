//
//  BSFunctionNode.swift
//  SwiftComplierDemo
//
//  Created by AugustRush on 12/1/16.
//  Copyright © 2016 August. All rights reserved.
//

import Foundation

enum BSFunctionNodeParseStatus {
    case name
    case paraStart
    case paraType
    case paraEnd
    case returnStart
    case impStart
    case impEnd
}

enum BSFunctionNodeType: Int {
    case class_ = 0
    case instance = 1
    case static_ = 2
}

class BSFunctionNode: BSNode {
    var isOverride = false
    var returnType = "Void"
    var name: String!
    var type: BSFunctionNodeType = .instance
    var paramaters = [BSVaribleNode]()
    var excuteNodes = [BSExcuteNode]()
    // for objc
    lazy var objcaName: String = {
        var objcName: String = self.name
        for para in self.paramaters {
            let text = para.name.capitalized
            objcName += text + ":"
        }
        return objcName
    }()
    
    //
    var parseStatus: BSFunctionNodeParseStatus = .name
    
    //BSNode protocol
    var isFullfilled: Bool = false {
        didSet {
            if isFullfilled {
                self.parseStatus = .impEnd
            }
        }
    }
    
    var nodeType: BSNodeType {
        return .functionType
    }
    
    func appendLeafNode(_ node: BSNode) {
        switch node.nodeType {
        case .excuteObjcType:
            excuteNodes.append(node as! BSObjcExcuteNode)
        case .varibleType:
            paramaters.append(node as! BSVaribleNode)
        case .classType:
            fallthrough
        case .excuteObjcType:
            fallthrough
        case .functionType:
            fatalError()
        }
    }
    
    func setLastParamaterType(_ text: String) -> Void {
        let node = paramaters.last
        node?.type = text
    }
    
    //
    
    func objcMethodEncode() -> [String] {
        
        var types = [String]()
        types.append(BSTypeEncoding(returnType))
        types.append(contentsOf: ["@",":"])
        self.paramaters.forEach{ (para) in
            types.append(BSTypeEncoding(para.type))
        }
        return types
    }
}
