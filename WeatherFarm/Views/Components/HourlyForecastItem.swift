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
        VStack(spacing: 10) {
            Text(item.time)
                .font(.minecraft(size: 24))
//                .font(.caption)

            Image(item.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)


            Text("\(item.temp)°")
                .font(.minecraft(size: 24))
//                .font(.caption)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    HourItemView(item: .init(time: "12 PM", iconName: "cloudy", temp: 20))
}
