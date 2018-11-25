//
//  MapSelectController.swift
//  Wildlife
//
//  Created by Felix Eisenmenger on 02.11.17.
//  Copyright © 2017 Felix Eisenmenger. All rights reserved.
//

import Foundation
import UIKit
import SwiftRangeSlider

protocol backtToMenuFromMapSelect: class {
    
}

class MapSelectController: UIViewController, UITableViewDataSource, UITableViewDelegate, backToMapSelect, DatePopUpDelegate {

    
    weak var delegate: backtToMenuFromMapSelect?
    var choices = ["Animal", "Collar"]
    var choice: Array<String>?
    var selected: String?
    var idForMap: String?
    var idsForMap = Array<String>()
    var labelText: String = ""
    let db = Database()
    @IBOutlet weak var pickerTimeIntervall: UIPickerView!
    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var FailureLabel: UILabel!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var endBtn: UIButton!
    
    override func viewDidLoad() {
        self.startBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        self.endBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.activityIndicator.isHidden = true
        table.reloadData()
        self.idsForMap.removeAll()
        self.labelText = ""
        selectBtn.isHidden = true
        table.delegate = self
        table.dataSource = self
        table.allowsMultipleSelection = true
        table.backgroundColor = nil
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.choice == nil {
            return 0
        } else {
            return self.choice!.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectCell", for: indexPath)
        
        cell.backgroundColor = nil
        
        if ((self.choice?[indexPath.row]) != nil) {
            cell.textLabel?.text = self.choice?[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.selected == "collar" {
            if collarArray.count > 0 {
                if (collarMap[collarArray[indexPath.row]] != nil) {
                    self.idsForMap.append(collarMap[collarArray[indexPath.row]]!)
                }
            }
        } else {
            if animalArray.count > 0 {
                if (animalDataArray.count >= indexPath.row) {
                    let animal = animalDataArray[indexPath.row - 1]
                    self.idsForMap.append(animal.id)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        var deselected: String?
        if indexPath.row > 0 {
            if selected == "collar" {
                deselected = collarMap[collarArray[indexPath.row]]
            } else {
                let animal = animalDataArray[indexPath.row - 1]
                deselected = animal.id
            }
            let index = self.idsForMap.index(of: deselected!)
            self.idsForMap.remove(at: index!)
        }
    }
    
    @IBAction func btn1(_ sender: Any) {
        print(startDate as Any)
        self.choice = animalArray
        if animalArray.count > 0 {
            self.selectBtn.isHidden = false
        } else {
            self.selectBtn.isHidden = true
        }
        self.selected = "animal"
        table.reloadData()
    }
    
    @IBAction func btn2(_ sender: Any) {
        self.choice = collarArray
        if collarArray.count > 0 {
            self.selectBtn.isHidden = false
        } else {
            self.selectBtn.isHidden = true
        }
        self.selected = "collar"
        table.reloadData()
    }
    
    @IBAction func backToMenu(_ sender: Any) {
        if allLocations.count > 0 {
            allLocations.removeAll()
        }
        if reallyAllLocations.count > 0 {
            reallyAllLocations.removeAll()
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func displayChoice(_ sender: Any) {
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        self.activityIndicator.hidesWhenStopped = true
        let startDate = "20" + (self.startBtn.titleLabel?.text)!
        let tmpDate = "20" + (self.endBtn.titleLabel?.text)!
        let endDate = convertIsoDateToString(date: addOneDay(date: convertStringToDate(isoDate: tmpDate)))
        let limit = 0
        if self.idsForMap.count > 0 {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            var counter = 1
            DispatchQueue.global(qos: .userInitiated).async {
                if UserDefaults.standard.bool(forKey: "switchStatus") == false || checkForWifiOnly() {
                    self.getDataFromServer(ids: self.idsForMap, startDate: startDate, endDate: endDate)
                }
                else {
                    if checkForWifiOnly() {
                        self.getDataFromServer(ids: self.idsForMap, startDate: startDate, endDate: endDate)
                    } else {
                        for id in self.idsForMap{
                            self.db.getLastPositions(collarId: Int(id)!, limit: limit, collarOrAnimal: self.selected!, startDate: startDate, endDate: endDate, completion: { (result, response, error) in
                                if result {
                                    if self.selected! == "collar" {
                                        self.labelText += id + ", "
                                    } else {
                                        for i in animalDataArray {
                                            if i.id == id {
                                                self.labelText += i.name + ", "
                                            }
                                        }
                                    }
                                    if self.idsForMap.count == counter {
                                        self.choice?.removeAll()
                                        DispatchQueue.main.async {
                                            self.activityIndicator.stopAnimating()
                                            self.performSegue(withIdentifier: "mapViewSegue", sender: self)
                                        }
                                    } else {
                                        counter += 1
                                    }
                                } else {
                                    self.dismiss(animated: true, completion: nil)
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    func getDataFromServer(ids: Array<String>, startDate: String, endDate: String) {
        var counter = 1
            for id in ids {
                getLatLonAnimalByCollarAndTime(id: id, collarOrAnimal: self.selected!, date1: startDate, date2: endDate, completion: {(result, response, error) in
                    if result {
                        if self.selected! == "collar" {
                            self.labelText += id + ", "
                        } else {
                            for i in animalDataArray {
                                if i.id == id {
                                    self.labelText += i.name + ", "
                                }
                            }
                        }
                        self.db.insertArrayElementsInDB(map: allLocations, completion: { (result) in
                            
                        })
                        if self.idsForMap.count == counter {
                            self.choice?.removeAll()
                            self.activityIndicator.stopAnimating()
                            self.performSegue(withIdentifier: "mapViewSegue", sender: self)
                        } else {
                            counter += 1
                        }
                        
                    } else {
                        self.activityIndicator.isHidden = true
                        if !checkWIFIAndMobileData()  && !UserDefaults.standard.bool(forKey: "switchStatus") {
                            self.present(alertNoInternet(btnTitle: "Noted",
                                                         message: "You have neither enabled wifi, mobile data nor the use of offline data"),
                                         animated: false,
                                         completion: nil)
                        } else {
                            self.FailureLabel.isHidden = false
                        }
                    }
                })
            }
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapViewSegue" {
            let mapVC = segue.destination as! MapViewController
            mapVC.textFromSelect = self.labelText
            mapVC.delegate = self
        } else if segue.identifier == "getStartDateSegue" {
            let startDateC = segue.destination as! ModuleDatePopUpController
            startDateC.startOrEnd = "s"
            startDateC.btn = self.startBtn
            startDateC.delegate = self
        } else if segue.identifier == "getEndDateSegue" {
            let endDateC = segue.destination as! ModuleDatePopUpController
            endDateC.startOrEnd = "e"
            endDateC.btn = self.endBtn
            endDateC.delegate = self
        }
    }
    
    func call(text: String?, startOrEnd: String?, btn: UIButton?) {
        if text == nil {
            
        } else {
            if startOrEnd == "s" {
                self.startBtn = btn
                self.startBtn.titleLabel?.text = text!
            } else {
                self.endBtn = btn
                self.endBtn.titleLabel?.text = text!
            }
        }
    }
}
