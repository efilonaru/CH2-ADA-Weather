//
//  SkyBackgroundWidgetView.swift
//  WeatherFarm
//
//  Created by Michel Pierce on 25/04/26.
//

import SwiftUI

struct WidgetSkyBackgroundView: View {
    var weather: WeatherCondition
    var time: TimeOfDay
    
    var imageSuffix: String {
        switch (weather, time) {
        case (.sunny, .dawn), (.extremeHeat, .dawn): return "dawn_sunny"
        case (.sunny, .day), (.extremeHeat, .day): return "day_sunny"
        case (.sunny, .afternoon), (.extremeHeat, .afternoon): return "afternoon_sunny"
        case (.sunny, .night), (.extremeHeat, .night): return "night_sunny"
            
        case (.cloudy, .dawn), (.snow, .dawn): return "dawn_cloudy"
        case (.cloudy, .day), (.snow, .day): return "dawn_cloudy"
        case (.cloudy, .afternoon), (.snow, .afternoon): return "dawn_cloudy"
        case (.cloudy, .night), (.snow, .night): return "night_cloudy"
            
        case (.rain, .dawn): return "dawn_cloudy"
        case (.rain, .day): return "afternoon_rainy"
        case (.rain, .afternoon): return "afternoon_rainy"
        case (.rain, .night): return "night_cloudy"
        }
    }
    
    var body: some View {
        ZStack {
            Image("bg_\(imageSuffix)_1").resizable()
                .scaledToFill()
                .opacity(1.0)
            
            Image("bg_\(imageSuffix)_2").resizable()
                .scaledToFill()
                .opacity(0.5)
            
            Image("bg_\(imageSuffix)_3").resizable()
                .scaledToFill()
                .opacity(0.4)
            
            Image("bg_\(imageSuffix)_4").resizable()
                .scaledToFill()
                .opacity(0.3)
        }
    }
}
