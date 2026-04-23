//
//  Extensions.swift
//  WeatherFarm
//
//  Created by Michel Pierce on 21/04/26.
//

import SwiftUI
import SpriteKit

extension Font {
    static func minecraft(size: CGFloat = 14) -> Font {
        Font.custom("Minecraft", size: size)
    }
}

extension SKTexture {
    static func fromSymbol(_ systemName: String, pointSize: CGFloat, color: UIColor) -> SKTexture? {
        let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .bold)
        guard let image = UIImage(systemName: systemName, withConfiguration: config)?.withTintColor(color, renderingMode: .alwaysOriginal) else { return nil }
        return SKTexture(image: image)
    }
}
