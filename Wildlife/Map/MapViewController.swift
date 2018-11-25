//
//  MapViewController.swift
//  Wildlife
//
//  Created by Felix Eisenmenger on 02.11.17.
//  Copyright © 2017 Felix Eisenmenger. All rights reserved.
//

import Foundation
import UIKit
import MapKit

protocol backToMapSelect {
}
class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, centerOnCollarId {
    
    var delegate: backToMapSelect?
    var textFromSelect: String?
    var locationManager = CLLocationManager()
    var artworks: [Artwork]?
    var userLat: Double?
    var userLong: Double?
    var counter = 0
    let regionRadius: CLLocationDistance = 10000
    var polymap = [String: [CLLocationCoordinate2D]]()
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var map: MKMapView!
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.global(qos: .userInteractive).async {
            self.setupLocationManager()
        }
        if UserDefaults.standard.bool(forKey: "switchStatus") && checkWIFIAndMobileData(){
            DispatchQueue.global(qos: .background).async {
                funcWriteIntoDB(data: reallyAllLocations)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            map.register(ArtworkMarkerView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        } else {
        }
        self.initLatiInitLongitude()
        self.checkIfArtworkOrArtworks()
        self.locationManager.startUpdatingLocation()
        self.setupLocationManager()
        map.delegate = self
        map.isScrollEnabled = true
        map.isZoomEnabled = true
        map.isRotateEnabled = true
        map.addAnnotations(artworks!)
        self.createPolylines()
        self.infoLabel.text = self.textFromSelect
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func initLatiInitLongitude() {
        if allLocations.count > 0 {
            let tempLatitude =  allLocations[allLocations.count - 1]["latitude"].unsafelyUnwrapped
            let tempLongitude = allLocations[allLocations.count - 1]["longitude"].unsafelyUnwrapped
            self.centerMapOnLocation(location: CLLocation(latitude: (Double(tempLatitude))!, longitude: (Double(tempLongitude))!))
        } else {
            self.centerMapOnLocation(location: CLLocation(latitude: 42.430504, longitude: 13.525795))
        }
    }
    
    func checkIfArtworkOrArtworks() {
        artworks = []
        if reallyAllLocations.count > 0 {
            if reallyAllLocations[0].first != nil {
                var start_end_counter = 0
                var idCounter = -1
                for location in reallyAllLocations {
                    var test = 0
                    idCounter += 1
                    let id = self.getIds()[idCounter]
                    for data in location {
                        test += 1                        
                        if id == data["collarId"] {
                            start_end_counter -= 1
                            let sunAngle = data["sunAngle"]
                            let tempLatitude = data["latitude"].unsafelyUnwrapped
                            let tempLongitude = data["longitude"].unsafelyUnwrapped
                            let tempTime = convertStringToIsoDate(isoDate: data["acquistionTime"].unsafelyUnwrapped)
                            var tempCollarId = data["collarId"].unsafelyUnwrapped
                            if data["animalName"] != nil && data["animalName"] != "" {
                                tempCollarId = data["animalName"].unsafelyUnwrapped
                            }
                            if (Double(tempLatitude) != nil){
                                if (test > 1 && test < location.count) {
                                    artworks!.append(Artwork(title: String(tempCollarId) + " " + tempTime,
                                                             locationName: "La: " + String(format: "%.3f", (Double(tempLatitude))!) + " Lo: " + String(format: "%.3f", (Double(tempLongitude))!),
                                                             discipline: self.getIds().index(of: id)! + 1,
                                                             coordinate: CLLocationCoordinate2D(latitude: (Double(tempLatitude))!, longitude: (Double(tempLongitude))!),
                                                             dayTime: "" + ((Double(sunAngle!)! <= -6.00) ? "night" : "day") ,
                                                             acquisition_time: tempTime))

                                } else {
                                    artworks!.append(Artwork(title: String(tempCollarId) + " " + tempTime,
                                                             locationName: "La: " + String(format: "%.3f", (Double(tempLatitude))!) + " Lo: " + String(format: "%.3f", (Double(tempLongitude))!),
                                                             discipline: self.getIds().index(of: id)! + 1,
                                                             coordinate: CLLocationCoordinate2D(latitude: (Double(tempLatitude))!, longitude: (Double(tempLongitude))!),
                                                             dayTime: "" + (test >= location.count ? "end" : "start"),
                                                             acquisition_time: tempTime))
                                }
                            }
                        }
                    }
                }
            } else {
                self.textFromSelect = "No data to display"
            }
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        map.setRegion(coordinateRegion, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        var counter = 0
        
        if location.horizontalAccuracy > 0 {
            self.userLat = location.coordinate.latitude
            self.userLong = location.coordinate.longitude
            self.locationManager.stopUpdatingLocation()
            if counter == 0 {
                map.addAnnotation(Artwork(title: "My Location",
                                          locationName: String(describing: Date()),
                                          discipline: 100,
                                          coordinate: CLLocationCoordinate2D(latitude: self.userLat!, longitude: self.userLong!),
                                          dayTime: "location",
                                          acquisition_time: ""))
            }
            
            counter += 1
        }
    }
    
    @IBAction func backToMapSelect(_ sender: Any) {
        reallyAllLocations.removeAll()
        allLocations.removeAll()
        infoLabel.text = ""
        map.removeAnnotations(artworks!)
        artworks!.removeAll()
        self.locationManager.stopUpdatingLocation()
        self.counter = 0
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "infoSegue" {
            let infoVC = segue.destination as! ModulePopUpController
            infoVC.labelString = infoLabel.text!
            infoVC.delegate = self
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var view : MKAnnotationView
        guard let artwork = annotation as? Artwork else { return nil }
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: artwork.identifier) {
            view = dequeuedView
        }else {
            //make a new view
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: artwork.identifier)
        }
        view.canShowCallout = true
        view.calloutOffset = CGPoint(x: -5, y: 5)
        view.rightCalloutAccessoryView = nil
        view.backgroundColor = artwork.markerTintColor
        switch artwork.dayTime {
        case "start":
            view.image = #imageLiteral(resourceName: "start")
        case "end":
            view.image = #imageLiteral(resourceName: "stop")
        case "day":
            view.image = #imageLiteral(resourceName: "new_sun-symbol")
        case "night":
            view.image = #imageLiteral(resourceName: "new_Moon")
        case "location":
            view.image = #imageLiteral(resourceName: "new_person-1")
            view.backgroundColor = nil
        default:
            print()
        }

        return view
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let lineView = MKPolylineRenderer(overlay: overlay)
            lineView.lineWidth = 2
            lineView.strokeColor = getLabelColor(row: Int(overlay.subtitle.unsafelyUnwrapped!)!)
            return lineView
        }
        return MKOverlayRenderer()
    }

    
    func getCollarLocation(latitude: Double?, longitude: Double?) {
        map.reloadInputViews()
        if latitude != nil {
            map.setCenter(CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!), animated: false)
        }
    }
    
    func getIds() -> [String] {
        var ids = [String]()
        for data in reallyAllLocations {
            for d in data{
                if ids.contains(d["collarId"]!) {
                    //nothing happens
                } else {
                    ids.append(d["collarId"]!)
                }
            }
        }
        return ids
    }
    
    func createPolylines() {
        let title = self.textFromSelect!
        var titleAsArray = title.split(separator: ",")
        for i in 0..<(titleAsArray.count - 1) {
            let animal = animalDataArray.first(where: { $0.name.trimmingCharacters(in: .whitespacesAndNewlines) == titleAsArray[i].trimmingCharacters(in: .whitespacesAndNewlines) })
            let realTitle = titleAsArray[i].trimmingCharacters(in: .whitespacesAndNewlines)
            var tmp_coords = Array<CLLocationCoordinate2D>()
            for data in artworks! {
                if data.title!.contains(realTitle.trimmingCharacters(in: .whitespacesAndNewlines)) {
                    tmp_coords.append(data.coordinate)
                } else if data.title!.contains(animal!.name) {
                    tmp_coords.append(data.coordinate)
                }
            }
            addPolylineToMap(coordinates: tmp_coords,
                             title: String(titleAsArray[i].trimmingCharacters(in: .whitespacesAndNewlines)),
                             subtitle: String(self.counter + 1))
            self.counter += 1
        }
    }
    
    func addPolylineToMap(coordinates: Array<CLLocationCoordinate2D>, title: String, subtitle: String) {
        print(coordinates)
        let polyline: MKPolyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        polyline.title = title
        polyline.subtitle = subtitle
        map.add(polyline)
    }
}
