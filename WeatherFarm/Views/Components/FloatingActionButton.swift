//
//  FloatingActionButton.swift
//  WeatherFarm
//
//  Created by Naufal Muafa on 24/04/26.
//
import SwiftUI

fileprivate struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

fileprivate struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// Helper button with the gradient and shadow styles from the original FarmView
fileprivate struct GameActionButton: View {
    let systemName: String
//    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 52, height: 52)
                .background(
                    .gray.opacity(0.4)
                    )
                .clipShape(Circle())
                .shadow(radius: 6, x: 0, y: 3)
                .overlay(Circle().stroke(.white.opacity(0.3), lineWidth: 1.5))
        }
//        .buttonStyle(ScaleButtonStyle())
    }
}

struct FloatingActionButton: View {
    @EnvironmentObject var viewModel: GameViewModel
    @State private var isMenuExpanded = false

    var body: some View {
        HStack {
            Spacer()

            VStack(spacing: 16) {
                if isMenuExpanded {
                    // Settings Button
                    GameActionButton(systemName: "gearshape.fill") {
                        viewModel.showSettings = true
                        isMenuExpanded = false
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))

                    // Edit Mode Button
                    GameActionButton(
                        systemName: "pencil"
                    ) {
                        viewModel.toggleEditMode()
                        withAnimation { isMenuExpanded = false }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))

                    // Inventory Button
                    GameActionButton(systemName: "bag.fill") {
                        viewModel.showInventory = true
                        isMenuExpanded = false
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))

                    // Shop Button
                    GameActionButton(systemName: "cart.fill") {
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
//                .buttonStyle(SecondaryButtonStyle())
            }
            .padding(12)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
            .overlay(Capsule().stroke(.white.opacity(0.2), lineWidth: 1))
        }
        .padding(.trailing, 16)
        .padding(.bottom, 16)
    }
}

struct FloatingActionButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.blue.ignoresSafeArea()
            FloatingActionButton()
                .environmentObject(GameViewModel())
        }
    }
}
