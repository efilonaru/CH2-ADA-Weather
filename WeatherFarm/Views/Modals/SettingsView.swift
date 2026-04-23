import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @EnvironmentObject var worldManager: WorldEnvironmentManager
    var body: some View {
        List {
            Section(header: Text("Weather Control").font(.minecraft(size: 16))) {
                Picker("Current Climate", selection: $worldManager.currentWeather) {
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
//                            Image(systemName: time.icon)
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
                    Image("coin")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                    Text("\(viewModel.plantedCrops.count)")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Total Base Value")
                    Spacer()
                    Image("coin")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                    Text("\(viewModel.potentialGoldSummary)")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Weather Bonus (20%)")
                    Spacer()
                    Image("coin")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                    Text("\(viewModel.currentWeatherBonus)")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Potential Total Gold")
                    Spacer()
                    Image("coin")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                    Text("\(viewModel.potentialGoldSummary + viewModel.currentWeatherBonus)")
                        .foregroundColor(.secondary)
                }
                
                if !viewModel.plantedCrops.isEmpty {
                    let totalPotential = Double(viewModel.potentialGoldSummary + viewModel.currentWeatherBonus)
                    let avg = totalPotential / Double(viewModel.plantedCrops.count)
                    HStack {
                        Text("Average Gold / Crop")
                        Spacer()
                        Text(String(format: "%.1f", avg))
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
