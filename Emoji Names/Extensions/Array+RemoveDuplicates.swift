//
//  Array+RemoveDuplicates.swift
//  Emoji Names
//
//  Created by Cal Stephens on 11/19/17.
//  Copyright © 2017 Cal Stephens. All rights reserved.
//

import Foundation

extension Array where Element:Equatable {
    
    func removeDuplicates() -> [Element] {
        var result = [Element]()
        
        for value in self {
            if !result.contains(value) {
                result.append(value)
            }
        }
        
        return result
    }
    
}
