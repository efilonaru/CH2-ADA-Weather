//
//  DailyWeather.swift
//  WeatherFarm
//
//  Created by Michel Pierce on 20/04/26.
//

import Foundation

// MARK: - Models
struct DailyWeather: Identifiable, Equatable {
    let id = UUID()
    let dayString: String
    let dateString: String
    let isToday: Bool
    let iconName: String
    let highTemp: Int
    let lowTemp: Int
    let hourlyData: [HourlyWeather]
    
    static func == (lhs: DailyWeather, rhs: DailyWeather) -> Bool {
        lhs.id == rhs.id
    }
}


