//
//  FarmView.swift
//  WeatherFarm
//
//  Created by Michel Pierce on 21/04/26.
//
import SwiftUI
import SpriteKit

struct FarmView: View {
    @State private var showingWeatherCalendar = false
    @StateObject private var viewModel = GameViewModel()
    @State private var scene: SKScene = {
        let s = GameScene()
        s.scaleMode = .resizeFill
        s.backgroundColor = .clear
        return s
    }()
    
    var body: some View {
        ZStack {
            SkyBackgroundView(weather: .sunny, time: .day)
            SpriteView(scene: scene)
                .ignoresSafeArea()
                .onAppear {
                    if let gs = scene as? GameScene {
                        gs.gameViewModel = viewModel
                    }
                }
            
            VStack {
                topBar
                Spacer()
                bottomBar
            }
            .padding()
        }
        .environmentObject(viewModel)
        .sheet(isPresented: $showingWeatherCalendar) {
                    WeatherDetailsView()
                .presentationDetents([.large])
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
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    
                    Button(action: {
                        showingWeatherCalendar = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "sun.max.fill")
                                .foregroundColor(.orange)
                            Text("Sunny")
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(SecondaryButtonStyle())

                    HStack(spacing: 6) {
                        Image(systemName: "bitcoinsign.circle.fill")
                            .foregroundColor(.yellow)
                        Text("\(viewModel.gold)")
                            .font(.system(.headline, design: .rounded))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.1), radius: 4)
                }
                
                Spacer()

                Button(action: {}) {
                    Image(systemName: "gearshape.fill")
                    .font(.title3)
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(.white.opacity(0.2), lineWidth: 1))
            }
            .buttonStyle(SecondaryButtonStyle())
        }
    }
    
    var bottomBar: some View {
        HStack {
            Spacer()
            
            VStack(spacing: 16) {
                // Edit Mode Button
                GameActionButton(systemName: "pencil", color: .blue)
                
                // Shop Button
                GameActionButton(systemName: "cart.fill", color: .orange)
                
                // Expand/Inventory Button
                Button(action: {}) {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
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
    
    
    // MARK: - Supporting Views & Styles
    
    struct GameActionButton: View {
        let systemName: String
        let color: Color
        
        var body: some View {
            Button(action: {}) {
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
}
