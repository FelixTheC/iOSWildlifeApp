//
//  Animal.swift
//  Wildlife
//
//  Created by Felix Eisenmenger on 19.06.18.
//  Copyright © 2018 Felix Eisenmenger. All rights reserved.
//

import Foundation

class Animal: CustomStringConvertible {
    
    var id: String
    var name: String
    var createdBy: String
    var age: String
    var sex: String
    var species: String

    init(id: String, name: String, createdBy: String, age: String, sex: String, species: String) {
        self.id = id
        self.name = name
        self.createdBy = createdBy
        self.age = age
        self.sex = sex
        self.species = species
    }
    
    var description: String {
        return self.id
    }
}

var animalDataArray = Array<Animal>()
