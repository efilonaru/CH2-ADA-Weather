//
//  WorldEnvironmentManager.swift
//  WeatherFarm
//
//  Created by Michel Pierce on 22/04/26.
//

import Foundation
import Combine

class WorldEnvironmentManager: ObservableObject {
    //ini bisa diubah ygy
    @Published var currentWeather: WeatherCondition = .sunny
    @Published var currentTime: TimeOfDay = .day
}
