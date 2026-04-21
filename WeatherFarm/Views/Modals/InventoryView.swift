import SwiftUI

struct InventoryView: View {
    @EnvironmentObject var viewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Your Seeds")
                .font(.system(.title2, design: .rounded, weight: .bold))
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
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .frame(height: 80)
                
                Text("\(count)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(4)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .offset(x: 4, y: 4)
            }
            .overlay(
                Text(crop.name.prefix(1))
                    .font(.title)
                    .fontWeight(.bold)
            )
            
            Text(crop.name)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3)
    }
}
