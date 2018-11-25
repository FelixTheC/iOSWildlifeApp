//
//  AnimalRequest.swift
//  Wildlife
//
//  Created by Felix Eisenmenger on 30.10.17.
//  Copyright © 2017 Felix Eisenmenger. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
    
func getCollarData(username: String, completion: @escaping (Bool, Any?, Error?) -> Void) {
    DispatchQueue.global(qos: .utility).async {
        let url = eurekaClientUrl + getCollarUrl(username: username)
        Alamofire.request(url, method: .get).responseJSON { response in
            if response.result.isSuccess {
                let apiResponse = JSON(response.result.value!)
                if apiResponse["status"] == JSON.null {
                    if apiResponse.count > 0 {
                        for j in apiResponse.array! {
                            let tempName: String = j["name"].stringValue
                            let tempId: String = j["id"].stringValue
                            let tempCollarType = j["collarType"].stringValue
                            let tempValid = j["valid"].stringValue
                            
                            if !collarArray.contains(tempName) {
                                collarMap.updateValue(tempId, forKey: tempName)
                                collarMap.updateValue(tempId, forKey: "id")
//                                animalMap.updateValue(tempName, forKey: "animalName")
                                collarMap.updateValue(tempCollarType, forKey: "collarType")
                                collarMap.updateValue(tempValid, forKey: "valid")
                                
                                allCollars.append(collarMap)
                                collarArray.append(tempName)
                            }
                        }
                        DispatchQueue.main.async {
                            completion(true, nil, nil)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(true, nil, nil)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(false, nil, nil)
                    }
                }
            }
        }
    }
}

func getUserByUserGroupAdmin(admin: String, completion: @escaping (Bool, Any?, Error?) -> Void) {
    DispatchQueue.global(qos: .utility).async {
        let url = eurekaClientUrl + getUserGroupUser(adminName: admin)
        Alamofire.request(url, method: .get).responseJSON { response in
            if response.result.isSuccess {
                let apiResponse = JSON(response.result.value!)
                if apiResponse["status"] == JSON.null {
                    if apiResponse.count != userArray.count {
                        for j in apiResponse.array! {
                            let tempName = j["name"].stringValue
                            userArray.append(tempName)
                            userMap.updateValue(j["id"].stringValue, forKey: tempName)
                        }
                        DispatchQueue.main.async {
                            completion(true, nil, nil)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(true, nil, nil)
                        }
                    }
                } else {
                    completion(false, nil, nil)
                }
            }
        }
    }
}

func getLatLonAnimalByCollarAndTime(id: String, collarOrAnimal: String, date1: String, date2: String, completion: @escaping (Bool, Any?, Error?) -> Void) {
    DispatchQueue.global(qos: .utility).async {
        var url = ""
        var animalName: String?
        if collarOrAnimal == "collar" {
            url = eurekaClientUrl + getAnimalPositionsBetweenByCollar(id: id, date1: date1, date2: date2)
            animalName = ""
        } else {
            url = eurekaClientUrl + getAnimalPositionsBetweenByAnimal(id: id, date1: date1, date2: date2)
            let animal = animalDataArray.first(where: { $0.id == id })
            animalName = (animal?.name)!
        }
        Alamofire.request(url, method: .get).responseJSON { response in
            if response.result.isSuccess {
                let apiResponse = JSON(response.result.value!)
                if apiResponse["status"] == JSON.null {
                    if apiResponse.array!.count == 0 {
                        allLocations.append(["latitude": "0",
                                             "longitude": "0",
                                             "time": "Jan 10, 2000 00:00:00",
                                             "sunAngle": "10",
                                             "collarId": id,
                                             "animalName": animalName!,
                                             "idPosition": "-1",
                                             "acquistionTime": "Jan 10, 2000 00:00:00",
                                             "id": id])
                        reallyAllLocations.append(allLocations)
                    } else {
                        for tempData in apiResponse.array! {
                            let idPosition = tempData["idPosition"].intValue
                            let acquistionTime = tempData["acquisitionTime"].stringValue
                            let latitude = tempData["latitude"].stringValue
                            let longitude = tempData["longitude"].stringValue
                            let sunAngle = tempData["sunAngle"].stringValue
                            let collarId = tempData["idCollar"].stringValue
                            allLocations.append(["latitude": latitude,
                                                     "longitude": longitude,
                                                     "time": acquistionTime,
                                                     "sunAngle": sunAngle,
                                                     "collarId": id,
                                                     "animalName": animalName!,
                                                     "idPosition": String(idPosition),
                                                     "acquistionTime": acquistionTime,
                                                     "id": collarId])
                        }
                        reallyAllLocations.append(allLocations)
                    }
                    completion(true, nil, nil)
                } else {
                    completion(false, nil, nil)
                }
            } else {
                completion(false, nil, nil)
            }
        }
    }
}

func getSizeOfData(username: String, whichToCheck: String) {
    let url: String?
    switch whichToCheck {
    case "collar":
            url = eurekaClientUrl + getCollarSize(username: username)
        break
    case "animal":
        url = eurekaClientUrl + getAnimalSize(username: username)
        break
    case "user":
        url = eurekaClientUrl + getUserSize(username: username)
        break
    default:
        url = eurekaClientUrl + getCollarSize(username: username)
    }
    Alamofire.request(url!, method: .get).responseJSON { response in
        if response.result.isSuccess {
            let apiResponse = JSON(response.result.value!)
            if apiResponse["status"] == JSON.null {
                switch whichToCheck {
                case "collar":
                    collarSize = apiResponse.dictionaryValue["size"]?.intValue
                    break
                case "animal":
                    animalSize = apiResponse.dictionaryValue["size"]?.intValue
                    break
                case "user":
                    userSize = apiResponse.dictionaryValue["size"]?.intValue
                    break
                default:
                    collarSize = apiResponse.dictionaryValue["size"]?.intValue
                }
            }
        }
    }
}

func funcWriteIntoDB(data: Array<Array<[String:String]>>) {
    let db = Database()
    DispatchQueue.global(qos: .background).async {
        var animal: Animal
        for d in data {
            theloop: for tempData in d {
                let id = tempData["collarId"]
                if animalDataArray.contains(where: { $0.id == id }) {
                    animal = animalDataArray.first(where: { $0.id == id })!
                } else {
                    animal = Animal.init(id: "", name: "", createdBy: "", age: "", sex: "", species: "")
                }
                db.insertPosition(idPosition: Int(tempData["idPosition"]!)!,
                                  acquistionTime: (tempData["time"] != nil ? tempData["time"]! : "Jan 10, 2000 00:00:00"),
                                  idCollar: (tempData["animalName"] == "" ? Int(tempData["collarId"]!)! : Int()),
                                  idAnimal: (tempData["animalName"] != "" ? Int(tempData["collarId"]!)! : Int()),
                                  latitude: Double(tempData["latitude"]!)!,
                                  longitude: Double(tempData["longitude"]!)!,
                                  sunAngle: Double(tempData["sunAngle"]!)!,
                                  animalName: "" + animal.name,
                                  completion: {(result, response, error) in
                })
            }
        }
    }
}

//@TODO look up for better solution -> get last db entry for better autoupdating the data or write a new one
func getLatLonAnimalByCollar(id: String, collarOrAnimal: String, completion: @escaping (Bool, Any?, Error?) -> Void) {
    DispatchQueue.global(qos: .utility).async {
        var url = ""
        if collarOrAnimal == "collar" {
            url = eurekaClientUrl + getAnimalCollarLastPosition(collarId: id)
        } else {
            url = eurekaClientUrl + getAnimalLastPosition(animalId: id)
        }
        Alamofire.request(url, method: .get).responseJSON { response in
            if response.result.isSuccess {
                let apiResponse = JSON(response.result.value!)
                if apiResponse["status"] == JSON.null {
                    lastLocation["latitude"] = apiResponse["latitude"].doubleValue
                    lastLocation["longitude"] = apiResponse["longitude"].doubleValue
                }
                DispatchQueue.main.async {
                    completion(true, apiResponse, nil)
                }
            } else {
                DispatchQueue.main.async {
                    completion(false, nil, nil)
                }
            }
        }
    }
}

func getLastPosFromService(id: String, collarOrAnimal: String) {
    var url = ""
    if collarOrAnimal == "collar" {
        url = eurekaClientUrl + getAnimalCollarLastPosition(collarId: id)
    } else {
        url = eurekaClientUrl + getAnimalLastPosition(animalId: id)
    }
    Alamofire.request(url, method: .get).responseJSON { response in
        if response.result.isSuccess {
            let apiResponse = JSON(response.result.value!)
            if apiResponse["status"] == JSON.null {
                lastPos[id] = apiResponse["idPosition"].stringValue
            }
        }
    }
}

func getLastPositionsFromService(id: String, collarOrAnimal: String, lastPos: String) -> Void {
    var url = ""
    var animalName: String?
    let db = Database()
    let animal: Animal
    if collarOrAnimal == "collar" {
        url = eurekaClientUrl + getAnimalPositionAfterByCollar(id: id, lastPos: lastPos)
        animalName = ""
    } else {
        url = eurekaClientUrl + getAnimalPositionAfterByAnimal(id: id, lastPos: lastPos)
        if animalDataArray.contains(where: { $0.id == id }) {
            animal = animalDataArray.first(where: { $0.id == id })!
        } else {
            animal = Animal.init(id: "", name: "", createdBy: "", age: "", sex: "", species: "")
        }
        animalName = animal.name
    }
    Alamofire.request(url, method: .get).responseJSON { response in
        if response.result.isSuccess {
           let apiResponse = JSON(response.result.value!)
            if apiResponse["status"] == JSON.null {
                var counter = 1
                DispatchQueue.global(qos: .background).async {
                    for tempData in apiResponse.array! {
                        db.insertPosition(idPosition: tempData["idPosition"].intValue,
                                          acquistionTime: tempData["acquisitionTime"].stringValue,
                                          idCollar: tempData["idCollar"].intValue,
                                          idAnimal: Int(id)!,
                                          latitude: tempData["latitude"].doubleValue,
                                          longitude: tempData["longitude"].doubleValue,
                                          sunAngle: tempData["sunAngle"].doubleValue,
                                          animalName: animalName!,
                          completion: {(result, response, error) in
                                    if result {
                                        if apiResponse.array!.count == counter {
                                            
                                        } else {
                                            counter += 1
                                        }
                                    }
                            })
                        }
                    }
                } else {
            }
        }
    }
}

func getDataBetweenTime(date1: String, date2: String, dataArray: Array<String>, isCollar: Bool, completion: @escaping(Bool) -> Void) {
    for data in dataArray {
        if data != "" {
            var url: String = ""
            var id = "-1"
            var animalName: String = ""
            if isCollar {
                id = String(data.split(separator: " ").first!)
                url = eurekaClientUrl + getAnimalPositionsBetweenByCollarWithoutTime(id: id, date1: date1, date2: date2)
            } else {
                if animalDataArray.contains(where: { $0.name == data }) {
                    let animal = animalDataArray.first(where: { $0.name == data })
                    id = (animal?.id)!
                }
                url = eurekaClientUrl + getAnimalPositionsBetweenByAnimalWithoutTime(id: id, date1: date1, date2: date2)
                animalName = data
            }
                Alamofire.request(url, method: .get).responseJSON { response in
                    if response.result.isSuccess {
                        let apiResponse = JSON(response.result.value!)
                        if apiResponse["status"] == JSON.null {
                            if apiResponse.array!.count == 0 {
                                allLocations.append(["latitude": "0",
                                                     "longitude": "0",
                                                     "time": "Jan 10, 2000 00:00:00",
                                                     "sunAngle": "10",
                                                     "collarId": id,
                                                     "animalName": animalName,
                                                     "idPosition": "-1",
                                                     "acquistionTime": "Jan 10, 2000 00:00:00",
                                                     "id": id])
                                reallyAllLocations.append(allLocations)
                            } else {
                                for tempData in apiResponse.array! {
                                    let idPosition = tempData["idPosition"].intValue
                                    let acquistionTime = tempData["acquisitionTime"].stringValue
                                    let latitude = tempData["latitude"].stringValue
                                    let longitude = tempData["longitude"].stringValue
                                    let time = tempData["acquisitionTime"].stringValue
                                    let sunAngle = tempData["sunAngle"].stringValue
                                    let collarId = tempData["idCollar"].stringValue
                                    allLocations.append(["latitude": latitude,
                                                         "longitude": longitude,
                                                         "time": time,
                                                         "sunAngle": sunAngle,
                                                         "collarId": id,
                                                         "animalName": animalName,
                                                         "idPosition": String(idPosition),
                                                         "acquistionTime": acquistionTime,
                                                         "id": collarId])
                                reallyAllLocations.append(allLocations)
                            }
                        }
                    }
                }
            }
        }
    }
    completion(true)
}
