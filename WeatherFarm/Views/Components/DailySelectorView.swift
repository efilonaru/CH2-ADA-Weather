//
//  DailySelectorView.swift
//  WeatherFarm
//
//  Created by Michel Pierce on 20/04/26.
//

import SwiftUI

struct DailySelectorView: View {
    let forecast: [DailyWeather]
    @Binding var selectedDay: DailyWeather
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(forecast) { day in
                        Button(action: {
                            withAnimation(.easeInOut) {
                                selectedDay = day
                            }
                        }) {
                            VStack(spacing: 8) {
                                Text(day.isToday ? "Today" : day.dayString)
                                    .font(.minecraft(size: 20))
                                    .fontWeight(day.isToday ? .bold : .regular)
                                    .foregroundColor(day.isToday ? .blue : .primary)
                                
                                Text(day.dateString)
                                    .font(.minecraft(size: 16))
                                    .foregroundColor(.secondary)
                                
                                Image(day.iconName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 32, height: 32)
                                
                                Text("\(day.highTemp)° / \(day.lowTemp)°")
                                    .font(.minecraft(size: 16))
                                    .foregroundColor(.primary)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(selectedDay == day ? Color.blue.opacity(0.2) : Color(.systemBackground).opacity(0.6))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(selectedDay == day ? Color.blue : Color.clear, lineWidth: 2)
                            )
                        }
                        .id(day.id)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
        }
    }
}



#Preview {
    @Previewable @State var selectedDay: DailyWeather = MockData.weekForecast.first!
    
    DailySelectorView(forecast: MockData.weekForecast, selectedDay: $selectedDay)
}
