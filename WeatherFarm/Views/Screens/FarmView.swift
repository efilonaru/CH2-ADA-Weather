//
//  FarmView.swift
//  WeatherFarm
//
//  Created by Michel Pierce on 21/04/26.
//
import SwiftUI
import SpriteKit
import SwiftData

struct FarmView: View {
    @EnvironmentObject var worldManager : WorldEnvironmentManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @State private var showingWeatherCalendar = false
    @StateObject private var viewModel = GameViewModel()
    @State private var scene: SKScene = {
        let s = GameScene()
        s.scaleMode = .resizeFill
        s.backgroundColor = .clear
        return s
    }()
    
    var todayHourly: [HourlyWeather] {
        guard let base = MockData.weekForecast.first(where: { $0.isToday })?.hourlyData else {
            return []
        }

        let now = HourlyWeather(
            time: "Now",
            iconName: worldManager.currentWeather.icon,
            temp: base.first?.temp ?? 30
        )

        return [now] + base.dropFirst()
    }
    
    var body: some View {
       NavigationStack {
           ZStack {
               // TODO: CHANGE THIS MANUT MO APA TAPI WORLDMANAGER FOR NOW
               SkyBackgroundView(weather: worldManager.currentWeather, time: worldManager.currentTime)
               SpriteView(scene: scene, options: .allowsTransparency)
                   .ignoresSafeArea()
                   .onAppear {
                       viewModel.modelContext = modelContext
                       viewModel.worldManager = worldManager
                       viewModel.loadSavedGameState()
                       if let gs = scene as? GameScene {
                           gs.gameViewModel = viewModel
                           gs.worldManager = worldManager
                       }
                   }
               
               VStack(spacing: 0) {
                   NavigationLink(destination: WeatherDetailsView()){
                       WeatherForecast(data: todayHourly)
                   }
                   .buttonStyle(.plain)
                   
                   GoldLabel()
                       .padding(8)
                   Spacer()
                   FloatingActionButton()
               }
           }
        }
        .toolbar(.hidden, for: .navigationBar)
        .environmentObject(viewModel)
        .alert(viewModel.confirmationMessage, isPresented: $viewModel.showConfirmation) {
            Button("OK") {}
        }
        .sheet(isPresented: $viewModel.showShop) {
            ShopView()
                .environmentObject(viewModel)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $viewModel.showInventory) {
            InventoryView()
                .environmentObject(viewModel)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $viewModel.showSettings) {
            NavigationView {
                SettingsView()
                    .environmentObject(viewModel)
            }
        }
        .sheet(item: $viewModel.selectedTile, onDismiss: {
            viewModel.deselectTile()
        }) { selection in
            TileModalView(gridX: selection.gridX, gridY: selection.gridY)
                .presentationDetents([.medium])
                .environmentObject(viewModel)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background || newPhase == .inactive {
                if let gs = scene as? GameScene {
                    gs.syncToSwiftData(modelContext: modelContext)
                }
                viewModel.saveGameState()
            }
        }
    }
}


#Preview {
    FarmView()
        .environmentObject(WorldEnvironmentManager())
}
