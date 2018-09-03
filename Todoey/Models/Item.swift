//
//  Item.swift
//  Todoey
//
//  Created by David Kittle on 9/2/18.
//  Copyright © 2018 David Kittle. All rights reserved.
//

import Foundation

// Had to add the "Codable" declaration below to eliminate the "Generic parameter 'Value' could not be inferred" error
// that popped up in TodoListViewController when implementing the encoder.
class Item: Codable{
    
    var title: String = ""
    var done: Bool = false
    
}
