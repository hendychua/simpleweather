//
//  WXClient.swift
//  SimpleWeather
//
//  Created by Hendy Chua on 1/10/17.
//  Copyright © 2017 Hendy Chua. All rights reserved.
//

import Foundation
import CoreLocation
import ObjectMapper
import Alamofire

class WXClient {
    
    let apiKey : String?
    
    init() {
        var keys : NSDictionary?
        
        if let path = Bundle.main.path(forResource: "keys", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
        
        if let dict = keys {
            self.apiKey = dict["openWeatherApiKey"] as? String
        } else {
            self.apiKey = nil
        }
    }
    
    func fetchCurrentConditionsForLocation(location: CLLocationCoordinate2D, completion: @escaping (WXCondition?) -> Void) {
        Alamofire.request(OpenWeatherRouter.current(location, self.apiKey!))
            .validate(statusCode: 200..<300)
            .responseJSON{ response in
                guard response.result.isSuccess else {
                    print("Error getting current conditions: \(response.result.error)")
                    completion(nil)
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    print("Invalid current conditons info from the service: \(response.result.value)")
                    completion(nil)
                    return
                }
                
                completion(WXCondition(JSON: responseJSON)!)
        }
    }
    
    func fetchHourlyForecastForLocation(location: CLLocationCoordinate2D, completion: @escaping ([WXCondition]) -> Void) {
        Alamofire.request(OpenWeatherRouter.hourly(location, self.apiKey!))
            .validate(statusCode: 200..<300)
            .responseJSON{ response in
                guard response.result.isSuccess else {
                    print("Error getting hourly forecast: \(response.result.error)")
                    completion([WXCondition]())
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any] else {
                    print("Invalid hourly forecast info from the service: \(response.result.value)")
                    completion([WXCondition]())
                    return
                }
                                
                completion(Mapper<WXCondition>().mapArray(JSONArray: responseJSON["list"] as! [[String: Any]])!)
        }
    }
}
