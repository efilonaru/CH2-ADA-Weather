import SwiftUI

struct InventoryView: View {
    @EnvironmentObject var viewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Your Seeds")
                .font(.minecraft(size: 24))
                .padding(.top)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(viewModel.crops) { crop in
                        let count = viewModel.inventory[crop.name] ?? 0
                        if count > 0 {
                            InventoryItemCard(crop: crop, count: count)
                        }
                    }
                }
                .padding()
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}

struct InventoryItemCard: View {
    let crop: CropModel
    let count: Int

    private let cardWidth: CGFloat = 100
    private let cardHeight: CGFloat = 140

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .frame(height: 100)

                if let texture = crop.textureName, !texture.isEmpty {
                    Image("\(texture)_harvest")
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                } else {
                    Text(crop.name.prefix(1))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }

                VStack {
                    HStack {
                        Image(systemName: crop.preferredWeather.icon)
                            .font(.system(size: 12))
                            .foregroundColor(.blue.opacity(0.7))

                        Spacer()

                        Text("\(count)")
                            .font(.minecraft(size: 10))
                            .fontWeight(.bold)
                            .padding(6)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(6)
            }

            Text(crop.name)
                .font(.minecraft(size: 12))
                .fontWeight(.medium)
        }
        .frame(width: cardWidth, height: cardHeight)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3)
    }
}
