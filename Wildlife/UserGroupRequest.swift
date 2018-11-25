//
//  UserGroupRequest.swift
//  Wildlife
//
//  Created by Felix Eisenmenger on 01.11.17.
//  Copyright © 2017 Felix Eisenmenger. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

func getUserByUserGroupAdmin(admin: String) {
    let url = mainURL + getUserGroupUser(adminName: admin)
    print(mainURL)
    print(url)
    Alamofire.request(url, method: .get).responseJSON { response in
        print(response)
        if response.result.isSuccess {
            let tempData = JSON(response.result.value!)
            for data in tempData {
                userArray.append(data.0)
                userMap[data.0] = data.1.stringValue
            }
        }
    }
}
