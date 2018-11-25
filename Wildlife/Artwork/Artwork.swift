//
//  Artwork.swift
//  Wildlife
//
//  Created by Felix Eisenmenger on 03.11.17.
//  Copyright © 2017 Felix Eisenmenger. All rights reserved.
//

import Foundation
import MapKit

class Artwork: NSObject, MKAnnotation {
    var identifier = "position data"
    let title: String?
    let locationName: String
    let discipline: Int
    let dayTime: String
    let acquisition_time: String
    //let dayTime: UIImage
    let coordinate: CLLocationCoordinate2D
    var markerTintColor: UIColor {
        switch discipline {
        case 1:
            return UIColor.init(red: 255/255, green: 128/255, blue: 128/255, alpha: 1)
        case 2:
            return UIColor.init(red: 204/255, green: 0/255, blue: 204/255, alpha: 1)
        case 3:
            return .cyan
        case 4:
            return UIColor.init(red: 0/255, green: 255/255, blue: 153/255, alpha: 1)
        case 5:
            return .gray
        case 6:
            return UIColor.init(red: 102/255, green: 204/255, blue: 255/255, alpha: 1)
        case 7:
            return UIColor.init(red: 153/255, green: 0/255, blue: 51/255, alpha: 1)
        case 8:
            return UIColor.init(red: 102/255, green: 255/255, blue: 102/255, alpha: 1)
        case 9:
            return UIColor.init(red: 255/255, green: 51/255, blue: 0/255, alpha: 1)
        case 10:
            return UIColor.init(red: 153/255, green: 153/255, blue: 255/255, alpha: 1)
        case 11:
            return UIColor.init(red: 255/255, green: 255/255, blue: 204/255, alpha: 1)
        case 12:
            return UIColor.init(red: 102/255, green: 153/255, blue: 153/255, alpha: 1)
        case 13:
            return UIColor.init(red: 102/255, green: 102/255, blue: 153/255, alpha: 0.75)
        case 14:
            return UIColor.init(red: 255/255, green: 102/255, blue: 255/255, alpha: 1)
        case 15:
            return UIColor.init(red: 204/255, green: 255/255, blue: 153/255, alpha: 1)
        case 16:
            return UIColor.init(red: 255/255, green: 204/255, blue: 0/255, alpha: 1)
        case 17:
            return UIColor.init(red: 255/255, green: 51/255, blue: 153/255, alpha: 1)
        case 18:
            return UIColor.init(red: 0/255, green: 102/255, blue: 255/255, alpha: 1)
        case 100:
            return UIColor.init(red: 255/255, green: 204/255, blue: 0/255, alpha: 1)
        default:
            return .green
        }
    }
    
    init(title: String, locationName: String, discipline: Int, coordinate: CLLocationCoordinate2D, dayTime: String, acquisition_time: String) {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        self.dayTime = dayTime
        self.acquisition_time = acquisition_time
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
}
