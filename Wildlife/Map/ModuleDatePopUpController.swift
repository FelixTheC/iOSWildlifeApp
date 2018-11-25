//
//  ModuleDatePopUpController.swift
//  Wildlife
//
//  Created by F Eisenmenger on 30.04.18.
//  Copyright © 2018 Felix Eisenmenger. All rights reserved.
//

import Foundation
import UIKit

protocol DatePopUpDelegate {
    func call(text: String?, startOrEnd: String?, btn: UIButton?)
}
class ModuleDatePopUpController: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    var delegate: DatePopUpDelegate?
    var segueTxt: String?
    var dateTxt: String?
    var startOrEnd: String?
    var btn: UIButton?
    var date: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func datePickerChanged(_ sender: Any) {
        self.dateTxt = getDateAsString(date: datePicker.date)
    }
    
    @IBAction func selectBtn(_ sender: Any) {
        if self.dateTxt == nil {
            self.dateTxt = getDateAsString(date: Date())
        }
        if self.startOrEnd == "s" {
            startDate = self.dateTxt
        } else {
            endDate = self.dateTxt
        }
        let mc = MapSelectController()
        let dateTxtIndex = self.dateTxt?.index((self.dateTxt?.startIndex)!, offsetBy: 2)
        self.dateTxt = String(self.dateTxt![dateTxtIndex!...])
        mc.call(text: self.dateTxt, startOrEnd: self.startOrEnd, btn: self.btn)
        self.dismiss(animated: false, completion: nil)
    }
    
    func getDateAsString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let strDate = dateFormatter.string(from: date)
        return strDate
    }
}
