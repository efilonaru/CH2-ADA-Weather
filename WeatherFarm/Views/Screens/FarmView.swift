//
//  FarmView.swift
//  WeatherFarm
//
//  Created by Michel Pierce on 21/04/26.
//
import SwiftUI
import SpriteKit

struct FarmView: View {
    @EnvironmentObject var worldManager : WorldEnvironmentManager
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
        ZStack {
            // TODO: CHANGE THIS MANUT MO APA TAPI WORLDMANAGER FOR NOW
            SkyBackgroundView(weather: .sunny, time: .night)
            SpriteView(scene: scene, options: .allowsTransparency)
                .ignoresSafeArea()
                .onAppear {
                    viewModel.worldManager = worldManager
                    if let gs = scene as? GameScene {
                        gs.gameViewModel = viewModel
                        gs.worldManager = worldManager
                    }
                }
            
            VStack {
                topBar
                goldView
                Spacer()
                bottomBar
            }
            .padding()
        }
        .environmentObject(viewModel)
        .alert(viewModel.confirmationMessage, isPresented: $viewModel.showConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Buy") {
                viewModel.onConfirm?()
            }
        }
        .sheet(isPresented: $showingWeatherCalendar) {
                    WeatherDetailsView()
                .presentationDetents([.large])
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
    }
    
    var topBar: some View {
        WeatherForecast(data: todayHourly)
            .onTapGesture {
                showingWeatherCalendar = true
            }
    }
    
    var goldView: some View {
        HStack {
            Spacer()
            
            HStack(spacing: 6) {
                Image(systemName: "bitcoinsign.circle.fill")
                    .foregroundColor(.yellow)
                
                Text("\(viewModel.gold)")
                    .font(.minecraft())
//                    .font(.system(.headline, design: .rounded))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.1), radius: 4)
        }
    }
    
    @State private var isMenuExpanded = false
    
    var bottomBar: some View {
        HStack {
            Spacer()
            
            VStack(spacing: 16) {
                if isMenuExpanded {
                    // Settings Button
                    GameActionButton(systemName: "gearshape.fill", color: .gray) {
                        viewModel.showSettings = true
                        isMenuExpanded = false
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    
                    // Edit Mode Button
                    GameActionButton(
                        systemName: "pencil",
                        color: viewModel.isEditMode ? .purple : .blue
                    ) {
                        viewModel.toggleEditMode()
                        withAnimation { isMenuExpanded = false }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    
                    // Inventory Button
                    GameActionButton(systemName: "bag.fill", color: .green) {
                        viewModel.showInventory = true
                        isMenuExpanded = false
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    
                    // Shop Button
                    GameActionButton(systemName: "cart.fill", color: .orange) {
                        viewModel.showShop = true
                        isMenuExpanded = false
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // Toggle Button (Chevron)
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        isMenuExpanded.toggle()
                    }
                }) {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                        .rotationEffect(.degrees(isMenuExpanded ? 180 : 0))
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(.white.opacity(0.3), lineWidth: 1))
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            .padding(12)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
            .overlay(Capsule().stroke(.white.opacity(0.2), lineWidth: 1))
        }
    }
    

    struct GameActionButton: View {
        let systemName: String
        let color: Color
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Image(systemName: systemName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 52, height: 52)
                    .background(
                        LinearGradient(
                            colors: [color, color.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                    .shadow(color: color.opacity(0.4), radius: 6, x: 0, y: 3)
                    .overlay(Circle().stroke(.white.opacity(0.3), lineWidth: 1.5))
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }
    
    struct ScaleButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
        }
    }
    
    struct SecondaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .opacity(configuration.isPressed ? 0.7 : 1.0)
                .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        }
    }
    
}


#Preview {
    FarmView()
        .environmentObject(WorldEnvironmentManager())
}
