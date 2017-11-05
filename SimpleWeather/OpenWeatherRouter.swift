//
//  OpenWeatherRouter.swift
//  SimpleWeather
//
//  Created by Hendy Chua on 23/10/17.
//  Copyright © 2017 Hendy Chua. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire

public enum OpenWeatherRouter : URLRequestConvertible {
    static let baseURLPath = "https://api.openweathermap.org/data/2.5"
    
    case current(CLLocationCoordinate2D, String)
    case hourly(CLLocationCoordinate2D, String)
    
    var method: HTTPMethod {
        switch self {
        default:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .current:
            return "/weather"
        case .hourly:
            return "/forecast"
        }
    }
    
    public func asURLRequest() throws -> URLRequest {
        let params: [String: Any] = {
            switch self {
            case .current(let location, let apiKey):
                return ["APPID": apiKey, "lat": location.latitude, "lon": location.longitude, "units": "imperial"]
            case .hourly(let location, let apiKey):
                return ["APPID": apiKey, "lat": location.latitude, "lon": location.longitude, "units": "imperial", "cnt": 12]
            }
        }()
        
        let url = try OpenWeatherRouter.baseURLPath.asURL()
        
        var request = URLRequest(url: url.appendingPathComponent(path))
        request.httpMethod = method.rawValue
        request.timeoutInterval = TimeInterval(10 * 1000)
        
        return try URLEncoding.default.encode(request, with: params)
    }
    
}
