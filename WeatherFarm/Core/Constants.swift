//
//  Constants.swift
//  WeatherFarm
//
//  Created by Michel Pierce on 21/04/26.
//

import Foundation

enum Constants {
    enum Game {
        static let autoHarvestBonus: Double = 0.2
        static let preferredWeatherMultiplier: Double = 1.5
        static let baseTileCost: Int = 20
        static let tileCostIncrease: Int = 10
    }
    
    enum Weather {
        static let spawnInterval: TimeInterval = 0.02
        
        enum Rain {
            static let rotation: CGFloat = 0.4
            static let duration: TimeInterval = 0.8
            static let moveX: CGFloat = -500
            static let alpha: ClosedRange<CGFloat> = 0.5...1.0
            static let scale: ClosedRange<CGFloat> = 0.8...1.2
        }
        
        enum Snow {
            static let rotation: CGFloat = 0
            static let duration: TimeInterval = 3.0
            static let moveX: ClosedRange<CGFloat> = -50...20
            static let alpha: ClosedRange<CGFloat> = 0.7...1.0
            static let scale: ClosedRange<CGFloat> = 0.5...1.0
        }
        
        static let spawnOffset: CGFloat = 300
        static let extraFallDistance: CGFloat = 150
    }
    
    enum Animation {
        static let floatingGoldRise: CGFloat = 30
        static let floatingGoldDuration: TimeInterval = 0.6
        static let floatingGoldFadeIn: TimeInterval = 0.1
    }
    
    enum Camera {
        static let padding: CGFloat = 64
        static let minScale: CGFloat = 0.25
        static let maxScale: CGFloat = 3.0
    }
    
    enum Render {
        static let tileScale: CGFloat = 2.0
        static let tileGap: CGFloat = 4.0
        static let minZoomFactor: CGFloat = 0.25
        static let zoomOutLimit: CGFloat = 3.0
    }
    
    enum Growth {
        static let stage1: Double = 0.33
        static let stage2: Double = 0.66
    }
    
    enum Grid {
        static let rows: Int = 3
        static let cols: Int = 3
    }
    
    enum ZIndex {
        static let weather: CGFloat = 1000
        static let floatingText: CGFloat = 2000
        static let ghostOffset: CGFloat = -1
    }
    
    enum Layout {
        static let weatherSpawnOffset: CGFloat = 300
        static let weatherStartYOffset: CGFloat = 50
        static let floatingGoldOffsetY: CGFloat = 40
    }
    
    enum Tile {
        static let fallbackSize = CGSize(width: 64, height: 64)
    }
}
