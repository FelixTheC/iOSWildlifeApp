//
//  Database.swift
//  Wildlife
//
//  Created by Felix Eisenmenger on 21.10.17.
//  Copyright © 2017 Felix Eisenmenger. All rights reserved.
//

import Foundation
import SQLite

class Database {

    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    
    let pPosition = Table("positions")
    let nNotification = Table("notifications")
    let aId = Expression<Int>("id")
    let pidPosition = Expression<Int>("idPosition")
    let pAcquisitionTime = Expression<Date>("acquisitionTime")
    let pIdCollar = Expression<Int?>("idCollar")
    let pIdAnimal = Expression<Int?>("idAnimal")
    let pLatitude = Expression<Double>("latitude")
    let pLongitude = Expression<Double>("longitude")
    let pSunAngle = Expression<Double>("sunAngle")
    let pAnimalName = Expression<String>("animalName")
    let nName = Expression<String>("name")
    let nGetNotifications = Expression<Bool>("getNotifications")
    let nEmail = Expression<String>("email")
    let nMobile = Expression<String>("mobileNr")
    var db: Connection?
    
    init() {
        do {
            self.db = try Connection("\(path)/db.sqlit3")
            db?.busyTimeout = 20
            db?.busyHandler({ tries in
                if tries >= 19 {
                    return false
                }
                return true
            })
        } catch {
            print(error)
        }
    }
    
    func createNotificationTable() {
        let createTable = nNotification.create(ifNotExists: true) { (table) in
            table.column(aId, unique: true)
            table.column(nName)
            table.column(pIdCollar)
            table.column(pIdAnimal)
            table.column(nEmail)
            table.column(nMobile)
            table.column(nGetNotifications)
        }
        
        do {
            try db?.run(createTable)
        } catch {
            print(error)
        }
    }
    
    func createPositionTable() {
        let createTable = pPosition.create(ifNotExists: true) { (table) in
            table.column(aId, primaryKey: true)
            table.column(pidPosition)
            table.column(pAcquisitionTime)
            table.column(pIdCollar)
            table.column(pIdAnimal)
            table.column(pLatitude)
            table.column(pLongitude)
            table.column(pSunAngle)
            table.column(pAnimalName)
        }
        
        do {
            try db?.run(createTable)
        } catch {
            print(error)
        }
    }
    
    func insertPosition(idPosition: Int, acquistionTime: String, idCollar: Int, idAnimal: Int, latitude: Double, longitude: Double, sunAngle: Double, animalName: String, completion: @escaping (Bool, Any?, Error?) -> Void) {
        print("insert into db - date: " + acquistionTime)
        DispatchQueue.global(qos: .background).async {
            let insertPosition = self.pPosition.insert(or: .ignore,
                                                       self.pidPosition <- idPosition,
                                                       self.pAcquisitionTime <- convertStringToDate(isoDate: acquistionTime),
                                                       self.pIdCollar <- idCollar,
                                                       self.pIdAnimal <- idAnimal,
                                                       self.pLatitude <- latitude,
                                                       self.pLongitude <- longitude,
                                                       self.pSunAngle <- sunAngle,
                                                       self.pAnimalName <- animalName
            )
            do {
                try self.db?.run(insertPosition)
                DispatchQueue.main.async {
                    completion(true, nil, nil)
                }
            } catch {
                print(error)
                sleep(5)
                self.insertPosition(idPosition: idPosition, acquistionTime: acquistionTime, idCollar: idCollar, idAnimal: idAnimal, latitude: latitude, longitude: longitude, sunAngle: sunAngle, animalName: animalName, completion: {(result, response, error) in
                    if result {
                        DispatchQueue.main.async {
                            completion(true, nil, nil)
                        }
                    }
                })
            }
        }
    }
    
    func insertArrayElementsInDB(map: Array<[String:String]>, completion: @escaping(Bool) -> Void) {
        var counter = 0
        DispatchQueue.global(qos: .background).async {
            for element in map {
                let insertPosition = self.pPosition.insert(or: .ignore,
                                                           self.pidPosition <- Int(element["idPosition"]!)!,
                                                           self.pAcquisitionTime <- convertStringToDate(isoDate: element["acquistionTime"]!),
                                                           self.pIdCollar <- Int(element["collarId"]!)!,
                                                           self.pIdAnimal <- Int(element["collarId"]!)!,
                                                           self.pLatitude <- Double(element["latitude"]!)!,
                                                           self.pLongitude <- Double(element["longitude"]!)!,
                                                           self.pSunAngle <- Double(element["sunAngle"]!)!,
                                                           self.pAnimalName <- element["animalName"]!
                    )
                    do {
                        try self.db?.run(insertPosition)
                        counter += 1
                    } catch {
                        print(error)
                    }
                }
            completion(true)
            }
        }
    
    func insertNotification(id: Int, name: String, idCollar: Int, getNotification: Bool) {
        let insertNotification = nNotification.insert(or: .ignore, aId <- id, nName <- name, pIdCollar <- idCollar, nGetNotifications <- getNotification)
        
        do {
            try db?.run(insertNotification)
        } catch {
            print(error)
        }
    }
    
    func getLastPositionSync(collarId: Int, collarOrAnimal:String) -> Dictionary<String, String> {
        var dict = [String:String]()
        do {
            var query: Table?
            if collarOrAnimal == "collar" {
                query = self.pPosition.filter(self.pIdCollar == collarId)
                    .order(self.aId.desc)
                    .limit(1)
            } else {
                query = self.pPosition.filter(self.pIdAnimal == collarId)
                    .order(self.aId.desc)
                    .limit(1)
            }
            let position = try self.db?.prepare(query!)
            for pos in position! {
                dict.updateValue(String(try(pos.get(self.pidPosition))), forKey: "idPosition")
                dict.updateValue( convertDateToString(date: try(pos.get(self.pAcquisitionTime))), forKey: "acquisitionTime")
                dict.updateValue(String(try(pos.get(self.pIdCollar)!)), forKey: "collarId")
                if collarOrAnimal != "collar" {
                    dict.updateValue(String(try(pos.get(self.pAnimalName))), forKey: "animalName")
                }
            }
        } catch {
            print("error")
        }
        return dict
    }
    
    func getLastPosition(collarId: Int, collarOrAnimal:String, completion: @escaping (Bool, Any?, Error?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                var query: Table?
                var lastPosition = ""
                if collarOrAnimal == "collar" {
                    query = self.pPosition.filter(self.pIdCollar == collarId)
                        .order(self.aId.desc)
                        .limit(1)
                } else {
                    query = self.pPosition.filter(self.pIdAnimal == collarId)
                        .order(self.aId.desc)
                        .limit(1)
                }
                let position = try self.db?.prepare(query!)
                for pos in position! {
                    lastLocation["latitude"] = try(pos.get(self.pLatitude))
                    lastLocation["longitude"] = try(pos.get(self.pLongitude))
                    lastPosition = String(try(pos.get(self.pidPosition)))
                }
                DispatchQueue.main.async {
                    completion(true, lastPosition, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, nil, error)
                }
            }
        }
    }
    
    func getLastPositions(collarId: Int, limit: Int, collarOrAnimal: String, startDate: String, endDate: String, completion: @escaping (Bool, Any?, Error?) -> Void) {
            do {
                var query: QueryType?
                if collarOrAnimal == "collar" {
                    if limit == 0 {
                        query = self.pPosition.filter(self.pIdCollar == collarId)
                            .filter(self.pAcquisitionTime >= convertStringDateToDate(isoDate: startDate))
                            .filter(self.pAcquisitionTime <= convertStringDateToDate(isoDate: endDate))
                            .order(self.pAcquisitionTime.desc)
                    } else if limit > 0 {
                        query = self.pPosition.filter(self.pIdCollar == collarId)
                            .order(self.pAcquisitionTime)
                            .limit(limit)
                    } else {
                        query = self.pPosition.filter(self.pIdCollar == collarId)
                            .order(self.pAcquisitionTime.desc)
                            .limit(2500)
                    }
                    let position = try self.db?.prepare(query!)
                        for pos in position! {
                            allLocations.append(
                                ["latitude": String(try(pos.get(self.pLatitude))),
                                 "longitude": String(try(pos.get(self.pLongitude))),
                                 "time": convertDateToString(date: try(pos.get(self.pAcquisitionTime))),
                                 "sunAngle": String(try(pos.get(self.pSunAngle))),
                                 "acquistionTime": convertDateToString(date: try(pos.get(self.pAcquisitionTime))),
                                 "collarId": String(describing: try(pos.get(self.pIdCollar)))])
                        }
                        reallyAllLocations.append(allLocations)
                } else {
                    if limit == 0 {
                        query = self.pPosition.filter(self.pIdAnimal == collarId)
                            .filter(self.pAcquisitionTime >= convertStringDateToDate(isoDate: startDate))
                            .filter(self.pAcquisitionTime <= convertStringDateToDate(isoDate: endDate))
                            .order(self.pAcquisitionTime)
                    } else if limit > 0 {
                        query = self.pPosition.filter(self.pIdAnimal == collarId)
                            .order(self.pAcquisitionTime.desc)
                            .limit(limit)
                    } else {
                        query = self.pPosition.filter(self.pIdAnimal == collarId)
                            .order(self.pAcquisitionTime.desc)
                            .limit(2500)
                    }
                    let position = try self.db?.prepare(query!)
                    for pos in position! {
                        allLocations.append(["latitude": String(try(pos.get(self.pLatitude))),
                                             "longitude": String(try(pos.get(self.pLongitude))),
                                             "time": convertDateToString(date: try(pos.get(self.pAcquisitionTime))),
                                             "acquistionTime": convertDateToString(date: try(pos.get(self.pAcquisitionTime))),
                                             "sunAngle": String(try(pos.get(self.pSunAngle))),
                                             "collarId": String(describing: try(pos.get(self.pIdAnimal))),
                                             "animalName": String(try(pos.get(self.pAnimalName)))
                            ])
                    }
                    reallyAllLocations.append(allLocations)
                }
                    completion(true, nil, nil)
            } catch {
                    completion(false, nil, error)
            }
        }
    
    func dropTable(completion: @escaping (Bool, Any?, Error?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let dropPositionTable = self.pPosition.drop(ifExists: true)
            let dropNotificationTable = self.nNotification.dropIndex(ifExists: true)
            do {
                try self.db?.run(dropPositionTable)
                try self.db?.run(dropNotificationTable)
                DispatchQueue.main.async {
                    completion(true, nil, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, nil, error)
                }
            }
        }
    }
}
