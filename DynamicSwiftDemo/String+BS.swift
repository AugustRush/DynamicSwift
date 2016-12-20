//
//  String+BS.swift
//  DynamicSwiftDemo
//
//  Created by AugustRush on 12/10/16.
//  Copyright © 2016 August. All rights reserved.
//

import Foundation

extension String {
    
    func firstCharUppercase() -> String {
        var str = String()
        let start = self.index(self.startIndex, offsetBy: 1)
        str.append(self.substring(to: start).uppercased())
        str.append(self.substring(from: start))
        return str
    }
}
