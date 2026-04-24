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
    
    
    // Inventory: Mapping of Crop name to quantity owned
    @Published var inventory: [String: Int] = [
        "Wheat": 5 // Starting seeds
    ]
    
    // Navigation and Mode flags
    @Published var showShop = false
    @Published var showInventory = false
    @Published var showSettings = false
    @Published var isEditMode = false
    
    // Game State untuk weather kita ga pake dulu, make universal sek
//    @Published var currentWeather: WeatherCondition = .sunny
    @Published var plantedCrops: [String: CropModel] = [:] // Key: "x:y"
    
    // Confirmation Dialog State
    @Published var showConfirmation = false
    @Published var confirmationMessage = ""
    var onConfirm: (() -> Void)? = nil

    // Available crops and communication channels
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
    
    func loadSavedGameState(){
        guard let modelContext else { return }
        
        let goldDescriptor = FetchDescriptor<GameStateSaveData>()
        if let savedState = (try? modelContext.fetch(goldDescriptor))?.first {
            self.gold = savedState.totalGold
        } else {
            let newState = GameStateSaveData(totalGold: 100)
            modelContext.insert(newState)
        }
        
        let tileDescriptor = FetchDescriptor<TileSaveData>()
        if let savedTiles = try? modelContext.fetch(tileDescriptor) {
            for tile in savedTiles where tile.hasCrop {
                
            }
        }
    }
    
    func savePlantedCrop (x: Int, y:Int, textureName: String){
        guard let context = modelContext else { return }
        let newSaveTile = TileSaveData(gridX: x, gridY: y, hasCrop: true, cropTextureName: textureName, plantedAt: Date(), harvested: false)
        
        context.insert(newSaveTile)
        try? context.save()
    }
    
    func saveHarvested (x: Int, y:Int, goldEarned:Int){
        guard let context = modelContext else { return }
        
        let descriptor = FetchDescriptor<TileSaveData>(predicate: #Predicate{$0.gridX == x && $0.gridY == y})
        
        if let tileToUpdate = try? context.fetch(descriptor).first {
            tileToUpdate.hasCrop = false
            tileToUpdate.harvested = true
        }
        
        let goldDescriptor = FetchDescriptor<GameStateSaveData>()
        if let savedState = (try? context.fetch(goldDescriptor))?.first {
            savedState.totalGold += goldEarned
            self.gold = savedState.totalGold
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

    // Planting logic: consume from inventory and track state
    func requestPlant(crop: CropModel) {
        guard let s = selectedTile else { return }
        
        // Verify inventory
        let count = inventory[crop.name] ?? 0
        if count > 0 {
            inventory[crop.name] = count - 1
            plantedCrops["\(s.gridX):\(s.gridY)"] = crop
            let req = PlantRequest(gridX: s.gridX, gridY: s.gridY, crop: crop)
            plantRequest.send(req)
            deselectTile()
        }
    }

    func buyCrop(_ crop: CropModel) {
        requestConfirmation(message: "Buy \(crop.name) for $\(crop.buyPrice)?") {
            if self.spendGold(crop.buyPrice) {
                self.inventory[crop.name, default: 0] += 1
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

    // Called by scene during auto-harvest to keep summary in sync
    func notifyAutoHarvest(x: Int, y: Int, goldAwarded: Int) {
        self.awardGold(goldAwarded)
        // If autoReplant is true in scene, the crop stays the same, 
        // but if it were false, we would remove it here.
    }

    func spendGold(_ amount: Int) -> Bool {
        guard amount >= 0 else { return true }
        if self.gold >= amount {
            self.gold -= amount
            return true
        }
        return false
    }
    
    // Helper to get owned crops for the planting modal
    func getOwnedCrops() -> [CropModel] {
        return crops.filter { (inventory[$0.name] ?? 0) > 0 }
    }
}
