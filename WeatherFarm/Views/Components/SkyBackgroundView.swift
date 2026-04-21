//
//  SkyBackgroundView.swift
//  WeatherFarm
//
//  Created by Michel Pierce on 21/04/26.
//

import SwiftUI


struct SkyBackgroundView: View {
    var weather: WeatherCondition
    var time: TimeOfDay
    
    var skyColors: [Color] {
        switch (weather, time) {
        case (.sunny, .day):
            return [Color(red: 0.4, green: 0.7, blue: 1.0), Color(red: 0.2, green: 0.5, blue: 1.0)]
        case (.sunny, .afternoon):
            return [Color.orange, Color.pink.opacity(0.8), Color.purple.opacity(0.6)]
        case (.sunny, .night):
            return [Color(red: 0.05, green: 0.05, blue: 0.2), Color.black]
        case (.cloudy, .day):
            return [Color.gray.opacity(0.6), Color.gray.opacity(0.9)]
        default:
            return [Color.blue, Color.black]
        }
    }
    
    var body: some View {
        LinearGradient(
            colors: skyColors,
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 2.0), value: skyColors)
    }
}
