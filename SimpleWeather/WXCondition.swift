//
//  WXCondition.swift
//  SimpleWeather
//
//  Created by Hendy Chua on 1/10/17.
//  Copyright © 2017 Hendy Chua. All rights reserved.
//

import Foundation
import ObjectMapper

class WXCondition : Mappable, CustomStringConvertible {
    
    static let IMAGE_MAP : [String : String] = ["01d": "weather-clear", "02d": "weather-few", "03d": "weather-few",
                                                "04d": "weather-broken", "09d": "weather-shower", "10d": "weather-rain",
                                                "11d": "weather-tstorm", "13d": "weather-snow", "50d": "weather-mist",
                                                "01n": "weather-moon", "02n": "weather-few-night", "03n": "weather-few-night",
                                                "04n": "weather-broken", "09n": "weather-shower", "10n": "weather-rain-night",
                                                "11n": "weather-tstorm", "13n": "weather-snow", "50n": "weather-mist"]

    var date : Date?
    var humidity : Double?
    var temperature : Double?
    var tempHigh : Double?
    var tempLow : Double?
    var locationName : String?
    var sunrise : Date?
    var sunset : Date?
    var conditionDescription : String?
    var condition : String?
    var windBearing : Double?
    var windSpeed : Double?
    var icon : String?
    
    var description: String {
        return "WXCondition: date=\(date), humidity=\(humidity), temperature=\(temperature), " +
            "tempHigh=\(tempHigh), tempLow=\(tempLow), locationName=\(locationName), " +
            "sunrise=\(sunrise), sunset=\(sunset), conditionDescription=\(conditionDescription), " +
            "condition=\(condition), windBearing=\(windBearing), windSpeed=\(windSpeed), icon=\(icon)"
    }
    
    let dateTransform = TransformOf<Date, Double>(fromJSON: { (value: Double?) -> Date? in
        if let value = value {
            return Date(timeIntervalSince1970: TimeInterval(value))
        } else {
            return nil
        }
    }, toJSON: { (value: Date?) -> Double?  in
        if let value = value {
            return value.timeIntervalSince1970
        } else {
            return nil
        }
    })
    
    func imageName() -> String {
        return WXCondition.IMAGE_MAP[self.icon!]!
    }
    
    // Mappable protocols
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        humidity <- map["main.humidity"]
        temperature <- map["main.temp"]
        tempHigh <- map["main.temp_max"]
        tempLow <- map["main.temp_min"]
        locationName <- map["name"]
        conditionDescription <- map["weather.0.description"]
        condition <- map["weather.0.main"]
        windBearing <- map["wind.deg"]
        windSpeed <- map["wind.speed"]
        icon <- map["weather.0.icon"]
        date <- (map["dt"], dateTransform)
        sunrise <- (map["sys.sunrise"], dateTransform)
        sunset <- (map["sys.sunset"], dateTransform)
    }
}
