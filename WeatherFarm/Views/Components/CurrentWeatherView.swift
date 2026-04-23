//
//  CurrentWeatherView.swift
//  WeatherFarm
//
//  Created by Michel Pierce on 20/04/26.
//
import SwiftUI

struct CurrentWeatherView: View {
    let day: DailyWeather
    
    @EnvironmentObject var worldManager : WorldEnvironmentManager
    
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
                
                Text("\(worldManager.currentWeather.exampleStats.currentTemp)°")
                    .font(.system(size: 84, weight: .bold, design: .rounded))
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(worldManager.currentWeather.conditionsExample)
                        .font(.minecraft(size: 20))
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Label("H: \(worldManager.currentWeather.exampleStats.highTemp)° L: \(worldManager.currentWeather.exampleStats.lowTemp)°", systemImage: "thermometer")
                        Label(worldManager.currentWeather.exampleStats.windSpeed, systemImage: "wind")
                        Label(worldManager.currentWeather.exampleStats.humidity, systemImage: "humidity.fill")
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
        .environmentObject(WorldEnvironmentManager())
}


