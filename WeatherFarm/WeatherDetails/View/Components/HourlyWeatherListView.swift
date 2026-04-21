//
//  HourlyWeatherListView.swift
//  WeatherFarm
//
//  Created by Michel Pierce on 20/04/26.
//

import SwiftUI

struct HourlyWeatherListView: View {
    let hourlyData: [HourlyWeather]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 12) {
                ForEach(hourlyData) { hour in
                    HStack {
                        Text(hour.time)
                            .font(.callout)
                            .frame(width: 60, alignment: .leading)
                        
                        Image(systemName: hour.iconName)
                            .font(.title2)
                            .frame(width: 40)
                            .symbolRenderingMode(.multicolor)
                        
                        Spacer()
                        
                        Label("12 mph", systemImage: "wind")
                            .opacity(0.5)
                        
                        Spacer()
                        
                        Text("\(hour.temp)°")
                            .font(.title3)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color(.systemBackground).opacity(0.6))
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    HourlyWeatherListView(hourlyData: MockData.generateHourly(baseTemp: 30, icon: "cloud.sun.fill"))
}
