//
//  BSFunctionNode+JS.swift
//  SwiftComplierDemo
//
//  Created by AugustRush on 12/2/16.
//  Copyright © 2016 August. All rights reserved.
//

import Foundation

extension BSFunctionNode: TransferToJS {
    //
    func asJS() -> String {
        let js = ""
        return js
    }
    
    func asJS(InClassNode node: BSClassNode) -> String {
        let prefix = node.name + "_"
        let hasPara = paramaters.count > 0

        var js = String.init(format: "function %@(%@,%@", prefix + name,BSSelfFlag,BSSelectorFlag);
        if hasPara {
            for v in paramaters {
                let sep =  ","
                js += (sep + v.name)
            }
        }
        js += ") {\n"
        
        for excute in excuteNodes {
            if excute.nodeType == .excuteObjcType {
                let excuteObjc = excute as! BSObjcExcuteNode
                var selName = excuteObjc.selector
                if excuteObjc.isSetter {
                    selName = "set" + excuteObjc.selector.firstCharUppercase() + ":"
                }
                var excuteCode = String.init(format: "%@(%@,'%@',[", BSCallingObjectCMethodJsvaScriptName,excuteObjc.caller,selName!)
                
                for (index,para) in excuteObjc.paramaters.enumerated() {
                    let sep = (index < paramaters.count - 1) ? ",":""
                    excuteCode += (para + sep)
                }
                //add suffix
                excuteCode += "]);\n"
                
                if excuteObjc.needDefineTempVar {
                    excuteCode = String.init(format: "var %@ = %@", excuteObjc.tempVarName,excuteCode)
                }
                
                js += excuteCode
            }
        }
        
        js += "\n}\n"
        return js
    }
    
}
