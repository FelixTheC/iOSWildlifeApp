//
//  CreateUserNotificationController.swift
//  Wildlife
//
//  Created by Felix Eisenmenger on 25.10.17.
//  Copyright © 2017 Felix Eisenmenger. All rights reserved.
//

import Foundation
import UIKit

protocol backtToAdminNotify {
    
}

class CreateUserNotificationController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var delegate: backtToAdminNotify?
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var collarPicker: UIPickerView!
    var userId: String?
    var collarId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        picker.dataSource = self
        collarPicker.delegate = self
        collarPicker.dataSource = self
    }
    
    @IBAction func backToAdminPage(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == picker {
            return userArray.count
        } else if pickerView == collarPicker {
            return collarArray.count
        } else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == picker {
            return userArray[row]
        } else if pickerView == collarPicker {
            return collarArray[row]
        } else {
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == picker {
            if userArray.count > 0 {
                self.userId = userMap[userArray[row]]
            }
        } else if pickerView == collarPicker {
            if collarArray.count > 1 {
                self.collarId = collarMap[collarArray[row]]
            }
        }
    }
}
