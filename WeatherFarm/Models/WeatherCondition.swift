//
//  WeatherCondition.swift
//  WeatherFarm
//
//  Created by Michel Pierce on 21/04/26.
//

import Foundation

enum WeatherCondition: String, Codable, CaseIterable {
    case sunny = "Sunny"
    case rain = "Rain"
    case cloudy = "Cloudy"
    case extremeHeat = "Extreme Heat"
    case snow = "Snow"
    
    var icon: String {
        switch self {
        case .sunny: return "sun.max.fill"
        case .rain: return "cloud.rain.fill"
        case .cloudy: return "cloud.fill"
        case .extremeHeat: return "thermometer.sun.fill"
        case .snow: return "snowflake"
        }
    }
}

enum TimeOfDay: String, Codable, CaseIterable {
    case dawn = "Dawn"
    case day = "Day"
    case afternoon = "Afternoon"
    case night = "Night"
}
