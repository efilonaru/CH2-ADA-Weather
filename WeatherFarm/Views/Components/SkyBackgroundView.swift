//
//  SkyBackgroundView.swift
//  WeatherFarm
//
//  Created by Michel Pierce on 21/04/26.
//
import SwiftUI

struct SkyBackgroundView: View {
    var weather: WeatherCondition
    var time: TimeOfDay
    
    var imageSuffix: String {
        let weatherStr = String(describing: weather) // e.g., "sunny", "stormy"
        let timeStr = String(describing: time)       // e.g., "day", "afternoon", "night"
        return "\(timeStr)_\(weatherStr)"
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("bg_\(imageSuffix)_1").resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .opacity(1.0)
                
                Image("bg_\(imageSuffix)_2").resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .opacity(0.5)
                
                Image("bg_\(imageSuffix)_3").resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .opacity(0.4)
                
                ScrollingCloudLayer(imageName: "bg_\(imageSuffix)_4", speed: 30.0)
            }
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 2.0), value: imageSuffix)
    }
}


struct ScrollingCloudLayer: View {
    let imageName: String
    let speed: Double
    
    @State private var isAnimating = false
    
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
            }
            .offset(x: isAnimating ? -geo.size.width : 0)
            .animation(
                .linear(duration: speed).repeatForever(autoreverses: false),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
            .onChange(of: imageName) { _, _ in
                isAnimating = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    isAnimating = true
                }
            }
        }
        .clipped()
        .opacity(0.3)
    }
}
