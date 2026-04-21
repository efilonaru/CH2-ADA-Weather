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

            Text("Plant a crop")
                .font(.subheadline)
                .foregroundColor(.secondary)

            // Crop catalog
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.crops) { crop in
                        Button(action: {
                            viewModel.requestPlant(crop: crop)
                        }) {
                            VStack {
                                // Placeholder crop image
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.green.opacity(0.7))
                                    .frame(width: 64, height: 64)
                                    .overlay(Text(crop.name.prefix(1)).font(.title).foregroundColor(.white))

                                Text(crop.name)
                                    .font(.caption)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 10)
        .onAppear {
            // ensure the view model has focus on this tile (optional)
        }
    }
}

#Preview {
    TileModalView(gridX: 0, gridY: 0).environmentObject(GameViewModel())
}
