//
//  BSLexer.swift
//  SwiftCompilerDemo
//
//  Created by AugustRush on 11/29/16.
//  Copyright © 2016 August. All rights reserved.
//

import Foundation

class BSLexer {
    
    public static func tokenlize(_ input: String) -> [BSToken] {
        
        var tokens = [BSToken]()
        var tempStr = String()
        var tempSym = String()
        var tempText = String()
        var isConstText = false // handle const text flag
        //
        let handleTempStr = {
            if !tempStr.isEmpty {
                let token = handleSeperatorAfter(tempStr)
                tokens.append(token)
                tempStr.removeAll()
            }
        }
        //
        let handleSymbol = {
            if !tempSym.isEmpty {
                let token = BSToken.symbol(_BSSymbols[tempSym]!)
                tokens.append(token)
                tempSym.removeAll()
            }
        }
        //handle const text
        let handleConstText = {
            let token = BSToken.constText(tempText)
            tokens.append(token)
            tempText.removeAll()
        }
        
        //
        for ch in input.characters {
            if isConstText && ch != "\"" {
                tempText.append(ch)
                continue
            }
            
            switch ch {
            case "a"..."z":
                fallthrough
            case "A"..."Z":
                tempStr.append(ch)
                handleSymbol()
            case "\"":
                if isConstText {
                    isConstText = false
                    handleConstText()
                } else {
                    handleTempStr()
                    handleSymbol()
                    isConstText = true
                }
            case ":","{","}","(",")",",",".","=","\"","+","*","/",";","!","?","\n","\\":
                handleTempStr()
                handleSymbol()
                tempSym.append(ch)
                handleSymbol()
            case "-",">":
                tempSym.append(ch)
            case " ":
                handleTempStr()
                handleSymbol()
            default:
                print("default \(ch)")
                break
            }
        }
        
        return tokens
    }
    
    private static func handleSeperatorAfter(_ text: String) -> BSToken {
        if let kw = _BSKeywords[text] {
            return BSToken.keyword(kw)
        }
        
        return BSToken.undefined(text)
    }
    
}
