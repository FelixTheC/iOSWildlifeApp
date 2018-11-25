//
//  ArtworkViews.swift
//  Wildlife
//
//  Created by Felix Eisenmenger on 03.11.17.
//  Copyright © 2017 Felix Eisenmenger. All rights reserved.
//

import Foundation
import MapKit

@available(iOS 11.0, *)
class ArtworkMarkerView: MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            // 1
            guard let artwork = newValue as? Artwork else { return }
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            // 2
            //image = artwork.dayTime
            markerTintColor = artwork.markerTintColor
            glyphText = String(describing: artwork.title?.suffix(2))
        }
    }
}
