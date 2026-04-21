//
//  hourlyWeather.swift
//  WeatherFarm
//
//  Created by Michel Pierce on 20/04/26.
//

import Foundation

struct HourlyWeather: Identifiable {
    let id = UUID()
    let time: String
    let iconName: String
    let temp: Int
}
