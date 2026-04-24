//
//  SaveDataModels.swift
//  WeatherFarm
//
//  Created by Michel Pierce on 23/04/26.
//

import Foundation
import SwiftData

@Model
class TileSaveData {
    var gridX: Int
    var gridY: Int
    var hasCrop: Bool
    var cropTextureName: String?
    var plantedAt: Date?
    var harvested: Bool
    
    init(gridX: Int, gridY: Int, hasCrop: Bool = false, cropTextureName: String? = nil, plantedAt: Date? = nil, harvested: Bool = false) {
        self.gridX = gridX
        self.gridY = gridY
        self.hasCrop = hasCrop
        self.cropTextureName = cropTextureName
        self.plantedAt = plantedAt
        self.harvested = harvested
    }
}

@Model
class GameStateSaveData {
    var totalGold: Int
    var lastSavedDate: Date
    
    init(totalGold: Int = 100, lastSavedDate: Date = Date()) {
        self.totalGold = totalGold
        self.lastSavedDate = lastSavedDate
    }
}
