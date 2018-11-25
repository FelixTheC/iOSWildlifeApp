//
//  MenuController.swift
//  Wildlife
//
//  Created by Felix Eisenmenger on 20.10.17.
//  Copyright © 2017 Felix Eisenmenger. All rights reserved.
//

import UIKit

class MenuController: UIViewController, UIApplicationDelegate, backToMenuFromCompass, backToMenuFromSettings, backtToMenuFromAdminNotify, backtToMenuFromUserNotify, backtToMenuFromMapSelect {
    
    @IBOutlet weak var compassBtn: UIStackView!
    @IBOutlet weak var settingsBtn: UIView!
    @IBOutlet weak var mapBtn: UIView!
    @IBOutlet weak var notifyBtn: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var infoLabel: UILabel!
    var timer: Timer?
    let defaultKeyNotification: String = "userType"
    let username: String = UserDefaults.standard.string(forKey: "username")!
    
    
    override func viewWillAppear(_ animated: Bool) {
        stopActivityAnimation()
        DispatchQueue.global(qos: .background).async {
            for collar in collarArray {
                if collar != "" {
                    let id = collar.split(separator: " ")[0]
                    getLastPosFromService(id: String(id), collarOrAnimal: "collar")
                }
            }
        }
//        if checkWIFIAndMobileData() {
//            DispatchQueue.global(qos: .background).async {
//                getAnimalCount(username: self.username)
//                getCollarCount(username: self.username)
//            }
//            if animalCount != nil || animalCount == nil {
//                if animalCount != (animalArray.count - 1) {
//                    if animalCount != nil {
//                        if animalCount! < (animalArray.count - 1) {
//                            animalArray.removeAll()
//                        }
//                    }
//                    self.startActivityAnimation(notify: "Please wait until your data will be fetched")
//                    getAnimalData(username: username, completion: { (result, response, error) in
//                        //@TODO idea for function return variable
//                        if result {
//                            self.stopActivityAnimation()
//                        } else {
//
//                        }
//                    })
//                }
//            }
//            if collarCount != nil || collarCount == nil {
//                if collarCount != (collarArray.count - 1) {
//                    if collarCount != nil {
//                        if collarCount! < (collarArray.count - 1) {
//                            collarArray.removeAll()
//                        }
//                    }
//                    self.startActivityAnimation(notify: "Please wait until your data will be fetched")
//                    getCollarData(username: username, completion: { (result, response, error) in
//                        //@TODO idea for function return variable
//                        if result {
//                            self.stopActivityAnimation()
//                        } else{
//
//                        }
//                    })
//                }
//            }
        
//                        getUserByUserGroupAdmin(admin: self.username, completion: {(result, response, error) in
//                            if result {
//                                self.stopActivityAnimation()
//                            }
//                        })
//        }
    }
    
    func startActivityAnimation(notify: String) {
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        self.infoLabel.isHidden = false
        self.infoLabel.text = notify
    }

    func stopActivityAnimation() {
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
        self.infoLabel.isHidden = true
    }

    func stopActivityAnimationWithError() {
        self.stopActivityAnimation()
        self.infoLabel.isHidden = false
        self.infoLabel.text = "Cannot connect to database"
    }
    
    @IBAction func showCompass(_ sender: Any) {
        performSegue(withIdentifier: "compassSegue", sender: self)
    }
    
    @IBAction func showMapSelect(_ sender: Any) {
        performSegue(withIdentifier: "mapSelectSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "compassSegue" {
            let compassVC = segue.destination as! CompassController
            compassVC.delegate = self
        } else if segue.identifier == "settingsSegue" {
            let settingsVC = segue.destination as! SettingsController
            settingsVC.delegate = self
        } else if segue.identifier == "adminNotificationSegue" {
            let adminNotifyVC = segue.destination as! AdminNotificationServiceController
            adminNotifyVC.delegate = self
        } else if segue.identifier == "userNotificationSegue" {
            let userNotifyVC = segue.destination as! UserNotificationServiceController
            userNotifyVC.delegate = self
        } else if segue.identifier == "mapSelectSegue" {
            let mapSelectVC = segue.destination as! MapSelectController
            mapSelectVC.delegate = self
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func notificationService(_ sender: Any) {
        if UserDefaults.standard.string(forKey: self.defaultKeyNotification) != nil {
            let userType = UserDefaults.standard.string(forKey: self.defaultKeyNotification)
            if userType == "ADMIN" {
                performSegue(withIdentifier: "adminNotificationSegue", sender: Any?.self)
            } else if userType == "USER" {
                performSegue(withIdentifier: "userNotificationSegue", sender: Any?.self)
            } else {
                
            }
        }
    }
    
    @IBAction func resetApp(_ sender: Any) {
        let db = Database()
        UserDefaults.standard.removeObject(forKey: "userType")
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "switchStatus")
        UserDefaults.standard.removeObject(forKey: "dataBaseUsage")
        resetArrays()
        db.dropTable(completion: {(result, response, error) in
            if result {
                self.performSegue(withIdentifier: "logoutSegue", sender: self)
            }
        })
    }
}
