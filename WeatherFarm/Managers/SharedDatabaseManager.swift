//
//  SwiftDataManager.swift
//  WeatherFarm
//
//  Created by Michel Pierce on 21/04/26.
//


import Foundation
import SwiftData

@MainActor
class SharedDatabaseManager {
    static let shared = SharedDatabaseManager()
    
    let container: ModelContainer
    
    private init() {
        let containerURL: URL
        if let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.naufal.WeatherFarm") {
            containerURL = groupURL.appendingPathComponent("WeatherFarm.sqlite")
        } else {
            // Fallback to local documents directory if App Group is not configured
            containerURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("WeatherFarm.sqlite")
            print("WARNING: App Group 'group.com.naufal.WeatherFarm' not found. Falling back to local storage. Widgets will not share data.")
        }
        
        let config = ModelConfiguration(url: containerURL)
        
        do {
            container = try ModelContainer(for: TileSaveData.self, GameStateSaveData.self, configurations: config)
        } catch {
            // If migration fails, try to recreate the store (use only in development)
            do {
                let fallbackContainer = try ModelContainer(for: TileSaveData.self, GameStateSaveData.self)
                container = fallbackContainer
            } catch {
                fatalError("Failed to initialize SwiftData container: \(error)")
            }
        }
    }
}
