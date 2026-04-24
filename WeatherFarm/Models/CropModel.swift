import Foundation

struct CropModel: Identifiable, Codable, Equatable {
    var id = UUID()
    let name: String
    let baseGrowthDuration: TimeInterval
    let textureName: String?
    let value: Int
    let buyPrice: Int
    let preferredWeather: WeatherCondition

    static let sampleCrops: [CropModel] = [
        CropModel(name: "Corn", baseGrowthDuration: 6, textureName: "corn", value: 5, buyPrice: 2, preferredWeather: .sunny),
        CropModel(name: "Sunflower", baseGrowthDuration: 8, textureName: "sunflower", value: 7, buyPrice: 3, preferredWeather: .sunny),
        CropModel(name: "Rice", baseGrowthDuration: 5, textureName: "rice", value: 4, buyPrice: 1, preferredWeather: .rain),
        CropModel(name: "Cranberries", baseGrowthDuration: 10, textureName: "cranberries", value: 12, buyPrice: 5, preferredWeather: .rain),
        CropModel(name: "Kale", baseGrowthDuration: 8, textureName: "kale", value: 10, buyPrice: 6, preferredWeather: .snow),
        CropModel(name: "Frost Berries", baseGrowthDuration: 16, textureName: "frostberries", value: 16, buyPrice: 12, preferredWeather: .snow),
        CropModel(name: "Cactus", baseGrowthDuration: 18, textureName: "cactus", value: 12, buyPrice: 6, preferredWeather: .extremeHeat),
        CropModel(name: "Wheat", baseGrowthDuration: 15, textureName: "wheat", value: 20, buyPrice: 8, preferredWeather: .extremeHeat),
        CropModel(name: "Radish", baseGrowthDuration: 15, textureName: "radish", value: 10, buyPrice: 8, preferredWeather: .cloudy),
        CropModel(name: "Potato", baseGrowthDuration: 15, textureName: "potato", value: 16, buyPrice: 12, preferredWeather: .cloudy),
    ]
}
