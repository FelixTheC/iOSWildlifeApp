//
//  CompassController.swift
//  Wildlife
//
//  Created by Felix Eisenmenger on 24.10.17.
//  Copyright © 2017 Felix Eisenmenger. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

protocol backToMenuFromCompass {
}

class CompassController:UIViewController, CLLocationManagerDelegate, getAinimalCollarDelegate {
    
    var locationManager = CLLocationManager()
    var animalLong: CLLocationDegrees?
    var animalLat: CLLocationDegrees?
    var heading: CGFloat = 0
    var momentanLocation: CLLocation?
    var delegate: backToMenuFromCompass?
    
    @IBOutlet weak var animalLocationLabel: UILabel!
    @IBOutlet weak var userLocationLabel: UILabel!
    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if lastLocation.count != 0 {
            self.animalLat = lastLocation["latitude"]!
            self.animalLong = lastLocation["longitude"]!
            animalLocationLabel.numberOfLines = 0
            animalLocationLabel.text = "Lat: " + String(format: "%.5f", self.animalLat ?? 00) + " Long: " + String(format: "%.5f", self.animalLong ?? 00) + "\n as your north"
            animalLocationLabel.textColor = UIColor(red: 144/255, green: 6/255, blue: 6/255, alpha: 1)
            userLocationLabel.isHidden = false
            userLocationLabel.text = selectedForCompass!
            self.setupLocationManager()
        } else {
            animalLocationLabel.text = "Please select a animal or a collar as destination "
            userLocationLabel.isHidden = true
            distanceLabel.text = "Have a nice day"
        }
    }
    
    @IBAction func backtToMainMenu(_ sender: Any) {
        locationManager.stopUpdatingHeading()
        locationManager.stopUpdatingLocation()
        lastLocation.removeAll()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectAnimalOController(_ sender: Any) {
        performSegue(withIdentifier: "selectAnimalOCollar", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if segue.identifier == "selectAnimalOCollar" {
            let selectVC = segue.destination as! SelectAnimalCollarCompassController
            selectVC.delegate = self
       }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.headingFilter = 5
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let animalLoctaion: CLLocation = CLLocation.init(latitude: self.animalLat!, longitude: self.animalLong!)
        
        if location!.horizontalAccuracy > 0 {
            self.momentanLocation = location!
            //userLocationLabel.text = "Lat: " + String(format: "%.5f", self.momentanLocation?.coordinate.latitude ?? 00) + " Long: " + String(format: "%.5f", self.momentanLocation?.coordinate.longitude ?? 00)
            formatDistance(distance: self.momentanLocation!.distance(from: animalLoctaion)/1000)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.heading = CGFloat(newHeading.trueHeading).degreesToRadians
        let rotation = self.bearingToLocationRadian(self.momentanLocation!)
        let degree =  self.heading - rotation
        self.rotate(degree: degree)
    }
    
    
    
    
    func formatDistance(distance: Double) {
        if distance >= 1.0 {
            self.distanceLabel.text = String(format:"%.2f Km", distance)
        } else if distance < 1.0 {
            self.distanceLabel.text = String(format:"%.2f m", (distance*1000))
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.userLocationLabel.text = "Own location unavailable"
    }
    
    func rotate(degree: CGFloat) {
        UIView.animate(withDuration: 0.5, animations: {
            self.arrowImage.transform = CGAffineTransform(rotationAngle: degree)
        })
    }
    
    func bearingToLocationRadian(_ myLocation: CLLocation) -> CGFloat {
        let lat1 = CGFloat(self.animalLat!).degreesToRadians //destination location
        let lon1 = CGFloat(self.animalLong!).degreesToRadians //destination location
        
        let lat2 = myLocation.coordinate.latitude.degreesToRadians //my location
        let lon2 = myLocation.coordinate.longitude.degreesToRadians //my location
        
        let dLon =  lon1 - CGFloat(lon2)
        
        let x = cos(CGFloat(lat2)) * sin(dLon)
        let y = (cos(lat1) * sin(CGFloat(lat2))) - (sin(lat1) * cos(CGFloat(lat2)) * cos(dLon))
        let radiansBearing = atan2(x, y)
    
        return CGFloat(radiansBearing)
    }
    
    func bearingToLocationDegrees(destinationLocation: CLLocation) -> CGFloat {
        return bearingToLocationRadian(destinationLocation).radiansToDegrees
    }
}
extension CGFloat {
    var degreesToRadians: CGFloat { return -1.0 * self * .pi / 180 }
    var radiansToDegrees: CGFloat { return -1.0 * self * 180 / .pi }
    var forDisplaying: CGFloat { return -1.0 * .pi * self / 180 }
}

private extension Double {
    var degreesToRadians: Double { return Double(CGFloat(self).degreesToRadians) }
    var radiansToDegrees: Double { return Double(CGFloat(self).radiansToDegrees) }
}
