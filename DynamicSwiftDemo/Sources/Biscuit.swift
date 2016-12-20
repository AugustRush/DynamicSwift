//
//  Biscuit.swift
//  SwiftComplierDemo
//
//  Created by AugustRush on 12/2/16.
//  Copyright © 2016 August. All rights reserved.
//

import Foundation

internal let BSSelfFlag = "_bs_self"
internal let BSSelectorFlag = "_bs_sel_"

internal let _BSKeywords: [String:BSKeyword] = [BSKeyword.class_.rawValue: .class_,
                                       BSKeyword.function.rawValue: .function,
                                       BSKeyword.weak.rawValue: .weak,
                                       BSKeyword.override.rawValue: .override,
                                       BSKeyword.super_.rawValue: .super_,
                                       BSKeyword.return_.rawValue: .return_,
                                       BSKeyword.varible.rawValue: .varible,
                                       BSKeyword.const.rawValue: .const,
                                       BSKeyword.self_.rawValue: .self_]

internal let _BSSymbols: [String:BSSymbol] = [BSSymbol.colon.rawValue: .colon,
                                     BSSymbol.obrace.rawValue: .obrace,
                                     BSSymbol.cbrace.rawValue: .cbrace,
                                     BSSymbol.oparent.rawValue: .oparent,
                                     BSSymbol.cparent.rawValue: .cparent,
                                     BSSymbol.comma.rawValue: .comma,
                                     BSSymbol.dit.rawValue: .dit,
                                     BSSymbol.equal.rawValue: .equal,
                                     BSSymbol.dquote.rawValue: .dquote,
                                     BSSymbol.add.rawValue: .add,
                                     BSSymbol.minus.rawValue: .minus,
                                     BSSymbol.mutiplier.rawValue: .mutiplier,
                                     BSSymbol.divided.rawValue: .divided,
                                     BSSymbol.semicolon.rawValue: .semicolon,
                                     BSSymbol.exclamation.rawValue: .exclamation,
                                     BSSymbol.question.rawValue: .question,
                                     BSSymbol.newline.rawValue: .newline,
                                     BSSymbol.slash.rawValue: .slash,
                                     BSSymbol.arrowr.rawValue: .arrowr]


public func BSInstance(ForClassName name: String) -> AnyObject? {
    let bridge = BSJavaScriptBridge.sharedInstance()
    return bridge.getInstanceForClass(withName: name) as AnyObject
}

func classVarInJS(WithName name: String) -> String {
    return name + "_class"
}

func instanceVarInJS(WithName name: String) -> String {
    return name + "_instance"
}
