import SwiftUI

struct ShopView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @State private var selectedClimate: WeatherCondition? = nil
    
    var filteredCrops: [CropModel] {
        if let climate = selectedClimate {
            return viewModel.crops.filter { $0.preferredWeather == climate }
        }
        return viewModel.crops
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Seed Shop")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .padding(.top)
            
            // Climate Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    FilterButton(title: "All", isSelected: selectedClimate == nil) {
                        selectedClimate = nil
                    }
                    
                    ForEach(WeatherCondition.allCases, id: \.self) { climate in
                        FilterButton(
                            title: climate.rawValue,
                            isSelected: selectedClimate == climate
                        ) {
                            selectedClimate = climate
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Shop Grid
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(filteredCrops) { crop in
                        ShopItemCard(crop: crop)
                    }
                }
                .padding()
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.white)
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
                .shadow(radius: 2)
        }
    }
}

struct ShopItemCard: View {
    @EnvironmentObject var viewModel: GameViewModel
    let crop: CropModel
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .frame(height: 120)
                
                Image(systemName: crop.preferredWeather.icon)
                    .foregroundColor(.blue.opacity(0.6))
                    .padding(8)
            }
            .overlay(
                Text(crop.name.prefix(1))
                    .font(.largeTitle)
                    .fontWeight(.bold)
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(crop.name)
                    .font(.headline)
                
                HStack {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .foregroundColor(.yellow)
                    Text("\(crop.buyPrice)")
                        .fontWeight(.bold)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: {
                viewModel.buyCrop(crop)
            }) {
                Text("Buy")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(viewModel.gold >= crop.buyPrice ? Color.green : Color.gray)
                    .cornerRadius(8)
            }
            .disabled(viewModel.gold < crop.buyPrice)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}
