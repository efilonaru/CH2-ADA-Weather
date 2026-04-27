//
//  FarmWeatherWidget.swift
//  FarmWeatherWidget
//
//  Created by Michel Pierce on 24/04/26.
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: AppIntentTimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
            SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), goldAmount: 100, weather: .sunny, time: .day)
        }

        func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
            let data = await fetchWidgetData()
            return SimpleEntry(date: Date(), configuration: configuration, goldAmount: data.gold, weather: data.weather, time: data.time)
        }
        
        func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
            let data = await fetchWidgetData()
            let entry = SimpleEntry(date: Date(), configuration: configuration, goldAmount: data.gold, weather: data.weather, time: data.time)
            return Timeline(entries: [entry], policy: .never)
        }
    
    @MainActor
        private func fetchWidgetData() -> (gold: Int, weather: WeatherCondition, time: TimeOfDay) {
            var currentGold = 100
            let context = SharedDatabaseManager.shared.container.mainContext
            let descriptor = FetchDescriptor<GameStateSaveData>()
            if let savedState = (try? context.fetch(descriptor))?.first {
                currentGold = savedState.totalGold
            }
            
            let defaults = UserDefaults(suiteName: "group.com.naufal.WeatherFarm")
            let savedW = defaults?.string(forKey: "savedWeather") ?? "extremeHeat"
            let savedT = defaults?.string(forKey: "savedTime") ?? "afternoon"
            
            let weather = WeatherCondition(rawValue: savedW) ?? .extremeHeat
            let time = TimeOfDay(rawValue: savedT) ?? .afternoon
            
            return (currentGold, weather, time)
        }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let goldAmount: Int
    let weather: WeatherCondition
    let time: TimeOfDay
}

struct FarmWeatherWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("💰 Gold")
                .font(.headline)
                .foregroundColor(.white)
                .shadow(color: .black, radius: 1, x: 1, y: 1)
            
            Text("\(entry.goldAmount)")
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .foregroundColor(.yellow)
                .shadow(color: .black, radius: 1, x: 1, y: 1)
        }
    }
}

struct FarmWeatherWidget: Widget {
    let kind: String = "FarmWeatherWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            FarmWeatherWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    WidgetSkyBackgroundView(weather: entry.weather, time: entry.time)
                }
        }
    }
}
//
//struct Provider: AppIntentTimelineProvider {
//    func placeholder(in context: Context) -> SimpleEntry {
//        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
//    }
//
//    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
//        SimpleEntry(date: Date(), configuration: configuration)
//    }
//    
//    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
//        var entries: [SimpleEntry] = []
//
//        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
//        let currentDate = Date()
//        for hourOffset in 0 ..< 5 {
//            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
//            let entry = SimpleEntry(date: entryDate, configuration: configuration)
//            entries.append(entry)
//        }
//
//        return Timeline(entries: entries, policy: .atEnd)
//    }
//
////    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
////        // Generate a list containing the contexts this widget is relevant in.
////    }
//}
//
//struct SimpleEntry: TimelineEntry {
//    let date: Date
//    let configuration: ConfigurationAppIntent
//}
//
//struct FarmWeatherWidgetEntryView : View {
//    var entry: Provider.Entry
//
//    var body: some View {
//        VStack {
//            Text("Time:")
//            Text(entry.date, style: .time)
//
//            Text("Favorite Emoji:")
//            Text(entry.configuration.favoriteEmoji)
//        }
//    }
//}
//
//struct FarmWeatherWidget: Widget {
//    let kind: String = "FarmWeatherWidget"
//
//    var body: some WidgetConfiguration {
//        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
//            FarmWeatherWidgetEntryView(entry: entry)
//                .containerBackground(.fill.tertiary, for: .widget)
//        }
//    }
//}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

//#Preview(as: .systemSmall) {
//    FarmWeatherWidget()
//} timeline: {
//    SimpleEntry(date: .now, configuration: .smiley)
//    SimpleEntry(date: .now, configuration: .starEyes)
//}
