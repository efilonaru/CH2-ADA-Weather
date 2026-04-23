//
//  WeatherFarmApp.swift
//  WeatherFarm
//
//  Created by Naufal Muafa on 19/04/26.
//

import SwiftUI

@main
struct WeatherFarmApp: App {
    @StateObject private var worldManager = WorldEnvironmentManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(worldManager)
                .font(.minecraft())
                .preferredColorScheme(ColorScheme.light)
        }
    }
}
