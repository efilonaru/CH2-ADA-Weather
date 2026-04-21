import Foundation

struct CropModel: Identifiable, Codable, Equatable {
    let id = UUID()
    let name: String
    let baseGrowthDuration: TimeInterval
    let textureName: String?
    let value: Int
    // gold cost in shop
    let buyPrice: Int
    // climate requirement for filtering and potential growth bonus
    let preferredWeather: WeatherCondition

    static let sampleCrops: [CropModel] = [
        CropModel(name: "Corn", baseGrowthDuration: 6, textureName: nil, value: 5, buyPrice: 2, preferredWeather: .sunny),
        CropModel(name: "Sunflower", baseGrowthDuration: 8, textureName: nil, value: 7, buyPrice: 3, preferredWeather: .sunny),
        CropModel(name: "Rice", baseGrowthDuration: 5, textureName: nil, value: 4, buyPrice: 1, preferredWeather: .rain),
        CropModel(name: "Cranberries", baseGrowthDuration: 10, textureName: nil, value: 12, buyPrice: 5, preferredWeather: .rain),
        CropModel(name: "Kale", baseGrowthDuration: 8, textureName: nil, value: 10, buyPrice: 6, preferredWeather: .snow),
        CropModel(name: "Frost Berries", baseGrowthDuration: 16, textureName: nil, value: 16, buyPrice: 12, preferredWeather: .snow),
        CropModel(name: "Aloe Vera", baseGrowthDuration: 18, textureName: nil, value: 12, buyPrice: 6, preferredWeather: .extremeHeat),
        CropModel(name: "Wheat", baseGrowthDuration: 15, textureName: nil, value: 20, buyPrice: 8, preferredWeather: .extremeHeat)
    ]
}
