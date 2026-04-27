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
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), goldAmount: 100, weather: .sunny, time: .day, averageGoldPerCrop:10.0, dayString: "Monday", dateString: "April 26th 2026")
        }

        func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
            let data = await fetchWidgetData()
            return SimpleEntry(date: Date(), configuration: configuration, goldAmount: data.gold, weather: data.weather, time: data.time, averageGoldPerCrop:data.averageGoldPerCrop, dayString: data.dayString, dateString: data.dateString)
        }
        
        func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
            let data = await fetchWidgetData()
            var entries: [SimpleEntry] = []
            for minuteOffset in 0..<60 {
                let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: .now)!
                let projectedGold = data.gold + (minuteOffset * Int(data.averageGoldPerCrop))
                
                let entry = SimpleEntry(date: entryDate, configuration: configuration, goldAmount: projectedGold, weather: data.weather, time: data.time, averageGoldPerCrop:data.averageGoldPerCrop, dayString: data.dayString, dateString: data.dateString)
                entries.append(entry)
            }
            let reloadDate = Calendar.current.date(byAdding: .hour, value: 1, to: .now)!
            return Timeline(entries: entries, policy: .after(reloadDate))
        }
    
    @MainActor
        private func fetchWidgetData() -> (gold: Int, weather: WeatherCondition, time: TimeOfDay, averageGoldPerCrop: Double, dayString: String, dateString: String) {
            var currentGold = 100
            let context = SharedDatabaseManager.shared.container.mainContext
            let descriptor = FetchDescriptor<GameStateSaveData>()
            if let savedState = (try? context.fetch(descriptor))?.first {
                currentGold = savedState.totalGold
            }
            
            let defaults = UserDefaults(suiteName: "group.com.naufal.WeatherFarm")
            let savedW = defaults?.string(forKey: "savedWeather") ?? "sunny"
            let savedT = defaults?.string(forKey: "savedTime") ?? "day"
            let averageGoldPerCrop = defaults?.double(forKey: "averageGoldPerCrop") ?? 10.0
            
            let weather = WeatherCondition(rawValue: savedW) ?? .sunny
            let time = TimeOfDay(rawValue: savedT) ?? .day
            
            let now = Date()
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEEE" // "Monday"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy"
            
            return (currentGold, weather, time, averageGoldPerCrop, dayFormatter.string(from: now), dateFormatter.string(from: now))
        }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let goldAmount: Int
    let weather: WeatherCondition
    let time: TimeOfDay
    let averageGoldPerCrop: Double
    let locationName: String = "Kuta Selatan, Bali"
    let dayString: String
    let dateString: String
}

struct FarmWeatherWidgetEntryView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack{
            HStack{
                // Location + Date
                VStack(alignment: .leading, spacing: 3) {
                    Text(entry.locationName)
                        .font(.minecraft(size: 12))
                        .fontWeight(.semibold)
                    Text("\(entry.dayString), \(entry.dateString)")
                        .font(.minecraft(size: 10))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 3) {
                    Image("coin")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    
                    Text("\(entry.goldAmount)")
                        .font(.minecraft(size: 16))
                }
            }
            .padding(.top, 16)
            .padding(.horizontal, 16)
            
            Spacer()
            
            HourlyWeatherListViewWidget(
                parentHStackSpacing: 4,
                hStackSpacing: 10,
                fontSize: 10,
                iconSize: 16,
                bgOpacity:0
            )
            
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
        .contentMarginsDisabled()
    }
}


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

#Preview(as: .systemMedium) {
    FarmWeatherWidget()
} timeline: {
    SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), goldAmount: 100, weather: .sunny, time: .day, averageGoldPerCrop: 10, dayString: "Monday", dateString: "April 24th 2026")
}
