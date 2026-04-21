//
//  HourlyForecastItem.swift
//  WeatherFarm
//
//  Created by Naufal Muafa on 21/04/26.
//
import SwiftUI

struct HourItemView: View {
    let item: HourlyWeather

    var body: some View {
        VStack(spacing: 6) {
            Text(item.time)
                .font(.caption)

            Image(systemName: item.iconName)

            Text("\(item.temp)°")
                .font(.caption)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    HourItemView(item: .init(time: "12:00", iconName: "cloud.rain", temp: 20))
}
