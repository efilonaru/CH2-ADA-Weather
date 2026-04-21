import Foundation
import SwiftUI
import Combine

struct TileSelection: Identifiable, Equatable {
    let id = UUID()
    let gridX: Int
    let gridY: Int
}

// PlantRequest used to communicate from SwiftUI down to the Scene
struct PlantRequest {
    let gridX: Int
    let gridY: Int
    let crop: CropModel
}

// HarvestRequest used to communicate harvest intent from UI down to the Scene (or vice-versa)
struct HarvestRequest {
    let gridX: Int
    let gridY: Int
}

final class GameViewModel: ObservableObject {
    @Published var selectedTile: TileSelection? = nil

    // Catalog of available crops
    let crops: [CropModel] = CropModel.sampleCrops

    // A simple passthrough subject for plant requests. Scene listens to this.
    let plantRequest = PassthroughSubject<PlantRequest, Never>()

    // Harvest requests (from UI) — scene listens and performs harvest
    let harvestRequest = PassthroughSubject<HarvestRequest, Never>()

    // Gold balance
    // Starting gold (tweak this for testing / game tuning)
    @Published var gold: Int = 100

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

    func requestPlant(crop: CropModel) {
        guard let s = selectedTile else { return }
        let req = PlantRequest(gridX: s.gridX, gridY: s.gridY, crop: crop)
        plantRequest.send(req)
        // Close modal on request
        deselectTile()
    }

    func requestHarvest(x: Int, y: Int) {
        harvestRequest.send(HarvestRequest(gridX: x, gridY: y))
        // Close modal after harvest
        deselectTile()
    }

    // Called by scene when a harvest succeeds to award gold
    func awardGold(_ amount: Int) {
        DispatchQueue.main.async {
            self.gold += amount
        }
    }

    // Check if the player has at least amount gold
    func canAfford(_ amount: Int) -> Bool {
        return gold >= amount
    }

    // Attempt to spend gold; returns true if successful
    @discardableResult
    func spendGold(_ amount: Int) -> Bool {
        guard amount > 0 else { return true }
        if Thread.isMainThread {
            if self.gold >= amount {
                self.gold -= amount
                return true
            } else {
                return false
            }
        } else {
            var success = false
            DispatchQueue.main.sync {
                if self.gold >= amount {
                    self.gold -= amount
                    success = true
                } else {
                    success = false
                }
            }
            return success
        }
    }
}
