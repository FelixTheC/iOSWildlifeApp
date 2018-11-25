//
//  SelectAnimalCollarCompassController.swift
//  Wildlife
//
//  Created by Felix Eisenmenger on 25.10.17.
//  Copyright © 2017 Felix Eisenmenger. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

protocol getAinimalCollarDelegate {
}

class SelectAnimalCollarCompassController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var delegate: getAinimalCollarDelegate?
    var collars: Array = collarArray
    var animals: Array = animalArray
    var id: Int?
    var selected = ""
    
    @IBOutlet weak var animalPicker: UIPickerView!
    @IBOutlet weak var collarPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animalPicker.delegate = self
        animalPicker.dataSource = self
        collarPicker.delegate = self
        collarPicker.dataSource = self
    }
    
    func dbUse() -> Bool {
        var dbUse = false
        if UserDefaults.standard.object(forKey: "dataBaseUsage") != nil {
            dbUse = true
        }
        return dbUse
    }
    
    @IBAction func returnButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func setBtn(_ sender: Any) {
        if !checkWIFIAndMobileData() && !UserDefaults.standard.bool(forKey: "switchStatus") {
            self.present(alertNoInternet(btnTitle: "Noted",
                                         message: "You have neither enabled wifi, mobile data nor the use of offline data"),
                         animated: false,
                         completion: nil)
        } else {
            let db = Database()
            if UserDefaults.standard.bool(forKey: "switchStatus") {
                db.getLastPosition(collarId: Int(self.id!), collarOrAnimal: self.selected, completion: {(result, response, error) in
                    if result {
                        self.getSelectedForCompass()
                        self.dismiss(animated: true, completion:  nil)
                    }
                })
            } else {
                getLatLonAnimalByCollar(id: String(self.id!), collarOrAnimal: self.selected, completion: {(result, response, error) in
                    if result {
                        self.getSelectedForCompass()
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var counter = self.animals.count
        if self.animals.count == 1 {
            counter = 1
        }
        
        if pickerView == collarPicker {
            counter = self.collars.count
        }
        
        return counter
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == animalPicker {
            if self.animals.count < 1 {
                self.animals[0] = "Nothing to display"
                return "Nothing to display"
            } else {
                return self.animals[row]
            }
        } else {
            if self.collars.count < 1 {
                self.collars[0] = "Nothing to display"
                return "Nothing to display"
            } else {
                return self.collars[row]
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == animalPicker {
            if animalDataArray.count >= row {
                let animal = animalDataArray[row - 1]
                self.id = Int(animal.id)
                self.selected = "animal"
            }
        } else {
            if collarMap[self.collars[row]] != nil {
                self.id = Int(collarMap[self.collars[row]]!)
                self.selected = "collar"
            }
        }
    }
    
    func getSelectedForCompass(){
        if self.selected == "collar" {
            for (_, value) in collarMap.enumerated(){
                if value.value == String(self.id!) {
                    selectedForCompass = value.key
                }
            }
        } else {
            let animal = animalDataArray.first(where: { Int($0.id) == self.id!})
            selectedForCompass = animal?.name
        }
    }
}
