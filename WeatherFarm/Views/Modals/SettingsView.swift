import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @EnvironmentObject var worldManager: WorldEnvironmentManager
    @State private var isReady: Bool = false
    var body: some View {
        NavigationStack {
            Group {
                if isReady {
                    settingsContent
                } else {
                    VStack(spacing: 16) {
                        ProgressView()
                            .controlSize(ControlSize.large)
                        Text("Loading...")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation{
                        isReady = true
                    }
                }
            }
        }
    }

    var settingsContent: some View {
        List {
            Section(header: Text("Weather Control").font(.minecraft(size: 16)))
            {
                Picker(
                    "Current Climate",
                    selection: $worldManager.currentWeather
                ) {
                    ForEach(WeatherCondition.allCases, id: \.self) { weather in
                        HStack {
                            Image(systemName: weather.icon)
                            Text(weather.rawValue)
                        }
                        .tag(weather)
                    }
                }
                .pickerStyle(.inline)
            }

            Section(header: Text("Time Control").font(.minecraft(size: 16))) {
                Picker("Current Time", selection: $worldManager.currentTime) {
                    ForEach(TimeOfDay.allCases, id: \.self) { time in
                        HStack {
                            Text(time.rawValue)
                        }
                        .tag(time)
                    }
                }
                .pickerStyle(.inline)
            }

            Section(header: Text("Farm Summary").font(.minecraft(size: 16))) {
                HStack {
                    Text("Planted Crops")
                    Spacer()
                    Text("\(viewModel.plantedCrops.count)")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Total Base Value")
                    Spacer()
                    Text("💰 \(viewModel.potentialGoldSummary)")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Weather Bonus (20%)")
                    Spacer()
                    Text("+ 💰 \(viewModel.currentWeatherBonus)")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Potential Total Gold")
                    Spacer()
                    Text(
                        "💰 \(viewModel.potentialGoldSummary + viewModel.currentWeatherBonus)"
                    )
                    .foregroundColor(.secondary)
                }

                if !viewModel.plantedCrops.isEmpty {
//                    let totalPotential = Double(
//                        viewModel.potentialGoldSummary
//                            + viewModel.currentWeatherBonus
//                    )
//                    let avg =
//                        totalPotential / Double(viewModel.plantedCrops.count)
                    HStack {
                        Text("Average Gold / Crop")
                        Spacer()
                        Text(String(format: "%.1f", viewModel.averageGoldPerCrop))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        //        .navigationTitle("Settings")
        .background(Color(UIColor.systemGroupedBackground))
    }
}

#Preview {
    SettingsView()
        .environmentObject(GameViewModel())
        .environmentObject(WorldEnvironmentManager())
        .font(.minecraft(size: 18))
}
