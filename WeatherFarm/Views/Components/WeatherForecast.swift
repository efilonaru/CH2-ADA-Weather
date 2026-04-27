//
//  WeatherForecast.swift
//  WeatherFarm
//
//  Created by Naufal Muafa on 21/04/26.
//

import SwiftUI

struct WeatherForecast: View {
    let data: [HourlyWeather]

    var body: some View {
        HStack(spacing: 0) {
            if let first = data.first {
                HourItemView(item: first)
                    .frame(width: 54)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(data.dropFirst()) { item in
                        HourItemView(item: item)
                            .frame(width: 54)
                    }
                }
            }
        }

        .background(.ultraThinMaterial
            .opacity(0.8))

    }
}
