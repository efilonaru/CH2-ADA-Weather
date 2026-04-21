//
//  WeatherDetailsView.swift
//  WeatherFarm
//
//  Created by Michel Pierce on 20/04/26.
//

import SwiftUI

struct WeatherDetailsView: View {
    @State private var selectedDay: DailyWeather = MockData.weekForecast.first(where: { $0.isToday})!
    
    var body: some View {
        ZStack {
            Color.blue.opacity(0.1).ignoresSafeArea()
            
            VStack(spacing: 20) {
                CurrentWeatherView(day: selectedDay)
                
                Text("Hourly Forecast")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                HourlyWeatherListView(hourlyData: selectedDay.hourlyData)
                
                DailySelectorView(
                    forecast: MockData.weekForecast,
                    selectedDay: $selectedDay 
                )
            }
            .padding(.top)
        }
    }
}

#Preview {
    WeatherDetailsView()
}

