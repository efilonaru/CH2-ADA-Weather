import Foundation

struct CropModel: Identifiable, Codable, Equatable {
    let id = UUID()
    let name: String
    let baseGrowthDuration: TimeInterval // seconds to fully grow
    // optional placeholder for texture name (base name, stage assets will be base_seed, base_early, base_ripe)
    let textureName: String?
    // gold awarded on harvest
    let value: Int

    static let sampleCrops: [CropModel] = [
        CropModel(name: "Wheat", baseGrowthDuration: 6, textureName: nil, value: 5),
        CropModel(name: "Corn", baseGrowthDuration: 8, textureName: nil, value: 7),
        CropModel(name: "Carrot", baseGrowthDuration: 5, textureName: nil, value: 4)
    ]
}
