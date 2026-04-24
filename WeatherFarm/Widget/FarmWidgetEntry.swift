//
//  WidgetEntry.swift
//  WeatherFarm
//
//  Created by Michel Pierce on 23/04/26.
//

import WidgetKit
import SwiftUI
import SwiftData

struct HourlyForecast{
    let time: String
    let weather: WeatherCondition
}

struct FarmWidgetEntry: TimelineEntry {
    let date: Date
    let currentWeather: WeatherCondition
    let currentTime: TimeOfDay
    let gold: Int
    let hourlyForecasts: [HourlyForecast]
}
