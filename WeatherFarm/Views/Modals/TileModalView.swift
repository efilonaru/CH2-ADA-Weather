import SwiftUI

struct TileModalView: View {
    let gridX: Int
    let gridY: Int

    @EnvironmentObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 12) {
            Capsule()
                .frame(width: 40, height: 6)
                .foregroundColor(Color.secondary)
                .padding(.top, 8)

            Text("Tile (\(gridX), \(gridY))")
                .font(.headline)

            if viewModel.isEditMode {
                Button(action: {
                    viewModel.requestHarvest(x: gridX, y: gridY)
                }) {
                    HStack {
                        Image(systemName: "trash.fill")
                        Text("Remove Crop")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
            }

            let ownedCrops = viewModel.getOwnedCrops()
            
            if ownedCrops.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "tray.and.arrow.down.fill")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    Text("No seeds in inventory")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button("Go to Shop") {
                        viewModel.deselectTile()
                        viewModel.showShop = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else {
                Text("Select a seed to plant")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(ownedCrops) { crop in
                            Button(action: {
                                viewModel.requestPlant(crop: crop)
                            }) {
                                VStack {
                                    ZStack(alignment: .bottomTrailing) {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.green.opacity(0.1))
                                            .frame(width: 70, height: 70)
                                            .overlay(
                                                Text(crop.name.prefix(1))
                                                    .font(.title)
                                            )
                                        
                                        Text("\(viewModel.inventory[crop.name] ?? 0)")
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .padding(4)
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .clipShape(Circle())
                                    }

                                    Text(crop.name)
                                        .font(.caption)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
    }
}
