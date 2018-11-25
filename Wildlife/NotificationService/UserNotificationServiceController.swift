//
//  UserNotificationServiceController.swift
//  Wildlife
//
//  Created by Felix Eisenmenger on 25.10.17.
//  Copyright © 2017 Felix Eisenmenger. All rights reserved.
//

import Foundation
import UIKit

protocol backtToMenuFromUserNotify {
}

class UserNotificationServiceController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var emailAddresseText: UITextField!
    @IBOutlet weak var mobileNumberText: UITextField!
    @IBOutlet weak var picker: UIPickerView!
    var delegate: backtToMenuFromUserNotify?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        picker.dataSource = self
    }
    
    @IBAction func backToMenu(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func setButton(_ sender: Any) {
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 1 //change to fooChoices.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Change
        // self.fooChoices[row]
        self.view.endEditing(true)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "" //change to fooChoices[row]
    }
}
