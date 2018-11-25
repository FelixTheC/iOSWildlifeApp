//
//  RequestController.swift
//  Wildlife
//
//  Created by Felix Eisenmenger on 30.10.17.
//  Copyright © 2017 Felix Eisenmenger. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyXMLParser

class RequestController {
    var url = ""
    
    func isConnectedToInternet() -> Bool {
        return NetworkReachabilityManager()!.isReachable
    }
    
    func getServiceUrl() {
        Alamofire.request(eurekaClientUrl, method: .get).responseString(completionHandler: { response in
            if response.result.isSuccess {
//                if let data = response.data {
//                    let xml = XML.parse(data)
//                    let ipAddr = xml["application"]["instance"]["ipAddr"]
//                    let port = xml["application"]["instance"]["port"]
//                    self.url = "http://" + (ipAddr.text)!
//                    self.url = self.url + ":" + (port.text)!
//                }
            }
        })
    }
    
    init() {
        getServiceUrl()
    }
    
    func getUrl() -> String {
        return self.url
    }
}
