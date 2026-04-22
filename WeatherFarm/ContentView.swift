//
//  ContentView.swift
//  WeatherFarm
//
//  Created by Naufal Muafa on 19/04/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        FarmView()
    }
}

#Preview {
    ContentView()
        .environmentObject(WorldEnvironmentManager())
}
