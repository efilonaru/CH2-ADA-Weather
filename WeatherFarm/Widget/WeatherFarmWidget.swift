//
//  WeatherFarmWidget.swift
//  WeatherFarm
//
//  Created by Michel Pierce on 23/04/26.
//
import WidgetKit
import SwiftUI
import SwiftData

struct WeatherFarmWidget:Widget {
    let kind:String = "WeatherFarmWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FarmWidgetProvider()){ entry in
            WeatherFarmWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName(Text("Weather Farm"))
        .description(Text("Shows the weather forecast for your farm"))
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
