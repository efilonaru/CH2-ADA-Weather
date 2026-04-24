//
//  WeatherForecast.swift
//  WeatherFarm
//
//  Created by Naufal Muafa on 21/04/26.
//

import SwiftUI

struct WeatherForecast: View {
    let mockData: [HourlyWeather] = [
        HourlyWeather(time: "Now", iconName: "moon.stars.fill", temp: 26),
        HourlyWeather(time: "22", iconName: "moon.stars.fill", temp: 26),
        HourlyWeather(time: "23", iconName: "moon.stars.fill", temp: 26),
        HourlyWeather(time: "00", iconName: "moon.stars.fill", temp: 25),
        HourlyWeather(time: "01", iconName: "moon.stars.fill", temp: 25),
    ]
    let data: [HourlyWeather]

    var body: some View {
        HStack(spacing: 0) {
            if let first = data.first {
                HourItemView(item: first)
                    .frame(width: 70)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(data.dropFirst()) { item in
                        HourItemView(item: item)
                            .frame(width: 70)
                    }
                }
            }
        }

        .background(.ultraThinMaterial
            .opacity(0.8))

    }
}

#Preview {
    WeatherForecast(data: [
        HourlyWeather(time: "Now", iconName: "moon.stars.fill", temp: 26),
        HourlyWeather(time: "22", iconName: "moon.stars.fill", temp: 26),
        HourlyWeather(time: "23", iconName: "moon.stars.fill", temp: 26),
        HourlyWeather(time: "00", iconName: "moon.stars.fill", temp: 25),
        HourlyWeather(time: "01", iconName: "moon.stars.fill", temp: 25),
    ])
}
