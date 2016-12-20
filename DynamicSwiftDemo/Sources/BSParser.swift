//
//  BSParser.swift
//  SwiftCompilerDemo
//
//  Created by AugustRush on 11/29/16.
//  Copyright © 2016 August. All rights reserved.
//

import Foundation

public enum BSParserError: Error {
    case unexpectedToken
}

struct BSParser {
    
    private var tokens: [BSToken]
    
    init(tokens: [BSToken]) {
        self.tokens = tokens
    }
    
    
    func parseToASTNodes() throws -> [BSNode] {
        if tokens.count == 0 {
            throw BSParserError.unexpectedToken
        }
        
        var nodes = [BSNode]()
        
        var parseTempNodeIndex = 0 // Invalidate index
        var templateNodes = [BSNode]()
        var parseFuncTempIndex = NSNotFound // Invalidate temp func index
        
        
        // temp var
        let tempVarPrefix = "_bs_tempVar"
        var tempVarNum = 0
        let tempVarName = { () -> String in
            tempVarNum += 1
            return tempVarPrefix + String(tempVarNum)
        }
        
        // for excute node var name used
        var excuteNeedLink = false
        var excuteIsWatingRight = false
        var leftTempVarName = String()
        var rightTempVarName = String()
        // clean temp var of excute parse when finished one line
        let oneLineExcuteFinishedClean = {
            leftTempVarName.removeAll()
            rightTempVarName.removeAll()
            parseFuncTempIndex = NSNotFound
        }
        
        // get last node type
        let curParseTmpNodeTypeIs: (BSNodeType) -> Bool = {
            if templateNodes.count > parseTempNodeIndex {
                return templateNodes[parseTempNodeIndex].nodeType == $0
            }
            return false
        }
        // parse node finish handler
        let parseNodeFinishedHandler = { (isExcute: Bool) -> Void in
            var finishedNode = templateNodes[parseTempNodeIndex]
            finishedNode.isFullfilled = true
            //remove fullfilled node
            templateNodes.remove(at: parseTempNodeIndex)
            //
            
            if isExcute {
                if parseFuncTempIndex != NSNotFound {
                    let function = templateNodes[parseFuncTempIndex] as! BSFunctionNode
                    function.appendLeafNode(finishedNode)
                    parseTempNodeIndex -= 1
                }
            } else {
                if parseTempNodeIndex > 0 {
                    parseTempNodeIndex -= 1
                    let node = templateNodes[parseTempNodeIndex]
                    if !node.isFullfilled {
                        node.appendLeafNode(finishedNode)
                    } else {
                        print("shouldn't be fullfilled!")
                    }
                } else {
                    //
                    nodes.append(finishedNode)
                }
            }
        }
        
        // append new node
        
        let appendNewTempNode: (BSNode) -> Void = {
            templateNodes.append($0)
            parseTempNodeIndex = templateNodes.count - 1
        }
        
        //keyword
        let handleKeyword: (BSKeyword) -> Void = { (kw) in
            
            var node: BSNode!
            
            switch kw {
            case .class_:
                if curParseTmpNodeTypeIs(.classType) {
                    let function = BSFunctionNode()
                    function.type = .class_
                    node = function
                } else {
                    node = BSClassNode()
                }
            case .override:
                if !curParseTmpNodeTypeIs(.functionType) {
                    let function = BSFunctionNode()
                    function.isOverride = true
                    node = function
                }
            case .function:
                if !curParseTmpNodeTypeIs(.functionType) {
                    node = BSFunctionNode()
                }
            case .return_:
                print("return")
            case .weak:// prepared to declare an varible
                if curParseTmpNodeTypeIs(.classType) {
                    let classNode = templateNodes.last as! BSClassNode
                    if classNode.parseStatus == .impStart {
                        let varible = BSVaribleNode()
                        varible.memPolicy = .weak
                        node = varible
                    }
                }
            case .varible:
                if curParseTmpNodeTypeIs(.classType) {
                    let classNode = templateNodes.last as! BSClassNode
                    if classNode.parseStatus == .impStart {
                        let varible = BSVaribleNode()
                        node = varible
                    }
                }
            case .const:
                print("let")
            case .super_:
                print("super")
            case .self_:
                if curParseTmpNodeTypeIs(.functionType) {
                    let function = templateNodes.last as! BSFunctionNode
                    if function.parseStatus == .impStart {
                        parseFuncTempIndex = parseTempNodeIndex
                        let excute = BSObjcExcuteNode()
                        excute.caller = BSSelfFlag
                        appendNewTempNode(excute)
                    }
                }
            }
            
            if let n = node {
                appendNewTempNode(n)
            }
        }
        
        //symbol
        let handleSymbol: (BSSymbol) -> Void = { (sym) in
            switch sym {
            case .colon: // :
                if curParseTmpNodeTypeIs(.functionType) {
                    let function = templateNodes.last as! BSFunctionNode
                    if function.parseStatus == .paraStart {
                        function.parseStatus = .paraType
                    }
                } else if curParseTmpNodeTypeIs(.classType) {
                    let classNode = templateNodes.last as! BSClassNode
                    if classNode.parseStatus == .name {
                        classNode.parseStatus = .superClass
                    }
                } else if curParseTmpNodeTypeIs(.varibleType) {
                    let varible = templateNodes.last as! BSVaribleNode
                    if varible.parseStatus == .name {
                        varible.parseStatus = .typeAssign
                    }
                }
            case .oparent: // (
                if curParseTmpNodeTypeIs(.functionType) {
                    let function = templateNodes.last as! BSFunctionNode
                    function.parseStatus = .paraStart
                }
            case .cparent: // )
                if curParseTmpNodeTypeIs(.functionType) {
                    let function = templateNodes.last as! BSFunctionNode
                    function.parseStatus = .paraEnd
                }
            case .obrace: // {
                if curParseTmpNodeTypeIs(.functionType) {
                    let function = templateNodes.last as! BSFunctionNode
                    function.parseStatus = .impStart
                } else if curParseTmpNodeTypeIs(.classType) {
                    let classNode = templateNodes.last as! BSClassNode
                    classNode.parseStatus = .impStart
                }
            case .cbrace: // }
                if curParseTmpNodeTypeIs(.functionType) {
                    parseNodeFinishedHandler(false)
                    parseFuncTempIndex = NSNotFound
                } else if curParseTmpNodeTypeIs(.classType) {
                    parseNodeFinishedHandler(false)
                }
            case .comma: // ,
                if curParseTmpNodeTypeIs(.functionType) {
                    let function = templateNodes.last as! BSFunctionNode
                    if function.parseStatus == .paraType {
                        function.parseStatus = .paraStart
                    }
                }
            case .exclamation: // !
                if curParseTmpNodeTypeIs(.varibleType) {
                    let varible = templateNodes.last as! BSVaribleNode
                    if varible.parseStatus == .typeAssign {
                        parseNodeFinishedHandler(false)
                    }
                }
            case .arrowr: // ->
                if curParseTmpNodeTypeIs(.functionType) {
                    let function = templateNodes.last as! BSFunctionNode
                    if function.parseStatus == .paraEnd {
                        function.parseStatus = .returnStart
                    }
                }
            case .dit: // .
                if curParseTmpNodeTypeIs(.excuteObjcType) {
                    let excute = templateNodes.last as! BSObjcExcuteNode
                    switch excute.parseStatus {
                    case .caller:
                        excute.parseStatus = .selector
                    case .paras:
                        excute.isSetter = false
                        excute.needDefineTempVar = true
                        let varName = tempVarName()
                        excute.tempVarName = varName
                        parseNodeFinishedHandler(true)
                        leftTempVarName = varName
                        excuteNeedLink = true
                    default:
                        print("excute node un handle")
                    }
                } else if curParseTmpNodeTypeIs(.functionType) {
                    
                }
            case .equal: // =
                if curParseTmpNodeTypeIs(.excuteObjcType) {
                    let excute = templateNodes.last as! BSObjcExcuteNode
                    excute.isSetter = true
                    excute.parseStatus = .paras
                    excuteIsWatingRight = true
                }
            case .semicolon:
                fallthrough
            case .newline:
                if curParseTmpNodeTypeIs(.excuteObjcType) {
                    parseNodeFinishedHandler(true)
                    if excuteIsWatingRight {
                        excuteIsWatingRight = false
                        let prevExcute = templateNodes.last as! BSObjcExcuteNode
                        prevExcute.paramaters.append(rightTempVarName)
                        parseNodeFinishedHandler(true)
                        //clear temp var name
                        oneLineExcuteFinishedClean()
                    }
                }
            default:
                print("ss is \(sym.rawValue)")
                break
            }
        }
        
        //undefine (common text)
        let handleUndefined: (String) -> Void = { (text) in
            if curParseTmpNodeTypeIs(.functionType) {
                
                let function = templateNodes.last as! BSFunctionNode
                
                switch function.parseStatus {
                case .name:
                    function.name = text
                case .paraStart:
                    let para = BSVaribleNode()
                    para.name = text
                    function.appendLeafNode(para)
                case .paraType:
                    function.setLastParamaterType(text)
                case .paraEnd:
                    print("para end")
                case .returnStart:
                    function.returnType = text
                case .impStart:
                    if excuteNeedLink {
                        let excute = BSObjcExcuteNode()
                        excute.caller = leftTempVarName
                        excute.selector = text
                        appendNewTempNode(excute)
                        leftTempVarName.removeAll()
                    }
                case .impEnd:
                    print("imp end")
                }
                
            } else if curParseTmpNodeTypeIs(.classType) {
                let classNode = templateNodes.last as! BSClassNode
                
                switch classNode.parseStatus {
                case .name:
                    classNode.name = text
                case .superClass:
                    classNode.superClass = text
                default:
                    break
                }
            } else if curParseTmpNodeTypeIs(.varibleType) {
                let varible = templateNodes.last as! BSVaribleNode
                switch varible.parseStatus {
                case .name:
                    varible.name = text
                case .typeAssign:
                    varible.type = text
                default:
                    break
                }
            } else if curParseTmpNodeTypeIs(.excuteObjcType) {
                let excute = templateNodes.last as! BSObjcExcuteNode
                switch excute.parseStatus {
                case .selector:
                    excute.selector = text
                    excute.parseStatus = .paras
                case .paras:
                    if excuteIsWatingRight {
                        let newExcute = BSObjcExcuteNode()
                        newExcute.caller = text
                        newExcute.needDefineTempVar = true
                        let varName = tempVarName()
                        newExcute.tempVarName = varName
                        rightTempVarName = varName
                        appendNewTempNode(newExcute)
                    }
                default:
                    print("somm text is \(text)")
                }
            }
        }
        
        //
        let handleConstText: (String) -> Void = { (text) in
            if excuteIsWatingRight {
                let excute = templateNodes.last as! BSObjcExcuteNode
                excute.paramaters.append(String.init(format: "'%@'", text))
                parseNodeFinishedHandler(true)
                oneLineExcuteFinishedClean()
            }
        }
        
        //
        for t in tokens {
                        
            switch t {
            case .keyword(let kw):
                handleKeyword(kw)
            case .symbol(let sym):
                handleSymbol(sym)
            case .undefined(let text):
                handleUndefined(text)
            case .constText(let text):
                handleConstText(text)
            }

            print("parsed token is \(t)")
        }
        
        return nodes
    }
}
