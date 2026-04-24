//
//  GoldLabel.swift
//  WeatherFarm
//
//  Created by Naufal Muafa on 24/04/26.
//
import SwiftUI

struct GoldLabel: View {
    @EnvironmentObject var viewModel: GameViewModel

    var body: some View {
        HStack {
            Spacer()

            HStack(spacing: 6) {
                Image("coin")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)

                Text("\(viewModel.gold)")
                    .font(.minecraft())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.1), radius: 4)
        }
    }
}

struct GoldLabel_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.blue.ignoresSafeArea()
            GoldLabel()
                .environmentObject(GameViewModel())
        }
    }
}
