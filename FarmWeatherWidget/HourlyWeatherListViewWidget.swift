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

            Image(item.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize*1.5, height: iconSize*1.5)

            Text("\(item.temp)°")
                .font(.minecraft(size: fontSize))
//                .font(.caption)
        }
        .padding(12)
    }
}

struct HourlyWeatherListViewWidget: View {
    var data: [HourlyWeather] {
        guard let base = MockData.weekForecast.first(where: { $0.isToday })?.hourlyData else {
            return []
        }

        let now = HourlyWeather(
            time: "Now",
            iconName: "sun",
            temp: base.first?.temp ?? 30
        )

        return [now] + base.dropFirst()
    }
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
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .background(.ultraThinMaterial
            .opacity(bgOpacity))

    }
}
