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
        switch (weather, time) {
            
            // SUNNY
        case (.sunny, .dawn):
            return "dawn_sunny"
        case (.sunny, .day):
            return "day_sunny"
        case (.sunny, .afternoon):
            return "afternoon_sunny"
        case (.sunny, .night):
            return "night_sunny"
            
        case (.extremeHeat, .dawn):
            return "dawn_sunny"
        case (.extremeHeat, .day):
            return "afternoon_extremeHeat"
        case (.extremeHeat, .afternoon):
            return "afternoon_extremeHeat"
        case (.extremeHeat, .night):
            return "night_sunny"
        case (.cloudy, .dawn):
            return "dawn_cloudy"
        case (.cloudy, .day):
            return "dawn_cloudy"
        case (.cloudy, .afternoon):
            return "dawn_cloudy"
        case (.cloudy, .night):
            return "night_cloudy"
            
            
        case (.snow, .dawn):
            return "dawn_cloudy"
        case (.snow, .day):
            return "dawn_cloudy"
        case (.snow, .afternoon):
            return "dawn_cloudy"
        case (.snow, .night):
            return "night_cloudy"
            
            // RAIN
        case (.rain, .dawn):
            return "dawn_cloudy"             // no dawn_rainy, cloudy is closest
        case (.rain, .day):
            return "afternoon_rainy"         // no day_rainy, afternoon_rainy is closest
        case (.rain, .afternoon):
            return "afternoon_rainy"
        case (.rain, .night):
            return "night_cloudy"            // no night_rainy, dark cloudy is closest
            
        }
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

                ScrollingCloudLayer(
                    imageName: "bg_\(imageSuffix)_4",
                    speed: 30.0
                )
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
            let imageWidth = geo.size.width
            let imageHeight = geo.size.height / 3  // landscape ratio, tweak this

            HStack(spacing: 0) {
                Image(imageName)
                    .resizable()
                    .frame(width: imageWidth, height: imageHeight)

                Image(imageName)
                    .resizable()
                    .frame(width: imageWidth, height: imageHeight)
            }
            .frame(
                width: imageWidth * 2,
                height: imageHeight,
                alignment: .leading
            )
            .offset(
                x: isAnimating ? -imageWidth : 0,
                y: (geo.size.height - imageHeight) / 1
            )  // vertically centered, y is fixed
            .animation(
                .linear(duration: speed).repeatForever(autoreverses: false),
                value: isAnimating
            )
            .onAppear { isAnimating = true }
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

#Preview {
    SkyBackgroundView(weather: .sunny, time: .day)
}
