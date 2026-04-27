//
//  WorldEnvironmentManager.swift
//  WeatherFarm
//
//  Created by Michel Pierce on 22/04/26.
//

import Foundation
import Combine
import WidgetKit

class WorldEnvironmentManager: ObservableObject {
    //ini bisa diubah ygy
    @Published var currentWeather: WeatherCondition = .sunny {
        didSet {
            syncToWidget()
        }
    }
    @Published var currentTime: TimeOfDay = .day {
        didSet {
            syncToWidget()
        }
    }
    
    private func syncToWidget() {
        let defaults = UserDefaults(suiteName: "group.com.naufal.WeatherFarm")
        defaults?.set(currentWeather.rawValue, forKey: "savedWeather")
        defaults?.set(currentTime.rawValue, forKey: "savedTime")
        WidgetCenter.shared.reloadAllTimelines()
    }
}
