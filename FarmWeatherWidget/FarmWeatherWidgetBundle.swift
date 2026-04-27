//
//  FarmWeatherWidgetBundle.swift
//  FarmWeatherWidget
//
//  Created by Michel Pierce on 24/04/26.
//

import WidgetKit
import SwiftUI

@main
struct FarmWeatherWidgetBundle: WidgetBundle {
    var body: some Widget {
        FarmWeatherWidget()
        FarmWeatherWidgetControl()
        FarmWeatherWidgetLiveActivity()
    }
}
