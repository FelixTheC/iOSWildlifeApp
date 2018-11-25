//
//  Collar.swift
//  Wildlife
//
//  Created by Felix Eisenmenger on 19.06.18.
//  Copyright © 2018 Felix Eisenmenger. All rights reserved.
//

import Foundation

class Collar: CustomStringConvertible {
    var id: String
    var name: String
    var collarType: String
    var valid: Bool
    
    
    init(id: String, name: String, collarType: String, valid: Bool) {
        self.id = id
        self.name = name
        self.collarType = collarType
        self.valid = valid
    }
    
    var description: String {
        return self.id
    }
}
