//
//  AnimalRequests.swift
//  Wildlife
//
//  Created by Felix Eisenmenger on 19.06.18.
//  Copyright © 2018 Felix Eisenmenger. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

func getAnimalCount(username: String){
    let url = eurekaClientUrl + getAnimalUrl(username: username)
    Alamofire.request(url, method: .get).responseJSON { response in
        if response.result.isSuccess {
            let apiResponse = JSON(response.result.value!)
            if apiResponse["status"] == JSON.null {
                animalCount = apiResponse.count
            } else {
                animalCount = -1
            }
        }
    }
}

func getAnimalData(username: String, completion: @escaping (Bool, Any?, Error?) -> Void) {
    DispatchQueue.global(qos: .utility).async {
        let url = eurekaClientUrl + getAnimalUrl(username: username)
        Alamofire.request(url, method: .get).responseJSON { response in
            if response.result.isSuccess {
                let apiResponse = JSON(response.result.value!)
                if apiResponse["status"] == JSON.null {
                    if apiResponse.count > 0 {
                        for j in apiResponse.array! {
                            let tempName: String = j["name"].stringValue
                            let tempId: String = j["id"].stringValue
                            let tempCreatedBy = j["createdBy"].stringValue
                            let tempAge = j["age"].stringValue
                            let tempSex = j["sex"].stringValue
                            let tempSpecies = j["species"].stringValue
                            
                            if !animalArray.contains(tempName) {
                                animalDataArray.append(Animal.init(id: tempId,
                                                                   name: tempName,
                                                                   createdBy: tempCreatedBy,
                                                                   age: tempAge,
                                                                   sex: tempSex,
                                                                   species: tempSpecies))
                                //                                animalMap.updateValue(tempId, forKey: tempName)
                                //                                animalMap.updateValue(tempName, forKey: tempId)
                                //                                animalMap.updateValue(tempName, forKey: "animalName")
                                //                                animalMap.updateValue(tempCreatedBy, forKey: "createdBy")
                                //                                animalMap.updateValue(tempAge, forKey: "age")
                                //                                animalMap.updateValue(tempSex, forKey: "sex")
                                //                                animalMap.updateValue(tempSpecies, forKey: "species")
                                //
                                //                                allAnimals.append(animalMap)
                                animalArray.append(tempName)
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
