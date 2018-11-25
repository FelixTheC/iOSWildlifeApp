//
//  Position.swift
//  Wildlife
//
//  Created by Felix Eisenmenger on 19.06.18.
//  Copyright © 2018 Felix Eisenmenger. All rights reserved.
//

import Foundation

class Position: CustomStringConvertible {
    let id: String
    let name: String
    let idPosition: String
    let latitude: String
    let longitude: String
    let sunAngle: String
    let acquistionTime: String
    
    init(id: String, name: String, idPosition: String, latitude: String, longitude: String, sunAngle: String, acquistionTime: String) {
        self.id = id
        self.name = name
        self.idPosition = idPosition
        self.latitude = latitude
        self.longitude = longitude
        self.sunAngle = sunAngle
        self.acquistionTime = acquistionTime
    }
    
    var description: String {
        return self.id
    }
}

var positionDataArray = Array<Position>()
