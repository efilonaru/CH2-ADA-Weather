//
//  FarmWidgetProvider.swift
//  WeatherFarm
//
//  Created by Michel Pierce on 23/04/26.
//
//
//import WidgetKit
//import SwiftUI
//import SwiftData
//
//struct FarmWidgetProvider: TimelineProvider {
//    @MainActor
//    func fetchGold() -> Int {
//        let context = SharedDatabaseManager.shared.container.mainContext
//        let descriptor = FetchDescriptor<GameStateSaveData>()
//        let state = try! context.fetch(descriptor).first!
//        return state.totalGold
//    }
//    
//    func placeholder(in context: Context) -> FarmWidgetEntry {
//            FarmWidgetEntry(date: Date(), currentWeather: .sunny, currentTime: .day, gold: 100, hourlyForecasts: [])
//        }
//    
//    func getSnapshot(in context: Context, completion: @escaping (FarmWidgetEntry) -> ()) {
//        Task {
//            @MainActor in
//            let entry = FarmWidgetEntry(
//                date: Date(),
//                currentWeather: .sunny,
//                currentTime: .day,
//                gold: fetchGold(),
//                hourlyForecasts: []
//            )
//            completion(entry)
//        }
//    }
//    
//    func getTimeline(in context: Context, completion: @escaping (Timeline<FarmWidgetEntry>) -> ()) {
//        Task { @MainActor in
//            var entries : [FarmWidgetEntry] = []
//            let currentDate = Date()
//            let currentGold = fetchGold()
//            
//            for hourSet in 0..<3 {
//                let entryDate = Calendar.current.date(byAdding: .hour, value: hourSet, to: currentDate)!
//                
//                
//                let mockForecasts: [HourlyForecast] = [
//                    HourlyForecast(time: "+1h", weather: .cloudy),
//                    HourlyForecast(time: "+2h", weather: .sunny),
//                    HourlyForecast(time: "+3h", weather: .extremeHeat),
//                ]
//                
//                let entry = FarmWidgetEntry(
//                    date: entryDate, currentWeather: hourSet == 0 ? .sunny : .extremeHeat, currentTime: .day, gold: currentGold, hourlyForecasts: mockForecasts
//                )
//                    entries.append(entry)
//            }
//            let timeline = Timeline(entries: entries, policy: .atEnd)
//            completion(timeline)
//        }
//    }
//}
