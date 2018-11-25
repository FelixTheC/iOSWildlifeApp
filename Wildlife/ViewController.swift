//
//  ViewController.swift
//  Wildlife
//
//  Created by Felix Eisenmenger on 20.10.17.
//  Copyright © 2017 Felix Eisenmenger. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import CryptoSwift

class ViewController: UIViewController {
    
    var alamofireReuqest: RequestController = RequestController()
    var connectToInternet: Bool = false
    var userAllowed: Bool = false
    var url: String = ""
    var serviceUrl = ""
    let apiUrl = loginUrl
    var username: String!
 
    @IBOutlet weak var LoginButton: UIButton!
    @IBOutlet weak var Username: UITextField!
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var ErrorLabel: UILabel!
    
    @IBAction func onChange(_ sender: Any) {
        LoginButton.isUserInteractionEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func LoginButton(_ sender: Any) {
        if  self.alamofireReuqest.isConnectedToInternet() {
            LoginButton.isUserInteractionEnabled = false
            self.userAuth(url: eurekaClientUrl + self.apiUrl + "/" + self.Username.text! + "/" + ((self.Password.text)?.md5())!)
            self.username = self.Username.text!
        } else {
            if UserDefaults.standard.string(forKey: "username") != nil {
                if self.Username.text! == UserDefaults.standard.string(forKey: "username")! && (self.Password.text)?.md5() == UserDefaults.standard.string(forKey: "apiKey") {
                    self.username = UserDefaults.standard.string(forKey: "username")!
                    self.userAllowed = true
                    self.toMainMenu()
                } else {
                    self.ErrorLabel.isHidden = false
                    self.ErrorLabel.text = "Username or Password incorrect"
                }
            } else {
                self.present(alertNoInternet(btnTitle: "Noted" ,message: "Please activate wifi or mobile data"), animated: true, completion: nil)
            }
        }
    }
    
    func userAuth(url: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            Alamofire.request(url, method: .get).responseJSON { response in
                if response.result.isSuccess {
                    let loginSuccess: JSON = JSON(response.result.value!)
                    let check = self.checkJSONData(json: loginSuccess)
                    if check == true {
                        let userType = self.userTypeJSONData(json: loginSuccess)
                        UserDefaults.standard.set(String(userType), forKey: "userType")
                        UserDefaults.standard.set(self.username, forKey: "username")
                        //I hope you understand it
                        UserDefaults.standard.set((self.Password.text)?.md5(), forKey: "apiKey")
                    }
                    self.userAllowed = check
                    self.toMainMenu()
                } else {
                    self.ErrorLabel.isHidden = false
                    self.ErrorLabel.text = "Connection is broken"
                }
            }
        }
    }
    
    func toMainMenu() {
        if self.userAllowed {
            let db = Database()
            if checkWIFIAndMobileData() {
                DispatchQueue.global(qos: .background).async {
                    db.createPositionTable()
                    db.createNotificationTable()
                    getAnimalData(username: self.username, completion: { (result, response, error) in
                        
                    })
                    getCollarData(username: self.username, completion: { (result, response, error) in
                        
                    })
                }
            }
            performSegue(withIdentifier: "loginSegue", sender: Any?.self)
        } else {
            self.ErrorLabel.isHidden = false
            self.ErrorLabel.text = "Username or Password incorrect"
            LoginButton.isUserInteractionEnabled = false
        }
    }
    
    func checkJSONData(json: JSON) -> Bool {
        let tempValue = json["success"]
        if tempValue == "true" {
            return true
        } else {
            return false
        }
    }
    
    func userTypeJSONData(json: JSON) -> String{
        let tempValue = json["userType"]
        return tempValue.string!
    }
}

