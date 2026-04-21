import Foundation

struct CropModel: Identifiable, Codable, Equatable {
    var id = UUID()
    let name: String
    let baseGrowthDuration: TimeInterval
    let textureName: String?
    let value: Int

    static let sampleCrops: [CropModel] = [
        CropModel(name: "Wheat", baseGrowthDuration: 6, textureName: nil, value: 5),
        CropModel(name: "Corn", baseGrowthDuration: 8, textureName: nil, value: 7),
        CropModel(name: "Carrot", baseGrowthDuration: 5, textureName: nil, value: 4)
    ]
}
