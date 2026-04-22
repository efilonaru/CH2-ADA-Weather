//
//  CurrentWeatherView.swift
//  WeatherFarm
//
//  Created by Michel Pierce on 20/04/26.
//
import SwiftUI

struct CurrentWeatherView: View {
    let day: DailyWeather
    
    let locationName: String = "Kuta Selatan, Bali"
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            
            VStack(alignment: .center, spacing: 4) {
                Text(locationName)
                    .font(.minecraft(size: 20))
                    .fontWeight(.semibold)
                
                Text("\(day.dayString), \(day.dateString)")
                    .font(.minecraft(size: 16))
                    .foregroundColor(.secondary)
            }
            
            HStack(alignment: .center, spacing: 24) {
                
                Text("\(day.highTemp - 4)°")
                    .font(.system(size: 84, weight: .bold, design: .rounded))
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Mostly Cloudy")
                        .font(.minecraft(size: 20))
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Label("H: \(day.highTemp)° L: \(day.lowTemp)°", systemImage: "thermometer")
                        Label("12 mph", systemImage: "wind")
                        Label("65%", systemImage: "humidity.fill")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
}


    
#Preview {
    CurrentWeatherView(day: DailyWeather(dayString: "Mon", dateString: "Apr 20", isToday: true, iconName: "cloud.sun.fill", highTemp: 31, lowTemp: 25, hourlyData: MockData.generateHourly(baseTemp: 30, icon: "cloud.sun.fill")))
        .font(.minecraft(size: 16))
}


