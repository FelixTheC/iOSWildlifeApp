//
//  utils.swift
//  Wildlife
//
//  Created by Felix Eisenmenger on 27.10.17.
//  Copyright © 2017 Felix Eisenmenger. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyXMLParser
import SystemConfiguration
import SwiftyJSON
import SQLite
//import CoreTelephony
//let networkInfo = CTTelephonyNetworkInfo()
//let networkString = networkInfo.currentRadioAccessTechnology
//let reachable = NetworkReachabilityManager()
var collarCount: Int?
var animalCount: Int?
var collarSize: Int?
var animalSize: Int?
var userSize: Int?
var selectedForCompass: String?
var collarArray = [""]
var animalArray = [""]
var lastLocation = [String: Double]()
var userArray = Array<String>()
//var animalMap = [String:String]()
var collarMap = [String:String]()
var userMap = [String:String]()
var allAnimals = Array<[String:String]>()
var allCollars = Array<[String:String]>()
var allLocations = Array<[String:String]>()
var reallyAllLocations = Array<Array<[String:String]>>()
var lastDBEntryAnimalJSONResponse: JSON?
var lastDBEntryCollarJSONResponse: JSON?
var startDate: String?
var endDate: String?
var lastPos = [String:String]()

//func checkCurrentRadioAccess() {
//    if networkString == CTRadioAccessTechnologyLTE {
//
//    } else if networkString == CTRadioAccessTechnologyWCDMA {
//
//    } else if networkString == CTRadioAccessTechnologyEdge {
//
//    } else if (reachable?.isReachableOnEthernetOrWiFi)! {
//
//    }
//}

func resetArrays() {
    collarCount = nil
    animalCount = nil
    collarArray.removeAll()
    animalArray = Array<String>()
    userArray = Array<String>()
    animalDataArray.removeAll()
    collarMap = [String:String]()
    userMap = [String:String]()
    allAnimals = Array<[String:String]>()
    allCollars = Array<[String:String]>()
    allLocations = Array<[String:String]>()
}

func getLabelColor(row: Int) -> UIColor {
    switch row {
    case 1:
        return UIColor.init(red: 255/255, green: 128/255, blue: 128/255, alpha: 1)
    case 2:
        return UIColor.init(red: 204/255, green: 0/255, blue: 204/255, alpha: 1)
    case 3:
        return .cyan
    case 4:
        return UIColor.init(red: 0/255, green: 255/255, blue: 153/255, alpha: 1)
    case 5:
        return .gray
    case 6:
        return UIColor.init(red: 102/255, green: 204/255, blue: 255/255, alpha: 1)
    case 7:
        return UIColor.init(red: 153/255, green: 0/255, blue: 51/255, alpha: 1)
    case 8:
        return UIColor.init(red: 102/255, green: 255/255, blue: 102/255, alpha: 1)
    case 9:
        return UIColor.init(red: 255/255, green: 51/255, blue: 0/255, alpha: 1)
    case 10:
        return UIColor.init(red: 153/255, green: 153/255, blue: 255/255, alpha: 1)
    case 11:
        return UIColor.init(red: 255/255, green: 255/255, blue: 204/255, alpha: 1)
    case 12:
        return UIColor.init(red: 102/255, green: 153/255, blue: 153/255, alpha: 1)
    case 13:
        return UIColor.init(red: 102/255, green: 102/255, blue: 153/255, alpha: 0.75)
    case 14:
        return UIColor.init(red: 255/255, green: 102/255, blue: 255/255, alpha: 1)
    case 15:
        return UIColor.init(red: 204/255, green: 255/255, blue: 153/255, alpha: 1)
    case 16:
        return UIColor.init(red: 255/255, green: 204/255, blue: 0/255, alpha: 1)
    case 17:
        return UIColor.init(red: 255/255, green: 51/255, blue: 153/255, alpha: 1)
    case 18:
        return UIColor.init(red: 0/255, green: 102/255, blue: 255/255, alpha: 1)
    case 100:
        return UIColor.init(red: 255/255, green: 204/255, blue: 0/255, alpha: 1)
    default:
        return .green
    }
}

func checkWIFIAndMobileData() -> Bool {
    guard let reachability = SCNetworkReachabilityCreateWithName(nil, "www.google.com") else { return false }
    var flags = SCNetworkReachabilityFlags()
    SCNetworkReachabilityGetFlags(reachability, &flags)
    let isReachable = flags.contains(SCNetworkReachabilityFlags.reachable)
    
    return isReachable
}

func checkForWifiOnly() -> Bool {
    let isReachable: Bool?
    guard let reachability = SCNetworkReachabilityCreateWithName(nil, "www.google.com") else { return false }
    var flags = SCNetworkReachabilityFlags()
    SCNetworkReachabilityGetFlags(reachability, &flags)
    if !flags.contains(SCNetworkReachabilityFlags.isWWAN) {
         isReachable = flags.contains(SCNetworkReachabilityFlags.reachable)
    } else {
        isReachable = false
    }
    return isReachable!
}

func alertNoInternet(btnTitle: String, message: String) -> UIViewController {
    let alertController = UIAlertController.init(title: "No connection", message: message, preferredStyle: UIAlertControllerStyle.alert)
    alertController.addAction(UIAlertAction.init(title: btnTitle, style: UIAlertActionStyle.cancel, handler: nil))
//    alertController.addAction(UIAlertAction.init(title: "Activate", style: UIAlertActionStyle.default, handler: { action in
//        UIApplication.shared.open(URL(string:"App-Prefs:root=General")!, options: [:], completionHandler: nil)
//    }))
    
    return alertController
}


//@TODO check last db Entry with real database
//-> add new function in MicroService(check last entry if newer data available -> download all)
func updateDatabase(_ completion: @escaping (Bool) -> Void){
    if checkForWifiOnly() {
        //weak var db = Database()
        if UserDefaults.standard.bool(forKey: "switchStatus") {
            
        } else {
            completion(false)
        }
    } else {
        completion(false)
    }
}

func getDate(days: Int, month: Int) -> Date {
    var timeInterval = DateComponents()
    if days != 0 {
        timeInterval.day = (days * (-1))
    }
    if month != 0 {
        timeInterval.month = (month * (-1))
    }
    return Calendar.current.date(byAdding: timeInterval, to: Date())!
}

func convertDateToString(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM dd, yyyy hh:mm:ss"
    
    return dateFormatter.string(from:date)
}

func convertIsoDateToString(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    return dateFormatter.string(from:date)
}

func convertDateDateToString(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
    
    return dateFormatter.string(from:date)
}

func convertStringToDate(isoDate: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_En")
    dateFormatter.dateFormat = "MMM dd, yyyy hh:mm:ss a"
    let date = dateFormatter.date(from:String(isoDate))
    if date != nil{
        return date!
    } else {
        return Date()
    }
}

func convertStringToIsoDate(isoDate: String) -> String {
    let dateFormatter = DateFormatter()
    let date: String?
    
    dateFormatter.locale = Locale(identifier: "en_En")
    dateFormatter.dateFormat = "MMM dd, yyyy hh:mm:ss a"
    
    let tmpdate = dateFormatter.date(from:String(isoDate))
    dateFormatter.dateFormat = "yy-MM-dd hh:mm:ss"
    
    if let tmp = tmpdate {
        date = dateFormatter.string(from: tmp)
    } else {
        dateFormatter.dateFormat = "MMM dd, yyyy hh:mm:ss"
        let tmpdate = dateFormatter.date(from:String(isoDate))
        dateFormatter.dateFormat = "yy-MM-dd hh:mm:ss"
        date = dateFormatter.string(from: tmpdate!)
    }
    
    if let stringDate: String = date {
        return stringDate
    } else {
        return isoDate
    }
}

func convertStringDateToDate(isoDate: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let date = dateFormatter.date(from:String(isoDate))
    if date != nil{
        return date!
    } else {
        return Date()
    }
}

func addOneDay(date: Date) -> Date {
    let calender = Calendar.current
    var components = DateComponents()
    components.day = 1
    let newDate = calender.date(byAdding: components, to: date)
    return newDate!
}

func getDateBeforeTwoWeeks(date: Date) -> Date {
    let calender = Calendar.current
    var components = DateComponents()
    components.day = -14
    let newDate = calender.date(byAdding: components, to: date)
    return newDate!
}

