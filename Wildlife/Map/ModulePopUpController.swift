//
//  ModulePopUpController.swift
//  Wildlife
//
//  Created by Felix Eisenmenger on 20.11.17.
//  Copyright © 2017 Felix Eisenmenger. All rights reserved.
//

import Foundation
import UIKit

protocol centerOnCollarId {
    func getCollarLocation(latitude: Double?, longitude: Double?)
}

class ModulePopUpController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var table: UITableView!
    var delegate: centerOnCollarId?
    var infoLables = ArraySlice<Substring>()
    var labelString = String()
    
    override func viewWillAppear(_ animated: Bool) {
        self.convertLabelStringToArray()
        self.table.delegate = self
        self.table.dataSource = self
    }
    
    override func viewDidLoad() {
        self.convertLabelStringToArray()
        super.viewDidLoad()
    }
    
    @IBAction func closeBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.infoLables.count < 1 {
            return 0
        } else {
            return self.infoLables.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        
        cell.textLabel?.text = String(self.infoLables[indexPath.row])
        cell.backgroundColor = getLabelColor(row: indexPath.row + 1)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var data = ["latitude": "42.430504", "longitude": "13.525795"]
        if reallyAllLocations.count >= indexPath.row {
            if (reallyAllLocations[indexPath.row].last != nil) {
                data = reallyAllLocations[indexPath.row].last!
            }
        }
        let tempLatitude = data["latitude"].unsafelyUnwrapped
        let tempLongitude = data["longitude"].unsafelyUnwrapped
        self.delegate?.getCollarLocation(latitude: (Double(tempLatitude)), longitude: Double(tempLongitude))
        self.dismiss(animated: true, completion: nil)
    }
    
    func convertLabelStringToArray() {
        let tempArray = self.labelString.split(separator: ",")
        self.infoLables = tempArray.dropLast()
    }
}
