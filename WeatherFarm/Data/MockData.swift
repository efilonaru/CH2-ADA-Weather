//
//  MockData.swift
//  WeatherFarm
//
//  Created by Michel Pierce on 20/04/26.
//

import Foundation

struct MockData {
    static let weekForecast: [DailyWeather] = [
        DailyWeather(dayString: "Sat", dateString: "Apr 18", isToday: false, iconName: "umbrella", highTemp: 32, lowTemp: 27, hourlyData: generateHourly(baseTemp: 29, icon: "umbrella")),
        DailyWeather(dayString: "Sun", dateString: "Apr 19", isToday: false, iconName: "cold-wind", highTemp: 29, lowTemp: 23, hourlyData: generateHourly(baseTemp: 27, icon: "cold-wind")),
        DailyWeather(dayString: "Mon", dateString: "Apr 20", isToday: true, iconName: "cloudy", highTemp: 31, lowTemp: 25, hourlyData: generateHourly(baseTemp: 30, icon: "cloudy")),
        DailyWeather(dayString: "Tue", dateString: "Apr 21", isToday: false, iconName: "umbrella", highTemp: 32, lowTemp: 27, hourlyData: generateHourly(baseTemp: 29, icon: "umbrella")),
        DailyWeather(dayString: "Wed", dateString: "Apr 22", isToday: false, iconName: "sun", highTemp: 30, lowTemp: 27, hourlyData: generateHourly(baseTemp: 29, icon: "sun")),
        DailyWeather(dayString: "Thu", dateString: "Apr 23", isToday: false, iconName: "cold-wind", highTemp: 29, lowTemp: 23, hourlyData: generateHourly(baseTemp: 27, icon: "cold-wind")),
        DailyWeather(dayString: "Fri", dateString: "Apr 24", isToday: false, iconName: "cloudy", highTemp: 28, lowTemp: 21, hourlyData: generateHourly(baseTemp: 25, icon: "cloudy"))
    ]
    
    static func generateHourly(baseTemp: Int, icon: String) -> [HourlyWeather] {
        let times = ["8 AM", "9 AM", "10 AM", "11 AM", "12 PM", "1 PM", "2 PM", "3 PM"]
        return times.enumerated().map { index, time in
            HourlyWeather(time: time, iconName: icon, temp: baseTemp + (index * 1))
        }
    }
}
