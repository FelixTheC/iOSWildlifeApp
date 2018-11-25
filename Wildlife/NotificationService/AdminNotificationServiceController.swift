//
//  AdminNotificationServiceController.swift
//  Wildlife
//
//  Created by Felix Eisenmenger on 25.10.17.
//  Copyright © 2017 Felix Eisenmenger. All rights reserved.
//

import Foundation
import UIKit

protocol backtToMenuFromAdminNotify {
    
}
class AdminNotificationServiceController: UIViewController, backtToAdminNotify, UITableViewDelegate, UITableViewDataSource {
    
    var delegate: backtToMenuFromAdminNotify?
    @IBOutlet weak var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        table.delegate = self
        table.dataSource = self
        
    }
    
    @IBAction func backToMenu(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createUserNotify(_ sender: Any) {
        performSegue(withIdentifier: "createUserNotifySegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createUserNotifySegue" {
            let createVC = segue.destination as! CreateUserNotificationController
            createVC.delegate = self
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)

        cell.textLabel?.text = userArray[indexPath.row]
        
        return cell
    }
    
}
