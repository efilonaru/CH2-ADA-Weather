//
//  HourlyForecastViewWidget.swift
//  WeatherFarm
//
//  Created by Michel Pierce on 27/04/26.
//

import SwiftUI

struct HourItemViewWidget: View {
    let item: HourlyWeather
    var fontSize: CGFloat = 12
    var iconSize: CGFloat = 16

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(item.time)
                .font(.minecraft(size: fontSize))
//                .font(.caption)

            Image(systemName: item.iconName)
                .font(Font.system(size: iconSize, weight: .bold, design: .default))

            Text("\(item.temp)°")
                .font(.minecraft(size: fontSize))
//                .font(.caption)
        }
        .padding(12)
    }
}

struct HourlyWeatherListViewWidget: View {
    let data: [HourlyWeather] = MockData.generateHourly(baseTemp: 30, icon: "cloud.sun.fill")
    var parentHStackSpacing: CGFloat = 0
    var hStackSpacing: CGFloat = 16
    var fontSize: CGFloat = 12
    var iconSize: CGFloat = 16
    var bgOpacity: Double = 0.4

    var body: some View {
        HStack(spacing: parentHStackSpacing) {
            if let first = data.first {
                HourItemViewWidget(item: first, fontSize: fontSize, iconSize: iconSize)
            }

                HStack(spacing: hStackSpacing) {
                    ForEach(data.dropFirst().prefix(5)) { item in
                        HourItemViewWidget(item: item, fontSize: fontSize, iconSize: iconSize)
                    }
                }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .background(.ultraThinMaterial
            .opacity(bgOpacity))

    }
}
