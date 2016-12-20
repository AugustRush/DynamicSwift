//
//  BSToken.swift
//  SwiftComplierDemo
//
//  Created by AugustRush on 12/2/16.
//  Copyright © 2016 August. All rights reserved.
//

import Foundation

enum BSToken {
    case keyword(BSKeyword)
    case symbol(BSSymbol)
    case constText(String)
    case undefined(String)
}

enum BSKeyword: String {
    case class_ = "class"
    case weak = "weak"
    case function = "func"
    case override = "override"
    case super_ = "super"
    case return_ = "return"
    case varible = "var"
    case const = "let"
    case self_ = "self"
}

enum BSSymbol: String {
    case colon = ":"
    case obrace = "{"
    case cbrace = "}"
    case oparent = "("
    case cparent = ")"
    case comma = ","
    case dit = "."
    case equal = "="
    case dquote = "\""
    case add = "+"
    case minus = "-"
    case mutiplier = "*"
    case divided = "/"
    case or = "~"
    case semicolon = ";"
    case exclamation = "!"
    case question = "?"
    case newline = "\n"
    case slash = "\\"
    case arrowr = "->"
}
