import Foundation
import SwiftUI
import Combine
import SwiftData

struct TileSelection: Identifiable, Equatable {
    let id = UUID()
    let gridX: Int
    let gridY: Int
}

struct PlantRequest {
    let gridX: Int
    let gridY: Int
    let crop: CropModel
}

struct HarvestRequest {
    let gridX: Int
    let gridY: Int
}

final class GameViewModel: ObservableObject {
    var worldManager: WorldEnvironmentManager?
    var modelContext: ModelContext?
    @Published var selectedTile: TileSelection? = nil
    @Published var gold: Int = 100
    
    var savedTilesData: [TileSaveData] = []
    
    @Published var inventory: [String: Int] = [:]
    
    // Navigation and Mode flags
    @Published var showShop = false
    @Published var showInventory = false
    @Published var showSettings = false
    @Published var isEditMode = false
    
    // Game State untuk weather kita ga pake dulu, make universal sek
//    @Published var currentWeather: WeatherCondition = .sunny
    @Published var plantedCrops: [String: CropModel] = [:] // Key: "x:y"
    
    @Published var showConfirmation = false
    @Published var confirmationMessage = ""
    var onConfirm: (() -> Void)? = nil

    let crops: [CropModel] = CropModel.sampleCrops
    let plantRequest = PassthroughSubject<PlantRequest, Never>()
    let harvestRequest = PassthroughSubject<HarvestRequest, Never>()

    var potentialGoldSummary: Int {
        plantedCrops.values.reduce(0) { $0 + $1.value }
    }

    var currentWeatherBonus: Int {
        guard let currentTargetWeather = worldManager?.currentWeather else {
                    return 0
                }
                
                return plantedCrops.values.reduce(0) { sum, crop in
                    let bonus = (crop.preferredWeather == currentTargetWeather) ? Int(Double(crop.value) * 0.2) : 0
                    return sum + bonus
                }
    }
    
    var averageGoldPerCrop: Double {
        guard !plantedCrops.isEmpty else { return 0.0 }
        let total = Double(gold) + Double(currentWeatherBonus)
        return total / Double(plantedCrops.count)
    }
    
    func loadSavedGameState() {
        guard let modelContext else { return }
        
        let goldDescriptor = FetchDescriptor<GameStateSaveData>()
        let savedState: GameStateSaveData
        
        if let existingState = (try? modelContext.fetch(goldDescriptor))?.first {
            savedState = existingState
            self.gold = savedState.totalGold
            self.inventory = savedState.inventory
        } else {
            let initialInventory = ["Corn": 5]
            savedState = GameStateSaveData(totalGold: 100, inventory: initialInventory)
            modelContext.insert(savedState)
            self.gold = 100
            self.inventory = initialInventory
        }
        
        let timeAway = Date().timeIntervalSince(savedState.lastSavedDate)
        var totalIdleGold = 0
        
        let tileDescriptor = FetchDescriptor<TileSaveData>()
        if let savedTiles = try? modelContext.fetch(tileDescriptor) {
            for tile in savedTiles {
                if tile.hasCrop, let cropName = tile.cropTextureName, 
                   let crop = crops.first(where: { $0.textureName == cropName }) {
                    
                    plantedCrops["\(tile.gridX):\(tile.gridY)"] = crop
                    
                    if let plantedAt = tile.plantedAt {
                        let growthDuration = crop.baseGrowthDuration
                        let timeSincePlanted = Date().timeIntervalSince(plantedAt)
                        
                        if timeSincePlanted >= growthDuration {
                            let cycles = Int(timeSincePlanted / growthDuration)
                            let goldPerCycle = crop.value
                            
                            totalIdleGold += cycles * goldPerCycle
                            
                            let remainingTime = timeSincePlanted.truncatingRemainder(dividingBy: growthDuration)
                            tile.plantedAt = Date().addingTimeInterval(-remainingTime)
                        }
                    }
                }
            }
        }
        
        if totalIdleGold > 0 {
            self.gold += totalIdleGold
            savedState.totalGold = self.gold
            self.confirmationMessage = "While you were away, your farm earned $\(totalIdleGold)!"
            self.showConfirmation = true
        }
        
        savedState.lastSavedDate = Date()
        try? modelContext.save()
    }

    func saveGameState() {
        guard let modelContext else { return }
        let goldDescriptor = FetchDescriptor<GameStateSaveData>()
        if let savedState = (try? modelContext.fetch(goldDescriptor))?.first {
            savedState.totalGold = self.gold
            savedState.inventory = self.inventory
            savedState.lastSavedDate = Date()
        }
        try? modelContext.save()
    }
    
    func savePlantedCrop(x: Int, y: Int, textureName: String) {
        guard let context = modelContext else { return }
        
        let descriptor = FetchDescriptor<TileSaveData>(predicate: #Predicate { $0.gridX == x && $0.gridY == y })
        
        if let existingTile = (try? context.fetch(descriptor))?.first {
            existingTile.hasCrop = true
            existingTile.cropTextureName = textureName
            existingTile.plantedAt = Date()
            existingTile.harvested = false
        } else {
            let newSaveTile = TileSaveData(gridX: x, gridY: y, hasCrop: true, cropTextureName: textureName, plantedAt: Date(), harvested: false)
            context.insert(newSaveTile)
        }
        
        try? context.save()
    }
    
    func saveHarvested(x: Int, y: Int, goldEarned: Int) {
        guard let context = modelContext else { return }
        
        let descriptor = FetchDescriptor<TileSaveData>(predicate: #Predicate { $0.gridX == x && $0.gridY == y })
        
        if let tileToUpdate = try? context.fetch(descriptor).first {
            tileToUpdate.hasCrop = false
            tileToUpdate.cropTextureName = nil
            tileToUpdate.plantedAt = nil
            tileToUpdate.harvested = true
        }
        
        let goldDescriptor = FetchDescriptor<GameStateSaveData>()
        if let savedState = (try? context.fetch(goldDescriptor))?.first {
            savedState.totalGold = self.gold
            savedState.lastSavedDate = Date()
        }
        try? context.save()
    }

    func selectTile(x: Int, y: Int) {
        DispatchQueue.main.async {
            self.selectedTile = TileSelection(gridX: x, gridY: y)
        }
    }

    func deselectTile() {
        DispatchQueue.main.async {
            self.selectedTile = nil
        }
    }

    func toggleEditMode() {
        isEditMode.toggle()
        deselectTile()
    }

    func requestConfirmation(message: String, action: @escaping () -> Void) {
        self.confirmationMessage = message
        self.onConfirm = action
        self.showConfirmation = true
    }

    func requestPlant(crop: CropModel) {
        guard let s = selectedTile else { return }
        
        let count = inventory[crop.name] ?? 0
        if count > 0 {
            inventory[crop.name] = count - 1
            plantedCrops["\(s.gridX):\(s.gridY)"] = crop
            
            savePlantedCrop(x: s.gridX, y: s.gridY, textureName: crop.textureName ?? "")
            saveGameState() // Update inventory in DB
            
            let req = PlantRequest(gridX: s.gridX, gridY: s.gridY, crop: crop)
            plantRequest.send(req)
            deselectTile()
        }
    }

    func buyCrop(_ crop: CropModel) {
        requestConfirmation(message: "Buy \(crop.name) for $\(crop.buyPrice)?") {
            if self.spendGold(crop.buyPrice) {
                self.inventory[crop.name, default: 0] += 1
                self.saveGameState()
            }
        }
    }

    func requestHarvest(x: Int, y: Int) {
        plantedCrops.removeValue(forKey: "\(x):\(y)")
        harvestRequest.send(HarvestRequest(gridX: x, gridY: y))
        deselectTile()
    }

    func awardGold(_ amount: Int) {
        DispatchQueue.main.async {
            self.gold += amount
        }
    }

    func notifyAutoHarvest(x: Int, y: Int, goldAwarded: Int, newPlantedDate: Date? = nil) {
        self.awardGold(goldAwarded)
        
        guard let context = modelContext else { return }
        
        let descriptor = FetchDescriptor<TileSaveData>(predicate: #Predicate { $0.gridX == x && $0.gridY == y })
        if let tile = (try? context.fetch(descriptor))?.first {
            if let newDate = newPlantedDate {
                tile.plantedAt = newDate
            } else {
                tile.hasCrop = false
                tile.plantedAt = nil
            }
        }
        
        saveGameState()
    }

    func spendGold(_ amount: Int) -> Bool {
        guard amount >= 0 else { return true }
        if self.gold >= amount {
            self.gold -= amount
            return true
        }
        return false
    }
    
    func getOwnedCrops() -> [CropModel] {
        return crops.filter { (inventory[$0.name] ?? 0) > 0 }
    }
}
