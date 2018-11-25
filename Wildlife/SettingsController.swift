//
//  SettingsController.swift
//  Wildlife
//
//  Created by Felix Eisenmenger on 24.10.17.
//  Copyright © 2017 Felix Eisenmenger. All rights reserved.
//

import Foundation
import UIKit

protocol backToMenuFromSettings {
}

class SettingsController: UIViewController{
    
    unowned let defaults = UserDefaults.standard
    let infoBtnTxt = "Available if use of offline data is allowed"
    let infoBtnUpdate = "Download- / Update- data"
    var delegate: backToMenuFromSettings?
    @IBOutlet weak var dataStorageValue: UISwitch!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var backToMenuBtn: UIButton!
    @IBOutlet weak var DownloadUpdateBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.activityIndicator.isHidden == false {
            self.activityIndicator.isHidden = true
        }
        if self.defaults.bool(forKey: "switchStatus") {
            self.dataStorageValue.setOn(true, animated: true)
            self.DownloadUpdateBtn.isUserInteractionEnabled = true
        } else {
            self.dataStorageValue.setOn(false, animated: true)
            self.DownloadUpdateBtn.isUserInteractionEnabled = false
        }
        if self.dataStorageValue.isOn {
            self.DownloadUpdateBtn.setTitle(self.infoBtnUpdate, for: UIControlState.normal)
        }
    }
    
    @IBAction func downloadUpdateBtn(_ sender: Any) {
        let db = Database()
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        self.activityIndicator.hidesWhenStopped = true
        DispatchQueue.global(qos: .background).async {
            for collar in collarArray {
                if collar != "" {
                    let id = collar.split(separator: " ").first!
                    let lastPosFromDb = db.getLastPositionSync(collarId: Int(String(id))!, collarOrAnimal: "collar")
                        if lastPosFromDb.count > 0 {
                            if Int(lastPosFromDb["idPosition"]!)! < Int(lastPos[String(id)]!)! {
                                getLastPositionsFromService(id: String(id), collarOrAnimal: "collar", lastPos: lastPos[String(id)]!)
                            }
                    } else {
                        let myGroup = DispatchGroup()
                        let dbGroup = DispatchGroup()
                        myGroup.enter()
                            getDataBetweenTime(date1: convertDateDateToString(date: getDateBeforeTwoWeeks(date: Date())).replacingOccurrences(of: " ", with:"%20"),
                                                     date2: convertDateDateToString(date: Date()).replacingOccurrences(of: " ", with: "%20"), dataArray: collarArray, isCollar: true, completion: {(result) in
                                                        if result {
                                                            myGroup.leave()
                                                        }
                            })
                            myGroup.notify(queue: DispatchQueue.global()) {
                                dbGroup.enter()
                                db.insertArrayElementsInDB(map: allLocations, completion: {(result) in
                                    if result {
                                        dbGroup.leave()
                                        allLocations.removeAll()
                                    }
                                })
                            }
                            dbGroup.notify(queue: DispatchQueue.main) {
                                self.activityIndicator.stopAnimating()
                            }
                        }
                    }
                }
            for animal in animalArray {
                if animal != "" {
                    let animal = animalDataArray.first(where: {$0.id == animal })
                    let id = animal?.id
                    let lastPosFromDb = db.getLastPositionSync(collarId: Int(id!)!, collarOrAnimal: "animal")
                    if lastPosFromDb.count > 0 {
                        if Int(lastPosFromDb["idPosition"]!)! < Int(lastPos[id!]!)! {
                            getLastPositionsFromService(id: id!, collarOrAnimal: "animal", lastPos: lastPos[id!]!)
                        }
                    } else {
                        let myGroup = DispatchGroup()
                        let dbGroup = DispatchGroup()
                        myGroup.enter()
                        getDataBetweenTime(date1: convertDateDateToString(date: getDateBeforeTwoWeeks(date: Date())).replacingOccurrences(of: " ", with:"%20"),
                                           date2: convertDateDateToString(date: Date()).replacingOccurrences(of: " ", with: "%20"), dataArray: animalArray, isCollar: false, completion: {(result) in
                                            if result {
                                                myGroup.leave()
                                            }
                        })
                        myGroup.notify(queue: DispatchQueue.global()) {
                            dbGroup.enter()
                            db.insertArrayElementsInDB(map: allLocations, completion: {(result) in
                                if result {
                                    dbGroup.leave()
                                }
                            })
                        }
                        dbGroup.notify(queue: DispatchQueue.main) {
                            self.activityIndicator.stopAnimating()
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func deletePhoneDatabaseBtn(_ sender: Any) {
        let db = Database()
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        self.activityIndicator.hidesWhenStopped = true
        db.dropTable(completion: {(result, response, error) in
            if result {
                self.activityIndicator.stopAnimating()
                self.dismiss(animated: true, completion: nil)
            }
        })
        DispatchQueue.global(qos: .background).async {
            db.createPositionTable()
            db.createNotificationTable()
        }
    }
    
    @IBAction func backToMenu(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dataStorageAction(_ sender: Any) {
        if self.dataStorageValue.isOn {
            self.defaults.set(true, forKey: "switchStatus")
            self.defaults.set(true, forKey: "dataBaseUsage")
            self.DownloadUpdateBtn.isUserInteractionEnabled = true
            self.DownloadUpdateBtn.setTitle(self.infoBtnUpdate, for: UIControlState.normal)
            self.DownloadUpdateBtn.titleLabel?.textAlignment = .center
        } else if self.dataStorageValue.isOn == false {
            self.defaults.removeObject(forKey: "dataBaseUsage")
            self.defaults.set(false, forKey: "switchStatus")
            self.DownloadUpdateBtn.isUserInteractionEnabled = false
            self.DownloadUpdateBtn.setTitle(self.infoBtnTxt, for: UIControlState.normal)
            self.DownloadUpdateBtn.titleLabel?.textAlignment = .left
        }
    }
}
