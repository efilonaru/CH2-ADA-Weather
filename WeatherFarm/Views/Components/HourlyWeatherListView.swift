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
                            .font(.minecraft(size: 20))
//                            .font(.callout)
                            .frame(width: 60, alignment: .leading)
                        
                        Spacer()
                        
                        Image(hour.iconName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                        
                        Spacer()
                        
                        Label("12 mph", systemImage: "wind")
                            .opacity(0.5)
                        
                        Spacer()
                        
                        Text("\(hour.temp)°")
                            .font(.minecraft(size: 24))
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
    HourlyWeatherListView(hourlyData: MockData.generateHourly(baseTemp: 30, icon: "cloudy"))
        .font(.minecraft(size:16))
}
