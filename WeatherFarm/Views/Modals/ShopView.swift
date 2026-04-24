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
                .font(.minecraft(size: 24))
                .padding(.top)
            
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
                .font(.minecraft(size: 14))
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
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .frame(height: 120)

                if let texture = crop.textureName, !texture.isEmpty {
                    Image("\(texture)_harvest")
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                } else {
                    Text(crop.name.prefix(1))
                        .font(.minecraft(size: 16))
                }

                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: crop.preferredWeather.icon)
                            .foregroundColor(.blue.opacity(0.6))
                    }
                    Spacer()
                }
                .padding(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(crop.name)
                    .font(.minecraft(size: 14))
                
                HStack {
                    Image("coin")
                        .resizable()
                        .frame(width: 16, height: 16)
                    
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

#Preview {
    ShopView()
}
