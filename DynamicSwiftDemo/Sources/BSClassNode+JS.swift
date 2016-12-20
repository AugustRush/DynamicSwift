//
//  BSClassNode+JS.swift
//  SwiftComplierDemo
//
//  Created by AugustRush on 12/3/16.
//  Copyright © 2016 August. All rights reserved.
//

import Foundation

extension BSClassNode: TransferToJS {
    
    func asJS() -> String {
        let newLine = "\n"
        // class and instance var
        var js = registerClassForJS() + newLine
        // methods
        for node in instanceMethods {
            js += node.asJS() + newLine
        }
        return js
    }
    
    func registerClassForJS() -> String {
        let className = classVarInJS(WithName: name)
        let register = String.init(format: "var %@ = %@('%@','%@',%@_funcs);", className,BSRegisteClassBlockJavaScriptName,name,superClass,name)
        return register
    }
    
//    func instanceDeclareForJS() -> String {
//        let className = classVarInJS(WithName: name)
//        let instanceName = instanceVarInJS(WithName: name)
//        let instance = String.init(format: "var %@ = %@(%@,'init');", instanceName,BSCreateObjectBlockJavaScriptName,className)
//        
//        return instance
//    }
    
    // prepared environmrnt for js context
    func exportToJS(InContext context: JSContext) -> Void {
        let classPrefix = self.name + "_"
        
        var funcs = [[String:Any]]()
        for m in instanceMethods {
            let dict: [String:Any] = [BSFunctionObjcNameKey: m.objcaName,
                                      BSFunctionTypeKey: m.type.rawValue,
                                      BSFunctionJSNameKey: classPrefix + m.name,
                                      BSFunctionObjcEncodeKey: m.objcMethodEncode(),
                                      BSFunctionArgsCountKey: m.paramaters.count]
            funcs.append(dict)
            // export function to js
            let js = m.asJS(InClassNode: self)
            context.evaluateScript(js)
            print("function in js is \(js)")
        }
        let funcsValueName = String.init(format: "%@funcs", classPrefix)
        context.setObject(funcs, forKeyedSubscript: funcsValueName as NSString)
        let js = registerClassForJS()
        context.evaluateScript(js)
    }
}
