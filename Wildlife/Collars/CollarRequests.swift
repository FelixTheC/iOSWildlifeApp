//
//  CollarRequests.swift
//  Wildlife
//
//  Created by Felix Eisenmenger on 19.06.18.
//  Copyright © 2018 Felix Eisenmenger. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

func getCollarCount(username: String) {
    let url = eurekaClientUrl + getCollarUrl(username: username)
    Alamofire.request(url, method: .get).responseJSON(completionHandler: {response in
        if response.result.isSuccess {
            let apiResponse = JSON(response.result.value!)
            if apiResponse["status"] == JSON.null {
                collarCount = apiResponse.count
            } else {
                collarCount = -1
            }
        }
    })
}
