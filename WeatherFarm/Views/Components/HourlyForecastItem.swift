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
                .font(.minecraft(size: 16))

            Image(systemName: item.iconName)
                .font(Font.system(size: 24, design: .default))

            Text("\(item.temp)°")
                .font(.minecraft(size: 16))
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HourItemView(item: .init(time: "12:00", iconName: "cloud.rain", temp: 20))
}
