import SwiftData
//
//  WeatherFarmWidgetEntryView.swift
//  WeatherFarm
//
//  Created by Michel Pierce on 23/04/26.
//
import SwiftUI
import WidgetKit

//struct WeatherFarmWidgetEntryView: View {
//    var entry: FarmWidgetProvider.Entry
//
//    var backgroundName: String {
//        switch (entry.currentWeather, entry.currentTime) {
//        case (.sunny, .dawn), (.extremeHeat, .dawn): return "dawn_sunny"
//        case (.sunny, .day), (.extremeHeat, .day): return "day_sunny"
//        case (.sunny, .afternoon), (.extremeHeat, .afternoon):
//            return "afternoon_sunny"
//        case (.sunny, .night), (.extremeHeat, .night): return "night_sunny"
//        case (.cloudy, .dawn), (.snow, .dawn), (.cloudy, .day), (.snow, .day),
//            (.cloudy, .afternoon), (.snow, .afternoon):
//            return "dawn_cloudy"
//        case (.cloudy, .night), (.snow, .night): return "night_cloudy"
//        case (.rain, .dawn): return "dawn_cloudy"
//        case (.rain, .day), (.rain, .afternoon): return "afternoon_rainy"
//        case (.rain, .night): return "night_cloudy"
//        }
//    }
//
//    var body: some View {
//        ZStack {
//            Image(backgroundName)
//                .resizable()
//                .scaledToFill()
//
//            LinearGradient(
//                colors: [.black.opacity(0.4), .clear, .black.opacity(0.4)],
//                startPoint: .top,
//                endPoint: .bottom
//            )
//
//            VStack {
//                HStack(alignment: .top) {
//                    HStack(spacing: 4) {
//                        Image(systemName: "coins")
//                            .foregroundColor(.yellow)
//                        Text("\(entry.gold)")
//                            .font(.headline)
//                            .bold()
//                            .foregroundColor(.white)
//                    }
//
//                    Spacer()
//
//                    VStack(alignment: .trailing) {
//                        Image(systemName: entry.currentWeather.icon)
//                            .font(.title)
//                            .foregroundColor(.white)
//                        Text(
//                            "\(entry.currentWeather.exampleStats.currentTemp)°"
//                        )
//                        .font(.title2)
//                        .bold()
//                        .foregroundColor(.white)
//                    }
//                }
//
//                Spacer()
//
//                HStack(spacing: 16) {
//                    ForEach(entry.hourlyForecasts, id: \.time) { forecast in
//                        VStack(spacing: 4) {
//                            Text(forecast.time)
//                                .font(.caption2)
//                                .foregroundColor(.white.opacity(0.8))
//                            Image(systemName: forecast.weather.icon)
//                                .font(.caption)
//                                .foregroundColor(.white)
//                        }
//                        .padding(8)
//                        .background(.black.opacity(0.3))
//                        .cornerRadius(8)
//                    }
//                }
//            }
//            .padding()
//        }
//    }
//}
