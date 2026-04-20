//
//  ContentView.swift
//  WeatherFarm
//
//  Created by Naufal Muafa on 19/04/26.
//

import SwiftUI
import SpriteKit

struct ContentView: View {

    var scene: SKScene {
        let scene = GameScene()
        scene.scaleMode = .resizeFill
        return scene
    }

    var body: some View {
        ZStack {
            SpriteView(scene: scene)
                .ignoresSafeArea()

            VStack {
                topBar
                Spacer()
                bottomBar
            }
            .padding()
        }
    }

    var topBar: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("☀️ Sunny")
                Text("💰 0")
            }
            Spacer()

            Button(action: {}) {
                Image(systemName: "gearshape.fill")
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .clipShape(Circle())
            }
        }
    }

    var bottomBar: some View {
        HStack {
            Spacer()

            VStack(spacing: 12) {
                Button(action: {}) {
                    Image(systemName: "pencil")
                }

                Button(action: {}) {
                    Image(systemName: "cart")
                }

                Button(action: {}) {
                    Image(systemName: "chevron.up")
                }
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

#Preview {
    ContentView()
}
