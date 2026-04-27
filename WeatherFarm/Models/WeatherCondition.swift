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
    case extremeHeat = "ExtremeHeat"
    case snow = "Snow"
    
    var icon: String {
        switch self {
        case .sunny: return "sun"
        case .rain: return "umbrella"
        case .cloudy: return "cloudy"
        case .extremeHeat: return "hot"
        case .snow: return "snowy"
        }
    }
    
    var conditionsExample: String {
        switch self {
        case .sunny: return "Clear Skies"
        case .rain: return "Mostly Pouring"
        case .cloudy: return "Mostly Cloudy"
        case .extremeHeat: return "Scorching Hot!"
        case .snow: return "Snow falls"
        }
    }
    
    var exampleStats: MockWeatherStats {
            switch self {
            case .sunny:
                return MockWeatherStats(currentTemp: 28, highTemp: 32, lowTemp: 25, windSpeed: "10 km/h", precipitation: "0%", humidity: "70%")
                
            case .rain:
                return MockWeatherStats(currentTemp: 26, highTemp: 29, lowTemp: 24, windSpeed: "18 km/h", precipitation: "90%", humidity: "85%")
                
            case .cloudy:
                return MockWeatherStats(currentTemp: 27, highTemp: 30, lowTemp: 25, windSpeed: "12 km/h", precipitation: "20%", humidity: "75%")
                
            case .extremeHeat:
                return MockWeatherStats(currentTemp: 34, highTemp: 36, lowTemp: 28, windSpeed: "5 km/h", precipitation: "0%", humidity: "65%")
                
            case .snow:
                return MockWeatherStats(currentTemp: -2, highTemp: 1, lowTemp: -6, windSpeed: "24 km/h", precipitation: "80%", humidity: "60%")
            }
        }
}

struct MockWeatherStats {
    let currentTemp: Int
    let highTemp: Int
    let lowTemp: Int
    let windSpeed: String
    let precipitation: String
    let humidity: String
}

enum TimeOfDay: String, Codable, CaseIterable {
    case dawn = "Dawn"
    case day = "Day"
    case afternoon = "Afternoon"
    case night = "Night"
    
}
