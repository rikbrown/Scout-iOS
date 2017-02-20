//
//  ScoutRequester.swift
//  Scout
//
//  Created by Brown, Rik on 2017-02-19.
//  Copyright © 2017 Scout. All rights reserved.
//

import Foundation

class ScoutRequester {
    let host = "http://192.168.1.4:5000"
    
    public func takeoff() {
        request(endpoint: "takeoff")
    }
    
    public func land() {
        request(endpoint: "land")    }
    
    public func sayHello() {
        request(endpoint: "sayHello")
    }
    
    public func lightsOn() {
        request(endpoint: "alarmLedOn")
    }
    
    public func lightsOff() {
        request(endpoint: "alarmLedOff")
    }
    
    func request(endpoint: String) {
        guard let url = URL(string: host + "/" + endpoint) else {
            print("Error: cannot create URL")
            return
        }
        print("making request")
        let request = URLRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            print(response.debugDescription)
            print(error.debugDescription)
        }
        task.resume()

    }
    
}
