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
        let sharedStoreURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.naufal.WeatherFarm")!
            .appendingPathComponent("WeatherFarm.sqlite")
        
        let config = ModelConfiguration(url: sharedStoreURL)
        
        do {
            container = try ModelContainer(for: TileSaveData.self, GameStateSaveData.self, configurations: config)
        } catch {
            fatalError("Failed to initialize shared SwiftData container: \(error)")
        }
    }
}
